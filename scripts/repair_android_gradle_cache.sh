#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

echo "Project root: $PROJECT_ROOT"

echo "Stopping Gradle daemons..."
gradle --stop >/dev/null 2>&1 || true
if [[ -x "$PROJECT_ROOT/android/gradlew" ]]; then
  (cd "$PROJECT_ROOT/android" && ./gradlew --stop >/dev/null 2>&1 || true)
fi

echo "Clearing Gradle transforms caches..."
if [[ -d "$GRADLE_USER_HOME/caches" ]]; then
  find "$GRADLE_USER_HOME/caches" -maxdepth 2 -type d -name transforms -print -exec rm -rf {} + || true
fi

echo "Clearing Gradle dependency caches that can retain stale metadata..."
rm -rf "$GRADLE_USER_HOME/caches"/jars-* || true
rm -rf "$GRADLE_USER_HOME/caches/modules-2/files-2.1" || true
rm -rf "$GRADLE_USER_HOME/caches"/modules-2/metadata-* || true

echo "Removing local project caches..."
rm -rf "$PROJECT_ROOT/build" || true
rm -rf "$PROJECT_ROOT/android/.gradle" || true

echo "Stopping lingering Java/Gradle processes..."
pkill -f 'GradleDaemon|org.gradle.launcher|java' >/dev/null 2>&1 || true

echo "Done. Next steps:"
echo "  1) flutter clean"
echo "  2) flutter pub get"
echo "  3) flutter run"
