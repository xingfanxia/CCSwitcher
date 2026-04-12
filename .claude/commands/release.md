Release a new version of CCSwitcher. This ensures the version is synced everywhere: `MARKETING_VERSION` in project.yml, git tag, and the commit message.

## Instructions

When the user invokes `/release`, follow these steps EXACTLY. Do NOT skip or improvise.

### 1. Pre-flight checks

- Verify you're on the `main` branch
- Verify working tree is clean (no uncommitted changes)
- If there ARE uncommitted changes, ask the user whether to commit them first

### 2. Determine version

- Read the current `MARKETING_VERSION` from `project.yml`
- Ask the user what the new version should be, or accept it as an argument (e.g., `/release 1.3.0` or `/release patch`)
- `patch`: bump 1.2.3 → 1.2.4
- `minor`: bump 1.2.3 → 1.3.0
- `major`: bump 1.2.3 → 2.0.0

### 3. Run the release script

Run `./scripts/release.sh <version>` which handles everything:
- Updates `MARKETING_VERSION` in project.yml (all occurrences)
- Increments `CURRENT_PROJECT_VERSION` (build number)
- Runs `xcodegen generate`
- Commits with message: `chore: Bump to X.Y.Z (build N)`
- Creates git tag `vX.Y.Z`
- Pushes the commit to `main`
- Pushes ONLY the specific tag (never `git push --tags`)

### Critical rules

- **NEVER use `git push --tags`** — it pushes ALL local tags including stale ones. Always push the specific tag: `git push origin vX.Y.Z`
- **MARKETING_VERSION must match the git tag** — if the tag is `v1.3.0`, MARKETING_VERSION must be `"1.3.0"`. They are the same value. No exceptions.
- **Verify before pushing** — check that the tag doesn't already exist locally or on remote before creating it
