import SwiftUI
import ServiceManagement

/// Settings window for configuring the app.
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("refreshInterval") private var refreshInterval: Double = 30
    @AppStorage("showSessionCount") private var showSessionCount = true
    @AppStorage("showInDock") private var showInDock = false
    @State private var launchAtLogin = false

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            accountsTab
                .tabItem {
                    Label("Accounts", systemImage: "person.2")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("Refresh") {
                Picker("Auto-refresh interval", selection: $refreshInterval) {
                    Text("15 seconds").tag(15.0)
                    Text("30 seconds").tag(30.0)
                    Text("1 minute").tag(60.0)
                    Text("5 minutes").tag(300.0)
                }
                .onChange(of: refreshInterval) { _, newValue in
                    appState.startAutoRefresh(interval: newValue)
                }
            }

            Section("Appearance") {
                Toggle("Show active session count in menu bar", isOn: $showSessionCount)
            }

            Section("System") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        toggleLaunchAtLogin(newValue)
                    }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Accounts Tab

    private var accountsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manage Accounts")
                .font(.headline)

            Text("To add an account, first log in to that account in Claude Code using 'claude auth login', then click 'Add Current Account' in the main menu.")
                .font(.caption)
                .foregroundStyle(.secondary)

            List {
                ForEach(appState.accounts) { account in
                    HStack {
                        Image(systemName: account.provider.iconName)
                            .foregroundStyle(account.isActive ? .purple : .secondary)

                        VStack(alignment: .leading) {
                            Text(account.displayName)
                                .font(.body.weight(.medium))
                            Text(account.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if account.isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.purple)

            Text("CCSwitcher")
                .font(.title2.weight(.bold))

            Text("Claude Code Account Switcher")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Version 1.0.0")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            Text("Easily switch between Claude Code accounts and monitor usage.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func toggleLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLogin = !enable // revert on failure
        }
    }
}
