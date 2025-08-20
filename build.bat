@echo off
echo Killing any existing Java processes...
taskkill /f /im java.exe >nul 2>&1

echo Cleaning build directories...
if exist .gradle rmdir /s /q .gradle
if exist app\build rmdir /s /q app\build

echo Starting build...
gradlew.bat clean assembleDebug --no-daemon --stacktrace

echo Checking for APK...
if exist app\build\outputs\apk\debug\app-debug.apk (
    echo SUCCESS: APK generated at app\build\outputs\apk\debug\app-debug.apk
) else (
    echo ERROR: APK not found
    if exist app\build\outputs (
        dir app\build\outputs /s
    ) else (
        echo Build outputs directory not created
    )
)
