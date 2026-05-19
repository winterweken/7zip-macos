# Project Roadmap & TODO

## 🚀 CI/CD & Automation

- [ ] **GitHub Actions Workflow**
  - Create a verified build pipeline for macOS (x86_64 & arm64).
  - Automate running the `./test.sh` suite on every PR/push.
  - Publish build artifacts automatically on release tags.

## 📦 Distribution

- [ ] **Homebrew Support**
  - Homebrew formula scaffold added in `Formula/7zip-macos.rb`.
  - Create and publish a custom tap repository so users can install with `brew install <tap>/7zip-macos`.
  - Submit to Homebrew-core (long term goal, optional).
- [ ] **Universal Binaries (Fat Binaries)**
  - Update `build.sh` to support creating universal binaries using `lipo`.
  - Allow users to choose between thin (arch-specific) or fat (universal) binaries.
- [ ] **Code Signing**
  - Sign binaries with a developer certificate to prevent macOS Gatekeeper warnings.
  - Notarize binaries for distribution outside of Homebrew.

## 🛠 Engineering & Maintenance

- [ ] **Upstream Synchronization**
  - Create a script to check `7-zip.org` for new source releases.
  - Automate the process of updating the `SEVEN_ZIP_VERSION` in `download-source.sh`.
- [ ] **Patch Management**
  - Refine the patching system (currently `sed`-based in `download-source.sh`) to support multiple patch files if more modifications become necessary.
  - Document strict compiler flags that cause issues (e.g., `-Wswitch-default`).

## 📚 Documentation

- [ ] **Man Pages**
  - Generate manual pages for `7zz` based on the help output.
- [ ] **Performance Benchmarks**
  - Compare compression speeds against system `zip` and `tar` on Apple Silicon.
