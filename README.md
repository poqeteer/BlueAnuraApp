# blue_anura

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Build

Run 

    flutter get

Add to ./ios/Runner/Info.plist

    <key>CFBundleName</key>
    <string>Blue Aura</string>

    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to location when open.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app needs access to location when in the background.</string>

And this to ./android/app/src/main/AndroidManifest.xml

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <application
        android:label="Blue Anura"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">

For now cloned the gallery_saver to fix bug in ./lib/views/camera/widgets/gallery_saver/android/src/main/kotlin/carnegietechnologies/gallery_saver/FileUtils.kt lines 272 and 275, add .toString()

Update the icon see comments in pubspec.yaml