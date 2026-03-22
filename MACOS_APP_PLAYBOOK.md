# Modern macOS App Development Playbook

This document is a synthesized master guide based on the successful development, architecture, and deployment of **CCSwitcher**. It serves as a blueprint for bootstrapping any fresh, production-ready native macOS application in the future.

---

## 1. Project Management: The "Single Source of Truth"

Never manually create or modify an Xcode project file (`.xcodeproj`). It leads to Git merge conflicts and fragile configurations. 

- **Tool**: Use [XcodeGen](https://github.com/yonaskolb/XcodeGen).
- **Setup**: Define your entire project structure, targets, and build settings in a `project.yml` file at the root.
- **Info.plist**: Do **not** keep a static, hardcoded `Info.plist` file. Let XcodeGen generate it dynamically. Map dynamic variables like `$(MARKETING_VERSION)` directly from the YAML.
- **Git**: Add `*.xcodeproj/` to your `.gitignore`. 
- **Workflow**: Anyone cloning the repo simply runs `xcodegen generate` to instantly build a pristine, localized Xcode environment.

## 2. UI & Architecture (SwiftUI + AppKit)

Build native, lightweight interfaces using modern SwiftUI, falling back to AppKit only when necessary.

- **Menubar Apps**: If building a menubar-only app, define `LSUIElement: true` in your `project.yml` properties to hide the Dock icon. Use `MenuBarExtra` with `.menuBarExtraStyle(.window)` for native popovers.
- **Settings**: Utilize SwiftUI's native `Settings { ... }` scene for a standard macOS preferences window.
- **Concurrency**: Embrace Swift 6 strict concurrency. Use `@MainActor` for ViewModels (`ObservableObject`) and mark background services as `Sendable`.
- **Launch at Login**: Use macOS 13+ `ServiceManagement.SMAppService.mainApp.register()` instead of legacy helper apps.

## 3. Security & Data Storage

Never store sensitive user data (tokens, API keys, personal emails) in plain text files (e.g., `~/.myapp.json`).

- **Keychain**: Use the macOS `Security` framework (`SecItemAdd`, `SecItemUpdate`, `SecItemCopyMatching`).
- **Access Control**: Because your app is signed with an Apple Developer Certificate, macOS automatically grants it seamless, silent access to its own Keychain items without prompting the user for passwords.
- **Preferences**: Use `@AppStorage` (UserDefaults) strictly for non-sensitive UI states (e.g., window sizes, refresh intervals, toggle states).

## 4. Automation & CI/CD (GitHub Actions)

Do not rely on local, manual archiving for releases. Automate the entire process to ensure pristine build environments.

- **Environment**: Use `macos-14` runners and explicitly set the Xcode version using actions like `maxim-lobanov/setup-xcode@v1` to avoid compatibility issues.
- **Dependencies**: Install tools via Homebrew (`brew install xcodegen create-dmg`) inside the pipeline.
- **Unsigned Build First**: Run `xcodebuild` with `CODE_SIGN_IDENTITY=""` to bypass Xcode's strict local provisioning profile checks in the cloud.
- **Manual Codesign**: Use the `codesign` CLI tool post-build to inject the `Developer ID Application` certificate and entitlements (vital for the Hardened Runtime).

## 5. Packaging & Distribution

macOS users expect apps to be delivered as `.dmg` files, perfectly signed and free of "Developer cannot be verified" warnings.

- **Certificates**: Store your `.p12` certificate as a Base64 string in GitHub Secrets. Create a temporary Keychain in the Actions runner to import it.
- **DMG Creation**: Use the `create-dmg` CLI tool to package the `.app` into a DMG with a native "Drag to Applications" visual layout.
- **Notarization**: Upload the signed DMG to Apple using `xcrun notarytool submit` (requires App-Specific Password).
- **Stapling**: Run `xcrun stapler staple` on the DMG so the app can verify its safety offline.
- **GitHub Releases**: Use `softprops/action-gh-release` tied to `tags: ['v*']` to automatically attach the finalized `.dmg` to a GitHub Release.

## 6. In-App Auto Updates

Don't rely on third-party backend servers if you don't have to. You can build a completely free, highly reliable auto-update system using GitHub.

- **The Source**: Query the GitHub API (`https://api.github.com/repos/{owner}/{repo}/releases/latest`).
- **The Logic**: Compare the remote `tag_name` (e.g., `1.0.2`) against the local `Bundle.main.infoDictionary?["CFBundleShortVersionString"]`.
- **The UI**: If a newer version exists, trigger a native `NSAlert`. If the user clicks "Download", use `NSWorkspace.shared.open()` to direct them straight to the GitHub Release `.dmg` asset.
- **Triggers**: Run the check silently via `.onAppear` when the app launches, and provide a manual "Check for Updates" button in the Settings -> About tab.

## 7. Aesthetics & Polish

A native macOS app must look the part.

- **Icon**: macOS icons (since Big Sur) must be squircles. They should not fill the entire 1024x1024 canvas. Scale the core squircle to ~824x824, center it, and add a soft drop shadow. 
- **Assets**: Use a script to automatically generate all required resolutions (`16x16` up to `1024x1024` in `1x` and `2x` scales) and their corresponding `Contents.json` to form a valid `.appiconset`.
- **Integration**: Ensure `project.yml` specifies `ASSETCATALOG_COMPILER_APPICON_NAME` and does not accidentally exclude the `Resources/` directory from compilation.

---
*Generated by Gemini CLI after the successful creation of CCSwitcher.*