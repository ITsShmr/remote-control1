#!/bin/bash
set -e

PROJECT_NAME="RemoteControl"
echo "=== Step 1: Install xcodegen 2.40.0 ==="
curl -L https://github.com/yonaskolb/XcodeGen/releases/download/2.40.0/xcodegen.zip -o /tmp/xcodegen.zip 2>&1
unzip -o /tmp/xcodegen.zip -d /tmp/xcodegen-bin/ 2>&1
sudo cp /tmp/xcodegen-bin/xcodegen /usr/local/bin/xcodegen
chmod +x /usr/local/bin/xcodegen
xcodegen --version 2>&1

echo "=== Step 2: Generate Xcode project ==="
xcodegen generate --spec project.yml --project . 2>&1

echo "=== Step 3: Build app ==="
xcodebuild clean build \
  -project "$PROJECT_NAME.xcodeproj" \
  -scheme "$PROJECT_NAME" \
  -sdk iphoneos \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ONLY_ACTIVE_ARCH=NO 2>&1

echo "=== Step 4: Package IPA ==="
APP_PATH="build/Build/Products/Release-iphoneos/$PROJECT_NAME.app"
if [ -d "$APP_PATH" ]; then
  mkdir -p output/Payload
  cp -R "$APP_PATH" "output/Payload/"
  cd output
  zip -r "$PROJECT_NAME.ipa" Payload/
  mv "$PROJECT_NAME.ipa" ../
  echo "=== SUCCESS: IPA ready ==="
else
  echo "=== ERROR: App not found at $APP_PATH ==="
  find build -name "*.app" -type d 2>/dev/null || echo "No .app found"
  ls -la build/Build/Products/ 2>/dev/null || echo "No Products dir"
  exit 1
fi
