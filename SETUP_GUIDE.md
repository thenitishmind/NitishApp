# Flutter Portfolio - Complete Setup Guide

This guide will walk you through setting up and running the Flutter portfolio application from scratch.

## 🛠️ Prerequisites

### 1. Install Flutter SDK

**Windows:**
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract to `C:\flutter` (or your preferred location)
3. Add Flutter to PATH:
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\flutter\bin` to PATH variable
4. Verify installation:
   ```cmd
   flutter doctor
   ```

**macOS:**
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually from flutter.dev
# Then add to PATH in ~/.zshrc or ~/.bash_profile:
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter doctor
```

**Linux:**
```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz

# Extract
tar xf flutter_linux_3.16.0-stable.tar.xz

# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Install Development Tools

**Android Studio (Recommended):**
1. Download from [developer.android.com](https://developer.android.com/studio)
2. Install with Android SDK
3. Install Flutter and Dart plugins
4. Run `flutter doctor` to verify Android setup

**VS Code (Alternative):**
1. Install VS Code
2. Install Flutter extension
3. Install Dart extension
4. Install Android SDK separately if needed

### 3. Platform-Specific Setup

**For Android Development:**
- Install Android Studio
- Install Android SDK (API 21+ required)
- Create Android Virtual Device (AVD) or connect physical device
- Enable Developer Options and USB Debugging on physical device

**For iOS Development (macOS only):**
```bash
# Install Xcode from App Store
# Install CocoaPods
sudo gem install cocoapods

# Accept Xcode license
sudo xcodebuild -license accept
```

**For Web Development:**
```bash
# Enable web support
flutter config --enable-web

# Verify web support
flutter devices
```

## 📋 Step-by-Step Setup

### Step 1: Clone and Setup Project

```bash
# 1. Navigate to your desired directory
cd /path/to/your/projects

# 2. Create the Flutter project
flutter create flutter_portfolio
cd flutter_portfolio

# 3. Replace the generated files with provided code
# Copy all files from the provided code structure

# 4. Install dependencies
flutter pub get
```

### Step 2: Verify Flutter Installation

```bash
# Run Flutter doctor to check setup
flutter doctor

# Expected output should show:
✓ Flutter (Channel stable, 3.16.0)
✓ Android toolchain - develop for Android devices
✓ Chrome - develop for the web  
✓ Android Studio (version 2023.1)
✓ VS Code (version 1.84)
✓ Connected device (3 available)
✓ Network resources
```

### Step 3: Configure Dependencies

Make sure your `pubspec.yaml` includes all required dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_animate: ^4.2.0
  lottie: ^2.7.0
  shimmer: ^3.0.0
  go_router: ^12.1.3
  provider: ^6.1.1
  http: ^1.1.0
  dio: ^5.3.4
  shared_preferences: ^2.2.2
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  url_launcher: ^6.2.1
  flutter_staggered_grid_view: ^0.7.0
  google_fonts: ^6.1.0
```

Then run:
```bash
flutter pub get
```

### Step 4: Run the Application

```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run on specific device
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios          # iOS (macOS only)

# Run in release mode for better performance
flutter run --release
```

## 🚀 Platform-Specific Instructions

### Running on Android

1. **Enable Developer Mode:**
   - Go to Settings → About Phone
   - Tap "Build number" 7 times
   - Go to Developer Options → Enable USB Debugging

2. **Connect Device:**
   ```bash
   # Check if device is connected
   flutter devices
   
   # Run on Android
   flutter run -d android
   ```

3. **Using Emulator:**
   - Open Android Studio → AVD Manager
   - Create Virtual Device
   - Select device and API level
   - Start emulator and run app

### Running on iOS (macOS only)

1. **Setup Xcode:**
   ```bash
   # Open iOS Simulator
   open -a Simulator
   
   # Run on iOS Simulator
   flutter run -d ios
   ```

2. **For Physical Device:**
   - Connect iPhone/iPad
   - Trust the computer
   - Run: `flutter run -d ios`

### Running on Web

1. **Enable Web Support:**
   ```bash
   flutter config --enable-web
   ```

