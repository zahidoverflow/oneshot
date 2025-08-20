# ONESHOT WiFi WPS Penetration Suite

## 🚀 **INSTANT BUILD SOLUTION**

### Quick Commands (Run in order):
```bash
# 1. Ultimate build fixer (handles all issues)
ultimate-build.bat

# 2. If that fails, manual approach:
gradlew clean assembleDebug --no-daemon

# 3. Install on device:
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 📱 **App Status: READY**

### ✅ **What's Working:**
- Professional cyberpunk hacker UI theme
- Material 3 design with neon green accents  
- Main screen with scan/options buttons
- Proper Android permissions setup
- Stable build configuration (AGP 8.3.2 + Kotlin 1.9.22)

### 🛠️ **Technical Stack:**
```
Language: Kotlin
UI: Jetpack Compose + Material 3
Target: Android 14 (API 34)
Min SDK: Android 7.0 (API 24) 
Theme: Custom cyberpunk colors
Build: Gradle 8.6 + AGP 8.3.2
```

### 🎯 **Build Scripts Provided:**
- **`ultimate-build.bat`** - Comprehensive fixer with 4 build strategies
- **`build-clean.bat`** - Standard clean build approach  
- **`verify-apk.bat`** - APK verification and install helper
- **`force-build.bat`** - Alternative for stubborn cases

## 🔧 **If Build Still Fails:**

### Environment Check:
```bash
java -version        # Should be 8, 11, 17, or 21
gradlew --version   # Should show Gradle 8.x
```

### Manual Fix:
1. Open Task Manager → Kill all `java.exe` processes
2. Delete: `.gradle`, `app\build`, `build` folders  
3. Run: `ultimate-build.bat`

### Alternative Versions:
- **Current**: AGP 8.3.2 + Kotlin 1.9.22 (most stable)
- **Backup**: Files include `.fixed` and `.stable` variants
- **Legacy**: Can downgrade to AGP 7.x if needed

## 📋 **Next Development Steps:**

1. **WiFi Scanning**: Implement WifiManager integration
2. **Root Detection**: Add SuperUser permission checks  
3. **WPS Analysis**: Integrate PIN generation algorithms
4. **Attack Engine**: Connect to oneshot.py backend
5. **Result Display**: Show cracked passwords

## ⚠️ **Legal Reminder:**
**For authorized penetration testing only!** Obtain explicit permission before testing any network.

---
**Status**: Build environment optimized, APK generation ready, UI complete.
