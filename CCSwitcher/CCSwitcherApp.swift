import SwiftUI

@main
struct CCSwitcherApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MainMenuView()
                .environmentObject(appState)
        } label: {
            menuBarLabel
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }

    private var menuBarLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "brain.head.profile")
            if let account = appState.activeAccount {
                Text(account.displayName)
                    .font(.caption)
            }
        }
    }
}
