# ONESHOT WiFi WPS Penetration Suite

A professional Android application for WiFi WPS penetration testing with a cyberpunk hacker-themed UI.

## 🚀 Quick Start

### Prerequisites
- Android SDK with API level 34
- JDK 17 or 21 
- Windows/Linux/macOS

### Building the APK

#### Method 1: Automated Clean Build (Recommended)
```bash
# Run the automated build script
build-clean.bat
```

#### Method 2: Manual Build
```bash
# Clean previous builds
gradlew clean

# Build debug APK
gradlew assembleDebug --no-daemon
```

#### Method 3: Force Build (If hanging)
```bash
# Kill processes and force build
force-build.bat
```

### Installation
```bash
# Install on connected device
adb install app/build/outputs/apk/debug/app-debug.apk
```

## 📱 Features

### Current Implementation
- **Cyberpunk UI Theme**: Dark hacker aesthetic with neon colors
- **Material 3 Design**: Modern Android UI components
- **WiFi Scanner Interface**: Ready for network detection
- **Attack Workflow**: Structured penetration testing flow
- **Professional Layout**: Clean, functional design

### Planned Features
- **WiFi Network Scanning**: Detect available access points
- **WPS Vulnerability Detection**: Identify vulnerable networks
- **Automated Attacks**: PIN-based WPS cracking
- **Password Recovery**: Display cracked credentials
- **Advanced Options**: Custom attack parameters
- **Root Integration**: System-level WiFi manipulation

## 🛠️ Technical Details

### Architecture
- **Language**: Kotlin
- **UI Framework**: Jetpack Compose
- **Theme**: Material 3 with custom cyberpunk colors
- **Target SDK**: Android 14 (API 34)
- **Min SDK**: Android 7.0 (API 24)

### Build Configuration
- **AGP Version**: 8.5.2 (stable, compatible)
- **Kotlin Version**: 1.9.22
- **Compose BOM**: 2024.04.01
- **Memory Settings**: Optimized for 1.5GB heap

### Project Structure
```
app/
├── src/main/
│   ├── java/com/android/oneshot/
│   │   ├── MainActivity.kt           # Main application entry
│   │   └── ui/theme/
│   │       ├── Color.kt             # Cyberpunk color scheme
│   │       ├── Theme.kt             # Material 3 theme
│   │       └── Type.kt              # Typography definitions
│   ├── AndroidManifest.xml          # App permissions & config
│   └── res/                         # Resources
├── build.gradle.kts                 # Module build config
└── proguard-rules.pro              # Code obfuscation rules
```

## 🔧 Troubleshooting

### Build Issues
1. **Gradle Daemon Hanging**: Use `build-clean.bat` script
2. **Memory Errors**: Reduced to 1.5GB heap size
3. **JDK Compatibility**: Compatible with JDK 17-21
4. **Network Issues**: Use `--offline` flag if dependencies cached

### Common Errors
- **Missing APK**: Check `app/build/outputs/apk/debug/`
- **Build Timeout**: Kill Java processes and retry
- **SDK Not Found**: Verify `local.properties` has correct SDK path

### Log Analysis
```bash
# View build logs
type build_log.txt

# Check last 20 lines
powershell "Get-Content build_log.txt | Select-Object -Last 20"
```

## 📋 Development Status

### ✅ Completed
- [x] Project structure and build configuration
- [x] Material 3 theme with cyberpunk colors
- [x] Main activity with Compose UI
- [x] Automated build scripts
- [x] Error handling and logging

### 🔄 In Progress
- [ ] WiFi scanning implementation
- [ ] WPS vulnerability detection
- [ ] Attack execution engine

### 📅 Planned
- [ ] Root privilege management
- [ ] Network interface selection
- [ ] Attack result logging
- [ ] Export functionality

## ⚠️ Legal Notice

This application is intended for **authorized penetration testing only**. Users must:

- Obtain explicit permission before testing any network
- Comply with local laws and regulations
- Use only on networks you own or have permission to test
- Not use for unauthorized access or malicious purposes

**Disclaimer**: The developers are not responsible for misuse of this software.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## 📄 License

This project is for educational and authorized testing purposes only.
