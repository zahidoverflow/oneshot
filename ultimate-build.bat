@echo off
setlocal EnableDelayedExpansion

echo ==========================================
echo ONESHOT - ULTIMATE BUILD FIXER
echo ==========================================

:: Step 1: Process cleanup
echo [1/7] Terminating all processes...
taskkill /f /im java.exe >nul 2>&1
taskkill /f /im gradle.exe >nul 2>&1
taskkill /f /im gradlew.exe >nul 2>&1
timeout /t 2 >nul

:: Step 2: Directory cleanup
echo [2/7] Deep cleaning directories...
for /d %%d in (app\build .gradle build .idea) do (
    if exist "%%d" (
        echo   Removing %%d...
        rmdir /s /q "%%d" 2>nul
    )
)

:: Step 3: Use stable configuration
echo [3/7] Applying stable build configuration...
if exist "gradle\libs.versions.toml.stable" (
    copy /y "gradle\libs.versions.toml.stable" "gradle\libs.versions.toml" >nul
    echo   Applied stable version catalog
)
if exist "app\build.gradle.kts.fixed" (
    copy /y "app\build.gradle.kts.fixed" "app\build.gradle.kts" >nul
    echo   Applied stable build script
)

:: Step 4: Gradle wrapper refresh
echo [4/7] Refreshing Gradle wrapper...
if exist gradlew.bat (
    gradlew.bat wrapper --gradle-version=8.6 --no-daemon >nul 2>&1
    echo   Gradle wrapper updated
)

:: Step 5: Environment setup
echo [5/7] Setting optimal environment...
set GRADLE_OPTS=-Xmx1024m -Dfile.encoding=UTF-8 -Dorg.gradle.daemon=false
set JAVA_OPTS=-Xmx1024m
set GRADLE_USER_HOME=%USERPROFILE%\.gradle

:: Step 6: Progressive build attempts
echo [6/7] Attempting build with multiple strategies...

:: Attempt 1: Clean + Build
echo   Strategy 1: Standard clean build
gradlew.bat clean assembleDebug --no-daemon --info --stacktrace >ultimate_build.log 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk goto :success

:: Attempt 2: Refresh dependencies
echo   Strategy 2: Refresh dependencies
gradlew.bat clean assembleDebug --refresh-dependencies --no-daemon >ultimate_build.log 2>&1  
if exist app\build\outputs\apk\debug\app-debug.apk goto :success

:: Attempt 3: Force no-cache
echo   Strategy 3: No cache build
gradlew.bat clean assembleDebug --no-build-cache --no-daemon >ultimate_build.log 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk goto :success

:: Attempt 4: Minimal flags
echo   Strategy 4: Minimal build
gradlew.bat assembleDebug >ultimate_build.log 2>&1
if exist app\build\outputs\apk\debug\app-debug.apk goto :success

goto :failure

:success
echo [7/7] BUILD SUCCESSFUL! 
echo.
echo ==========================================
dir app\build\outputs\apk\debug\app-debug.apk
echo ==========================================
echo.
echo APK Location: app\build\outputs\apk\debug\app-debug.apk
for %%I in (app\build\outputs\apk\debug\app-debug.apk) do (
    echo APK Size: %%~zI bytes ^(%.1f MB^)
)
echo.
echo Install command: adb install app\build\outputs\apk\debug\app-debug.apk
echo.
goto :end

:failure
echo [7/7] BUILD FAILED
echo.
echo Diagnostics:
if exist ultimate_build.log (
    echo Last 10 lines of build log:
    powershell "Get-Content ultimate_build.log | Select-Object -Last 10"
) else (
    echo No build log generated
)
echo.
echo Troubleshooting:
echo 1. Check Java version: java -version
echo 2. Check Android SDK path in local.properties
echo 3. Try: gradlew clean assembleDebug --scan
echo.

:end
echo ==========================================
pause
