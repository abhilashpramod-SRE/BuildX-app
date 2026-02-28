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
$allTransformsPaths = @(
  Get-ChildItem -Path (Join-Path $gradleUserHome "caches") -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName "transforms" }
)

if ($allTransformsPaths.Count -gt 0) {
  foreach ($transformsPath in $allTransformsPaths) {
    if (Test-Path $transformsPath) {
      Write-Host "Deleting Gradle transforms cache at: $transformsPath"
      Remove-Item -Path $transformsPath -Recurse -Force
    }
  }
} else {
  Write-Host "No Gradle transforms cache folders found under $gradleUserHome\caches"
}

# 2b) Remove plugin-resolution caches that frequently retain stale metadata.
$pluginResolutionDirs = @(
  (Join-Path $gradleUserHome "caches\jars-9"),
  (Join-Path $gradleUserHome "caches\modules-2\files-2.1"),
  (Join-Path $gradleUserHome "caches\modules-2\metadata-2.107")
)

foreach ($dir in $pluginResolutionDirs) {
  if (Test-Path $dir) {
    Write-Host "Deleting Gradle dependency cache at: $dir"
    Remove-Item -Path $dir -Recurse -Force
  }
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

# 4) Last resort for persistent lock/corruption: stop Java processes holding cache handles.
Write-Host "Attempting to stop lingering Java/Gradle processes..."
Get-Process -Name java, javaw, gradle -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Done. Next steps:"
Write-Host "  1) flutter clean"
Write-Host "  2) flutter pub get"
Write-Host "  3) flutter run"
