# Android build troubleshooting (Gradle metadata.bin errors)

If you see errors like:

- `Error resolving plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']`
- `Could not read workspace metadata from ...\.gradle\caches\8.14\transforms\...\metadata.bin`

this is usually caused by a corrupted local Gradle cache on your machine (not app business logic).

## Quick fix (Windows)

From repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\repair_android_gradle_cache.ps1
flutter clean
flutter pub get
flutter run
```

## Quick fix (macOS / Linux)

```bash
./scripts/repair_android_gradle_cache.sh
flutter clean
flutter pub get
flutter run
```

## Manual fallback

1. Stop Gradle daemons:
   - `gradle --stop`
   - `android\gradlew.bat --stop` (if `android/` exists)
2. Delete cache:
   - `%USERPROFILE%\.gradle\caches\*\transforms`
   - `%USERPROFILE%\.gradle\caches\jars-*`
   - `%USERPROFILE%\.gradle\caches\modules-2\files-2.1`
   - `%USERPROFILE%\.gradle\caches\modules-2\metadata-*`
3. Delete project temporary build data:
   - `<project>\build`
   - `<project>\android\.gradle`
4. Rebuild:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

## Why this works

`metadata.bin` read failures happen when Gradle transform or dependency cache entries are partially written, locked, or invalid. Clearing these cache folders forces Gradle to regenerate them on the next build.

## If it still fails

1. Reboot machine (ensures stale file handles are released).
2. Upgrade Flutter to stable latest and re-run `flutter doctor`.
3. Delete entire `%USERPROFILE%\.gradle\caches` folder as a final fallback.
