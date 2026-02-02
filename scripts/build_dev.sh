#!/bin/bash

echo "🔧 Building Pause it DEV..."
echo ""

# Android
echo "📱 Building Android APK (dev)..."
flutter build apk --release --flavor dev -t lib/main_dev.dart

if [ $? -eq 0 ]; then
  echo "✅ Android APK build complete!"
  echo "   Output: build/app/outputs/flutter-apk/app-dev-release.apk"
else
  echo "❌ Android APK build failed!"
  exit 1
fi

echo ""

# iOS (macOS에서만)
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍎 Building iOS (dev)..."
  flutter build ios --release --flavor dev -t lib/main_dev.dart --no-codesign

  if [ $? -eq 0 ]; then
    echo "✅ iOS build complete!"
    echo "   Output: build/ios/iphoneos/Runner.app"
  else
    echo "❌ iOS build failed!"
    exit 1
  fi
else
  echo "⏭️  Skipping iOS build (not on macOS)"
fi

echo ""
echo "🎉 Build complete!"
