@echo off
setlocal

echo [%TIME%] Starting build process...

:: Set environment
set GRADLE_OPTS=-Xmx2048m -Dfile.encoding=UTF-8

echo [%TIME%] Killing any existing Java processes...
taskkill /f /im java.exe >nul 2>&1

echo [%TIME%] Cleaning build directories...
if exist app\build rmdir /s /q app\build
if exist .gradle rmdir /s /q .gradle

echo [%TIME%] Starting Gradle build...
call gradlew.bat --no-daemon --info assembleDebug 2>&1 | findstr /C:"BUILD" /C:"ERROR" /C:"FAILED" /C:"APK" /C:"SUCCESS" /C:"FAILURE" /C:"Exception"

echo [%TIME%] Checking for APK output...
if exist app\build\outputs\apk\debug\app-debug.apk (
    echo SUCCESS: APK found at app\build\outputs\apk\debug\app-debug.apk
    dir app\build\outputs\apk\debug\app-debug.apk
) else (
    echo ERROR: APK not generated
    if exist app\build (
        echo Build directory exists, checking structure:
        dir app\build /s | findstr /C:"apk" /C:"outputs"
    ) else (
        echo Build directory was not created
    )
)

echo [%TIME%] Build process completed.
