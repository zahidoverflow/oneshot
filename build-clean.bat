@echo off
echo ========================================
echo ONESHOT WiFi Pentester - Clean Build
echo ========================================

:: Kill any hanging processes
echo [1/6] Cleaning processes...
taskkill /f /im java.exe >nul 2>&1
taskkill /f /im gradle.exe >nul 2>&1

:: Clean directories
echo [2/6] Cleaning build directories...
if exist app\build (
    rmdir /s /q app\build
    echo   - Removed app\build
)
if exist .gradle (
    rmdir /s /q .gradle  
    echo   - Removed .gradle cache
)
if exist build (
    rmdir /s /q build
    echo   - Removed root build
)

:: Clean global Gradle cache if needed
echo [3/6] Checking Gradle user cache...
set GRADLE_USER_HOME=%USERPROFILE%\.gradle
if exist "%GRADLE_USER_HOME%\daemon" (
    echo   - Stopping Gradle daemons...
    gradlew --stop >nul 2>&1
)

:: Set minimal environment
echo [4/6] Setting build environment...
set GRADLE_OPTS=-Xmx1536m -Dfile.encoding=UTF-8
set JAVA_OPTS=-Xmx1536m

:: Attempt build with fallback strategies
echo [5/6] Building APK...
echo   Trying standard build...

:: Strategy 1: Standard build
call gradlew.bat clean assembleDebug --no-daemon --stacktrace >build_log.txt 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk (
    goto :success
)

:: Strategy 2: With info logging
echo   Trying with info logging...
call gradlew.bat assembleDebug --no-daemon --info --stacktrace >build_log.txt 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk (
    goto :success
)

:: Strategy 3: Offline mode (if dependencies cached)
echo   Trying offline mode...
call gradlew.bat assembleDebug --no-daemon --offline --stacktrace >build_log.txt 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk (
    goto :success
)

:: Build failed
echo [ERROR] Build failed. Check build_log.txt for details.
if exist build_log.txt (
    echo Last 20 lines of build log:
    powershell "Get-Content build_log.txt | Select-Object -Last 20"
)
goto :end

:success
echo [6/6] Build successful!
dir app\build\outputs\apk\debug\app-debug.apk
echo.
echo APK Location: app\build\outputs\apk\debug\app-debug.apk
echo APK Size:
for %%I in (app\build\outputs\apk\debug\app-debug.apk) do echo   %%~zI bytes

:end
echo ========================================
pause
