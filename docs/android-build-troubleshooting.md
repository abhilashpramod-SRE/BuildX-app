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

## Manual fallback

1. Stop Gradle daemons:
   - `gradle --stop`
   - `android\gradlew.bat --stop` (if `android/` exists)
2. Delete cache:
   - `%USERPROFILE%\.gradle\caches\8.14\transforms`
3. Delete project temporary build data:
   - `<project>\build`
   - `<project>\android\.gradle`
4. Rebuild:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

## Why this works

`metadata.bin` read failures happen when Gradle transform cache entries are partially written or invalid. Clearing just the corrupted transform cache forces Gradle to regenerate it on the next build.
