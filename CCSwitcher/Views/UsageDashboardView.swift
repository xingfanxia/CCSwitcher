import SwiftUI

/// Shows usage statistics: today, weekly, and a bar chart of recent activity.
struct UsageDashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Today's stats
                statsSection(
                    title: "Today",
                    messages: appState.usageSummary.todayMessages,
                    sessions: appState.usageSummary.todaySessionCount,
                    toolCalls: appState.usageSummary.todayToolCalls
                )

                // Weekly stats
                statsSection(
                    title: "This Week",
                    messages: appState.usageSummary.weeklyMessages,
                    sessions: appState.usageSummary.weeklySessionCount,
                    toolCalls: appState.usageSummary.weeklyToolCalls
                )

                // Weekly chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Activity")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    UsageChartView(activities: appState.recentActivity)
                        .frame(height: 120)
                }
                .padding(.horizontal, 16)

                // Active sessions
                if !appState.activeSessions.isEmpty {
                    activeSessionsSection
                }

                // All-time stats
                HStack(spacing: 20) {
                    miniStat(
                        label: "Total Messages",
                        value: formatNumber(appState.usageSummary.totalMessages)
                    )
                    miniStat(
                        label: "Total Sessions",
                        value: formatNumber(appState.usageSummary.totalSessions)
                    )
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: - Stats Section

    private func statsSection(title: String, messages: Int, sessions: Int, toolCalls: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                statCard(icon: "message.fill", label: "Messages", value: messages, color: .blue)
                statCard(icon: "rectangle.stack.fill", label: "Sessions", value: sessions, color: .green)
                statCard(icon: "wrench.fill", label: "Tool Calls", value: toolCalls, color: .orange)
            }
        }
        .padding(.horizontal, 16)
    }

    private func statCard(icon: String, label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.system(.title3, design: .rounded, weight: .bold))

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Active Sessions

    private var activeSessionsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Active Sessions")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(appState.activeSessions.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }

            ForEach(appState.activeSessions) { session in
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)

                    Text(session.cwd?.replacingOccurrences(of: NSHomeDirectory(), with: "~") ?? "Unknown")
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    if let date = session.startDate {
                        Text(date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Mini Stat

    private func miniStat(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 6))
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1000 {
            return String(format: "%.1fK", Double(n) / 1000.0)
        }
        return "\(n)"
    }
}
