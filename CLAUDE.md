# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter example project demonstrating `FlutterCallbackCache` functionality with iOS notification service extensions. The project tests callback handle persistence and retrieval between the main Flutter app and notification service extensions, specifically testing custom Flutter engine builds.

## Development Setup

- **Flutter Version**: Uses FVM (Flutter Version Manager) with version 3.35.4 specified in `.fvmrc`
- **Language**: Dart SDK ^3.5.3
- **Platform Focus**: iOS (with minimal Android implementation)

## Common Commands

```bash
# Run the app
flutter run

# Build for iOS
flutter build ios

# Run tests
flutter test

# Get dependencies
flutter pub get

# Lint
flutter analyze
```

## Architecture

### Core Callback Cache Flow

The app demonstrates a specific pattern for preserving Dart callback handles across process boundaries:

1. **Main App (lib/main.dart)**:
   - `initNotificationPreSync()` obtains a callback handle for the `dispatcher()` function using `PluginUtilities.getCallbackHandle()`
   - Sends the raw handle to native iOS via method channel `nz.co.resolution.flutterCallbackCacheExample/flutterCallbackCacheExampleForegroundChannel`

2. **iOS App Delegate (ios/Runner/AppDelegate.swift)**:
   - Receives callback handle via foreground method channel
   - Stores handle in shared UserDefaults suite `group.resolution.callbackCacheExample` using `UserDefaultsHelper`

3. **Notification Service Extension (ios/NotificationServiceExtension/NotificationService.swift)**:
   - Retrieves callback handle from shared UserDefaults
   - Attempts to look up callback information using `FlutterCallbackCache.lookupCallbackInformation()`
   - This tests whether callbacks registered in the main app are accessible in app extensions

### Key iOS Components

- **App Groups**: Uses `group.resolution.callbackCacheExample` for sharing data between main app and extension
- **Notification Service Extension**: A separate target that processes push notifications before display
- **Custom Bridging Header**: `InternalFlutterSwift-Bridging-Header.h` provides access to internal Flutter framework headers

### Platform Channels

- **Channel Name**: `nz.co.resolution.flutterCallbackCacheExample/flutterCallbackCacheExampleForegroundChannel`
- **Methods**:
  - `initialize`: Receives and stores callback handle from Dart

## iOS-Specific Details

- Project uses App Groups capability for data sharing between targets
- The NotificationServiceExtension is a separate app extension target embedded in the main app
- Remote notifications are registered on app launch
- UserDefaults suite name must match the App Group identifier

## Custom Flutter Engine

Recent commits suggest this project may be using a custom Flutter engine build (commit: "working config with custom engine"). The custom bridging header and specialized callback cache testing indicate potential engine modifications or testing of unreleased engine features.
