import Foundation

/// Data shared between the main app and widget via direct file in the widget's sandbox container.
///
/// The main app (non-sandboxed) writes a JSON file into the widget extension's container directory.
/// The widget (sandboxed) reads from its own Application Support, which maps to the same path.
struct WidgetAccountData: Codable {
    let email: String          // pre-obfuscated
    let displayName: String    // pre-obfuscated
    let subscriptionType: String?
    let isActive: Bool
    let sessionUtilization: Double?
    let sessionResetTime: String?
    let weeklyUtilization: Double?
    let weeklyResetTime: String?
    let extraUsageEnabled: Bool?
    let hasError: Bool
    let errorMessage: String?
}

struct WidgetData: Codable {
    let accounts: [WidgetAccountData]
    let todayCost: Double
    let conversationTurns: Int
    let activeCodingTime: String
    let linesWritten: Int
    let modelUsage: [String: Int]
    let lastUpdated: Date

    private static let fileName = "widget-data.json"
    private static let subdir = "CCSwitcherWidget"
    private static let widgetBundleID = "me.xueshi.ccswitcher.widget"

    /// Load from the widget's own Application Support directory (called by widget extension).
    static func load() -> WidgetData? {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = appSupport.appendingPathComponent(subdir).appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WidgetData.self, from: data)
    }

    /// Save into the widget extension's sandbox container (called by the main app, which is non-sandboxed).
    /// Only writes if the container already exists — macOS creates it when the widget is first added
    /// to the desktop. We must not create the container ourselves as it would lack the system metadata.
    func save() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let widgetContainer = home
            .appendingPathComponent("Library/Containers")
            .appendingPathComponent(Self.widgetBundleID)

        guard FileManager.default.fileExists(atPath: widgetContainer.path) else { return }

        let containerAppSupport = widgetContainer
            .appendingPathComponent("Data/Library/Application Support")
            .appendingPathComponent(Self.subdir)

        try? FileManager.default.createDirectory(at: containerAppSupport, withIntermediateDirectories: true)
        let fileURL = containerAppSupport.appendingPathComponent(Self.fileName)
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
