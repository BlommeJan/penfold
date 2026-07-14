# Building release APKs

Penfold targets **Android** first. Release builds produce an APK you can sideload or distribute via GitHub Releases.

## Prerequisites

- Flutter SDK 3.x with Android toolchain configured
- See [CONTRIBUTING.md](CONTRIBUTING.md) for full development setup

## Build commands

```bash
# arm64 only (recommended for modern phones/tablets)
flutter build apk --release --target-platform android-arm64

# universal APK (all ABIs)
flutter build apk --release
```

Flutter writes the artifact to:

```
build/app/outputs/flutter-apk/app-release.apk
```

For the lowest drawing latency on a physical device, prefer a **`--release`** build over debug.

## APKs/ folder convention

After each release build, copy and rename the APK into **`APKs/`** at the project root. Use the version from `pubspec.yaml`:

```powershell
# Windows (PowerShell)
New-Item -ItemType Directory -Path APKs -Force
Copy-Item build/app/outputs/flutter-apk/app-release.apk APKs/Penfold-v0.2.4-arm64.apk
```

```bash
# Linux / macOS
mkdir -p APKs
cp build/app/outputs/flutter-apk/app-release.apk "APKs/Penfold-v$(grep '^version:' pubspec.yaml | awk '{print $2}')-arm64.apk"
```

**Deliverables:** release APKs live in `APKs/` — e.g. `APKs/Penfold-v0.2.4-arm64.apk`. Do not leave `.apk` files in the project root.

Pre-built releases are also published on [GitHub Releases](https://github.com/BlommeJan/penfold/releases).
