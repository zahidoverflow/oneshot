@echo off
echo ==========================================
echo ONESHOT APK Verification
echo ==========================================

:check_loop
if exist app\build\outputs\apk\debug\app-debug.apk (
    echo SUCCESS: APK Found!
    echo.
    echo File: app\build\outputs\apk\debug\app-debug.apk
    dir app\build\outputs\apk\debug\app-debug.apk
    echo.
    for %%I in (app\build\outputs\apk\debug\app-debug.apk) do (
        echo Size: %%~zI bytes
        echo Modified: %%~tI
    )
    echo.
    echo To install on device:
    echo adb install app\build\outputs\apk\debug\app-debug.apk
    goto :end
)

if exist app\build (
    echo Build directory exists, checking outputs...
    if exist app\build\outputs (
        dir app\build\outputs /s | findstr "apk"
    ) else (
        echo Outputs directory not yet created
    )
) else (
    echo Build not started or cleaned
)

echo Waiting 10 seconds...
timeout /t 10 >nul
goto :check_loop

:end
pause
