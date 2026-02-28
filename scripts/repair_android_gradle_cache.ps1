param(
  [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = 'Stop'

Write-Host "Project root: $ProjectRoot"

# 1) Stop Gradle daemons to release cache locks.
Write-Host "Stopping Gradle daemons..."
try {
  & gradle --stop | Out-Null
} catch {
  Write-Host "gradle not found globally. Continuing..."
}

if (Test-Path (Join-Path $ProjectRoot "android/gradlew.bat")) {
  Push-Location (Join-Path $ProjectRoot "android")
  try {
    & .\gradlew.bat --stop | Out-Null
  } catch {
    Write-Host "android/gradlew.bat --stop failed or unavailable. Continuing..."
  }
  Pop-Location
}

# 2) Remove corrupted transform metadata cache.
$gradleUserHome = if ($env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME } else { Join-Path $env:USERPROFILE ".gradle" }
$transformsPath = Join-Path $gradleUserHome "caches\8.14\transforms"

if (Test-Path $transformsPath) {
  Write-Host "Deleting Gradle transforms cache at: $transformsPath"
  Remove-Item -Path $transformsPath -Recurse -Force
} else {
  Write-Host "Transforms path not found ($transformsPath). Skipping delete."
}

# 3) Clear project build outputs.
$buildDir = Join-Path $ProjectRoot "build"
if (Test-Path $buildDir) {
  Write-Host "Removing project build directory: $buildDir"
  Remove-Item -Path $buildDir -Recurse -Force
}

$androidBuildDir = Join-Path $ProjectRoot "android\.gradle"
if (Test-Path $androidBuildDir) {
  Write-Host "Removing android local Gradle dir: $androidBuildDir"
  Remove-Item -Path $androidBuildDir -Recurse -Force
}

Write-Host "Done. Next steps:"
Write-Host "  1) flutter clean"
Write-Host "  2) flutter pub get"
Write-Host "  3) flutter run"