2. **Run Web Application:**
   ```bash
   # Development server
   flutter run -d chrome
   
   # Build for production
   flutter build web
   
   # Serve built files
   cd build/web
   python -m http.server 8000
   ```

### Running on Desktop

**Windows:**
```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Run on Windows
flutter run -d windows
```

**macOS:**
```bash
# Enable macOS desktop
flutter config --enable-macos-desktop

# Run on macOS
flutter run -d macos
```

**Linux:**
```bash
# Enable Linux desktop
flutter config --enable-linux-desktop

# Install required packages (Ubuntu/Debian)
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# Run on Linux
flutter run -d linux
```

## 🔧 Configuration Options

### GitHub Integration

Update the GitHub configuration in `lib/core/config/github_config.dart`:

```dart
class GitHubConfig {
  /// Your GitHub username
  static const String username = 'your-github-username';
  
  /// Optional: GitHub Personal Access Token for higher rate limits
  /// Generate at: https://github.com/settings/tokens
  /// Required scopes: public_repo, read:user
  static const String? token = 'your_token_here'; // or null
}
```

**Benefits of adding a GitHub token:**
- Increases rate limit from 60 to 5000 requests/hour
- More reliable data fetching
- Faster app performance

**To generate a token:**
1. Go to [GitHub Token Settings](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes: `public_repo` and `read:user`
4. Copy the token and update the config file

### Custom Branding

1. **App Name and Icon:**
   ```yaml
   # pubspec.yaml
   name: your_portfolio_name
   description: Your custom description
   ```

2. **Colors and Theme:**
   Update `lib/core/theme/app_theme.dart` with your color preferences.

3. **Personal Information:**
   Update personal details in relevant screens and components.

## 🐛 Troubleshooting

### Common Issues and Solutions

1. **"flutter: command not found"**
   ```bash
   # Add Flutter to PATH
   export PATH="$PATH:/path/to/flutter/bin"
   source ~/.bashrc  # or ~/.zshrc
   ```

2. **Android License Issues:**
   ```bash
   flutter doctor --android-licenses
   # Accept all licenses
   ```

3. **Gradle Build Failures:**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

4. **iOS Build Issues:**
   ```bash
   cd ios
   rm Podfile.lock
   rm -rf Pods
   pod install
   cd ..
   flutter run
   ```

5. **Web Build Issues:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome --web-renderer html
   ```

### Performance Issues

1. **Slow Debug Performance:**
   ```bash
   # Always use release mode for performance testing
   flutter run --release
   ```

2. **Large Bundle Size:**
   ```bash
   # Analyze bundle size
   flutter build apk --analyze-size
   
   # Use app bundle for smaller downloads
   flutter build appbundle
   ```

### Environment Specific Issues

**Windows:**
- Ensure Windows 10 SDK is installed
- Run PowerShell as Administrator if needed
- Check antivirus isn't blocking Flutter

**macOS:**
- Update Xcode to latest version
- Install Xcode command line tools: `xcode-select --install`
- Grant necessary permissions in System Preferences

**Linux:**
- Install missing dependencies: `sudo apt-get install curl git unzip xz-utils zip libglu1-mesa`
- Ensure snap is not interfering with Flutter

## 📊 Development Workflow

### Recommended Development Setup

1. **Hot Reload for Fast Development:**
   ```bash
   flutter run
   # Press 'r' for hot reload
   # Press 'R' for hot restart
   ```

2. **Debugging:**
   ```bash
   # Run with debugging
   flutter run --debug
   
   # Profile mode for performance testing
   flutter run --profile
   ```

3. **Testing:**
   ```bash
   # Run all tests
   flutter test
   
   # Run with coverage
   flutter test --coverage
   ```

4. **Code Analysis:**
   ```bash
   # Analyze code
   flutter analyze
   
   # Format code
   flutter format .
   ```

## 🚀 Deployment

### Building Release Versions

**Android:**
```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

**iOS:**
```bash
# Build iOS app
flutter build ios --release

# Create IPA file
flutter build ipa
```

**Web:**
```bash
# Build web app
flutter build web --release

# Deploy to hosting service
# Copy build/web/* to your web server
```

**Desktop:**
```bash
# Build for current platform
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

This setup guide should get your Flutter portfolio app running smoothly across all platforms! 🎉