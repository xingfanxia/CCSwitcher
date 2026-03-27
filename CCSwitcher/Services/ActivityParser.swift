import Foundation

private let log = FileLog("ActivityParser")

/// Parses Claude Code session JSONL files to extract today's coding activity stats:
/// conversation turns, active coding time, tool usage, lines written, model usage.
final class ActivityParser: Sendable {
    static let shared = ActivityParser()

    private let claudeDir: String

    private init() {
        self.claudeDir = NSHomeDirectory() + "/.claude"
    }

    func getTodayStats() -> ActivityStats {
        let projectsDir = claudeDir + "/projects"
        let fm = FileManager.default

        guard let projectDirs = try? fm.contentsOfDirectory(atPath: projectsDir) else {
            return .empty
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoFallback = ISO8601DateFormatter()
        isoFallback.formatOptions = [.withInternetDateTime]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayStr = dateFormatter.string(from: Date())

        var turns = 0
        var sessionTimestamps: [String: [Date]] = [:]  // sessionId → timestamps
        var toolCounts: [String: Int] = [:]
        var linesWritten = 0
        var modelCounts: [String: Int] = [:]
        var seenRequests: Set<String> = []

        for projectDir in projectDirs {
            let projectPath = projectsDir + "/" + projectDir
            guard let files = try? fm.contentsOfDirectory(atPath: projectPath) else { continue }

            for file in files where file.hasSuffix(".jsonl") && !file.contains("subagent") {
                let filePath = projectPath + "/" + file
                // Skip subagent files (internal agent-to-agent communication)
                if filePath.contains("/subagents/") { continue }
                guard let data = fm.contents(atPath: filePath),
                      let content = String(data: data, encoding: .utf8) else { continue }

                for line in content.components(separatedBy: .newlines) {
                    guard !line.isEmpty,
                          let lineData = line.data(using: .utf8),
                          let obj = try? JSONSerialization.jsonObject(with: lineData) as? [String: Any],
                          let timestampStr = obj["timestamp"] as? String,
                          let timestamp = isoFormatter.date(from: timestampStr) ?? isoFallback.date(from: timestampStr) else { continue }

                    // Filter for today only
                    guard dateFormatter.string(from: timestamp) == todayStr else { continue }

                    let type = obj["type"] as? String ?? ""

                    // Collect timestamps per session for active time calculation
                    let sessionId = obj["sessionId"] as? String ?? file
                    sessionTimestamps[sessionId, default: []].append(timestamp)

                    switch type {
                    case "user":
                        // Only count real user input, not tool_result feedback
                        let message = obj["message"] as? [String: Any]
                        let content = message?["content"]
                        if let str = content as? String, !str.isEmpty {
                            turns += 1
                        } else if let arr = content as? [[String: Any]] {
                            let hasToolResult = arr.contains { $0["type"] as? String == "tool_result" }
                            if !hasToolResult { turns += 1 }
                        }

                    case "assistant":
                        guard let message = obj["message"] as? [String: Any] else { continue }

                        // Model usage (deduplicate by requestId)
                        if let model = message["model"] as? String,
                           let requestId = obj["requestId"] as? String,
                           !seenRequests.contains(requestId) {
                            seenRequests.insert(requestId)
                            let shortName = CostParser.shortModelName(model)
                            modelCounts[shortName, default: 0] += 1
                        }

                        // Tool usage & lines written from content array
                        if let content = message["content"] as? [[String: Any]] {
                            for block in content {
                                guard let blockType = block["type"] as? String,
                                      blockType == "tool_use",
                                      let toolName = block["name"] as? String else { continue }

                                toolCounts[toolName, default: 0] += 1

                                // Estimate lines written from Edit/Write tools
                                if let input = block["input"] as? [String: Any] {
                                    linesWritten += Self.estimateLines(tool: toolName, input: input)
                                }
                            }
                        }

                    default:
                        break
                    }
                }
            }
        }

        let activeMinutes = Self.calculateActiveMinutes(from: sessionTimestamps)

        log.info("[getTodayStats] turns=\(turns) active=\(activeMinutes)m tools=\(toolCounts.values.reduce(0,+)) lines=\(linesWritten) models=\(modelCounts)")
        return ActivityStats(
            conversationTurns: turns,
            activeCodingMinutes: activeMinutes,
            toolUsage: toolCounts,
            linesWritten: linesWritten,
            modelUsage: modelCounts
        )
    }

    // MARK: - Helpers

    /// Estimate net lines written from a tool call's input parameters.
    private static func estimateLines(tool: String, input: [String: Any]) -> Int {
        switch tool {
        case "Write":
            let content = input["content"] as? String ?? ""
            return content.components(separatedBy: "\n").count
        case "Edit":
            let newStr = input["new_string"] as? String ?? ""
            let oldStr = input["old_string"] as? String ?? ""
            let added = newStr.components(separatedBy: "\n").count
            let removed = oldStr.components(separatedBy: "\n").count
            return max(0, added - removed)
        default:
            return 0
        }
    }

    /// Calculate total active coding minutes across all sessions.
    /// Each session's active time is calculated independently, then summed.
    /// Parallel sessions stack — 3 sessions × 30 min = 90 min.
    private static func calculateActiveMinutes(from sessionTimestamps: [String: [Date]]) -> Int {
        let maxGap: TimeInterval = 10 * 60
        let tailPadding: TimeInterval = 2 * 60

        var totalSeconds: TimeInterval = 0

        for (_, timestamps) in sessionTimestamps {
            guard timestamps.count >= 2 else {
                if !timestamps.isEmpty { totalSeconds += tailPadding }
                continue
            }

            let sorted = timestamps.sorted()
            var periodStart = sorted[0]
            var periodEnd = sorted[0]

            for i in 1..<sorted.count {
                let gap = sorted[i].timeIntervalSince(periodEnd)
                if gap <= maxGap {
                    periodEnd = sorted[i]
                } else {
                    totalSeconds += periodEnd.timeIntervalSince(periodStart) + tailPadding
                    periodStart = sorted[i]
                    periodEnd = sorted[i]
                }
            }
            totalSeconds += periodEnd.timeIntervalSince(periodStart) + tailPadding
        }

        return totalSeconds > 0 ? max(1, Int(totalSeconds / 60)) : 0
    }
}
