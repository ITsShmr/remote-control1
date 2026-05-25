#!/bin/bash
PROJECT_NAME="RemoteControl"
BUNDLE_ID="com.remotecontrol.ios"

echo "=== Step 1: Creating Xcode project structure ==="
mkdir -p "$PROJECT_NAME.xcodeproj"

cat > "$PROJECT_NAME.xcodeproj/project.pbxproj" << 'ENDXCODE'
// !$*UTF8*$!
{
  archiveVersion = 1;
  classes = {};
  objectVersion = 56;
  objects = {
/* Begin PBXBuildFile section */
111111111111111111111111 /* RemoteControlApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222222; };
111111111111111111111112 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222223; };
111111111111111111111113 /* ConnectionView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222224; };
111111111111111111111114 /* StreamView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222225; };
111111111111111111111115 /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222226; };
111111111111111111111116 /* ConnectionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222227; };
111111111111111111111117 /* StreamManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222228; };
111111111111111111111118 /* CursorController.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222229; };
111111111111111111111119 /* PacketTypes.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222230; };
111111111111111111111120 /* ServerTransport.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222231; };
111111111111111111111121 /* BluetoothTransport.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222232; };
111111111111111111111122 /* ScreenCaptureService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222233; };
111111111111111111111123 /* TouchSimulator.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222234; };
111111111111111111111124 /* EventProcessor.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222235; };
111111111111111111111125 /* Data+Extensions.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222236; };
111111111111111111111126 /* UIImage+Extensions.swift in Sources */ = {isa = PBXBuildFile; fileRef = 222222222222222222222237; };
/* End PBXBuildFile section */
/* Begin PBXFileReference section */
222222222222222222222222 /* RemoteControlApp.swift */ = {isa = PBXFileReference; path = App/RemoteControlApp.swift; sourceTree = "<group>"; };
222222222222222222222223 /* ContentView.swift */ = {isa = PBXFileReference; path = UI/ContentView.swift; sourceTree = "<group>"; };
222222222222222222222224 /* ConnectionView.swift */ = {isa = PBXFileReference; path = UI/ConnectionView.swift; sourceTree = "<group>"; };
222222222222222222222225 /* StreamView.swift */ = {isa = PBXFileReference; path = UI/StreamView.swift; sourceTree = "<group>"; };
222222222222222222222226 /* SettingsView.swift */ = {isa = PBXFileReference; path = UI/SettingsView.swift; sourceTree = "<group>"; };
222222222222222222222227 /* ConnectionManager.swift */ = {isa = PBXFileReference; path = Core/ConnectionManager.swift; sourceTree = "<group>"; };
222222222222222222222228 /* StreamManager.swift */ = {isa = PBXFileReference; path = Core/StreamManager.swift; sourceTree = "<group>"; };
222222222222222222222229 /* CursorController.swift */ = {isa = PBXFileReference; path = Core/CursorController.swift; sourceTree = "<group>"; };
222222222222222222222230 /* PacketTypes.swift */ = {isa = PBXFileReference; path = Networking/PacketTypes.swift; sourceTree = "<group>"; };
222222222222222222222231 /* ServerTransport.swift */ = {isa = PBXFileReference; path = Networking/ServerTransport.swift; sourceTree = "<group>"; };
222222222222222222222232 /* BluetoothTransport.swift */ = {isa = PBXFileReference; path = Networking/BluetoothTransport.swift; sourceTree = "<group>"; };
222222222222222222222233 /* ScreenCaptureService.swift */ = {isa = PBXFileReference; path = Services/ScreenCaptureService.swift; sourceTree = "<group>"; };
222222222222222222222234 /* TouchSimulator.swift */ = {isa = PBXFileReference; path = Services/TouchSimulator.swift; sourceTree = "<group>"; };
222222222222222222222235 /* EventProcessor.swift */ = {isa = PBXFileReference; path = Services/EventProcessor.swift; sourceTree = "<group>"; };
222222222222222222222236 /* Data+Extensions.swift */ = {isa = PBXFileReference; path = Extensions/Data+Extensions.swift; sourceTree = "<group>"; };
222222222222222222222237 /* UIImage+Extensions.swift */ = {isa = PBXFileReference; path = Extensions/UIImage+Extensions.swift; sourceTree = "<group>"; };
333333333333333333333333 /* Info.plist */ = {isa = PBXFileReference; path = Support/Info.plist; sourceTree = "<group>"; };
333333333333333333333334 /* RemoteControl.entitlements */ = {isa = PBXFileReference; path = Support/RemoteControl.entitlements; sourceTree = "<group>"; };
/* End PBXFileReference section */
/* Begin PBXGroup section */
444444444444444444444441 = {
  isa = PBXGroup;
  children = (444444444444444444444442, 333333333333333333333333, 333333333333333333333334);
  sourceTree = "<group>";
};
444444444444444444444442 = {
  isa = PBXGroup;
  children = (222222222222222222222222, 222222222222222222222223, 222222222222222222222224, 222222222222222222222225, 222222222222222222222226, 222222222222222222222227, 222222222222222222222228, 222222222222222222222229, 222222222222222222222230, 222222222222222222222231, 222222222222222222222232, 222222222222222222222233, 222222222222222222222234, 222222222222222222222235, 222222222222222222222236, 222222222222222222222237);
  name = RemoteControl;
  sourceTree = "<group>";
};
/* End PBXGroup section */
/* Begin PBXNativeTarget section */
555555555555555555555551 /* RemoteControl */ = {
  isa = PBXNativeTarget;
  buildConfigurationList = 666666666666666666666661;
  buildPhases = (777777777777777777777771, 777777777777777777777772);
  buildRules = ();
  name = RemoteControl;
  productName = RemoteControl;
  productReference = 888888888888888888888881;
  productType = "com.apple.product-type.application";
};
/* End PBXNativeTarget section */
/* Begin PBXProject section */
999999999999999999999991 /* Project object */ = {
  isa = PBXProject;
  attributes = { LastSwiftUpdateCheck = 1500; LastUpgradeCheck = 1500; };
  buildConfigurationList = 666666666666666666666662;
  developmentRegion = en;
  hasScannedForEncodings = 0;
  knownRegions = (en, Base);
  mainGroup = 444444444444444444444441;
  productRefGroup = 444444444444444444444442;
  projectDirPath = "";
  projectRoot = "";
  targets = (555555555555555555555551);
};
/* End PBXProject section */
/* Begin XCBuildConfiguration section */
666666666666666666666671 /* Debug */ = {
  isa = XCBuildConfiguration;
  buildSettings = {
    ASSETCATALOG_COMPILER_APPICON_NAME = "";
    CODE_SIGN_STYLE = Manual;
    CURRENT_PROJECT_VERSION = 1;
    DEVELOPMENT_TEAM = "";
    GENERATE_INFOPLIST_FILE = YES;
    IPHONEOS_DEPLOYMENT_TARGET = 16.0;
    MARKETING_VERSION = 1.0;
    PRODUCT_BUNDLE_IDENTIFIER = "com.remotecontrol.ios";
    PRODUCT_NAME = "RemoteControl";
    SWIFT_VERSION = 5.0;
    TARGETED_DEVICE_FAMILY = "1,2";
    INFOPLIST_FILE = Support/Info.plist;
    CODE_SIGN_IDENTITY = "";
    CODE_SIGNING_REQUIRED = NO;
    CODE_SIGNING_ALLOWED = NO;
  };
  name = Debug;
};
666666666666666666666672 /* Release */ = {
  isa = XCBuildConfiguration;
  buildSettings = {
    ASSETCATALOG_COMPILER_APPICON_NAME = "";
    CODE_SIGN_STYLE = Manual;
    CURRENT_PROJECT_VERSION = 1;
    DEVELOPMENT_TEAM = "";
    GENERATE_INFOPLIST_FILE = YES;
    IPHONEOS_DEPLOYMENT_TARGET = 16.0;
    MARKETING_VERSION = 1.0;
    PRODUCT_BUNDLE_IDENTIFIER = "com.remotecontrol.ios";
    PRODUCT_NAME = "RemoteControl";
    SWIFT_VERSION = 5.0;
    TARGETED_DEVICE_FAMILY = "1,2";
    INFOPLIST_FILE = Support/Info.plist;
    CODE_SIGN_IDENTITY = "";
    CODE_SIGNING_REQUIRED = NO;
    CODE_SIGNING_ALLOWED = NO;
  };
  name = Release;
};
666666666666666666666673 /* Debug */ = {
  isa = XCBuildConfiguration;
  buildSettings = {
    ALWAYS_SEARCH_USER_PATHS = NO;
    CLANG_ENABLE_MODULES = YES;
    CLANG_ENABLE_OBJC_ARC = YES;
    COPY_PHASE_STRIP = NO;
    DEBUG_INFORMATION_FORMAT = dwarf;
    IPHONEOS_DEPLOYMENT_TARGET = 16.0;
    ONLY_ACTIVE_ARCH = YES;
    SDKROOT = iphoneos;
    SWIFT_VERSION = 5.0;
  };
  name = Debug;
};
666666666666666666666674 /* Release */ = {
  isa = XCBuildConfiguration;
  buildSettings = {
    ALWAYS_SEARCH_USER_PATHS = NO;
    CLANG_ENABLE_MODULES = YES;
    CLANG_ENABLE_OBJC_ARC = YES;
    COPY_PHASE_STRIP = NO;
    DEBUG_INFORMATION_FORMAT = dwarf;
    IPHONEOS_DEPLOYMENT_TARGET = 16.0;
    ONLY_ACTIVE_ARCH = NO;
    SDKROOT = iphoneos;
    SWIFT_VERSION = 5.0;
  };
  name = Release;
};
/* End XCBuildConfiguration section */
/* Begin XCConfigurationList section */
666666666666666666666661 /* Build configuration list for target */ = {
  isa = XCConfigurationList;
  buildConfigurations = (666666666666666666666671, 666666666666666666666672);
  defaultConfigurationIsVisible = 0;
  defaultConfigurationName = Release;
};
666666666666666666666662 /* Build configuration list for project */ = {
  isa = XCConfigurationList;
  buildConfigurations = (666666666666666666666673, 666666666666666666666674);
  defaultConfigurationIsVisible = 0;
  defaultConfigurationName = Release;
};
/* End XCConfigurationList section */
/* Begin PBXSourcesBuildPhase section */
777777777777777777777771 /* Sources */ = {
  isa = PBXSourcesBuildPhase;
  buildActionMask = 2147483647;
  files = (111111111111111111111111, 111111111111111111111112, 111111111111111111111113, 111111111111111111111114, 111111111111111111111115, 111111111111111111111116, 111111111111111111111117, 111111111111111111111118, 111111111111111111111119, 111111111111111111111120, 111111111111111111111121, 111111111111111111111122, 111111111111111111111123, 111111111111111111111124, 111111111111111111111125, 111111111111111111111126);
  runOnlyForDeploymentPostprocessing = 0;
};
777777777777777777777772 /* Resources */ = {
  isa = PBXResourcesBuildPhase;
  buildActionMask = 2147483647;
  files = ();
  runOnlyForDeploymentPostprocessing = 0;
};
/* End PBXSourcesBuildPhase section */
/* Begin PBXProductsBuildPhase section */
888888888888888888888881 /* RemoteControl.app */ = {
  isa = PBXFileReference;
  explicitFileType = wrapper.application;
  includeInIndex = 0;
  path = RemoteControl.app;
  sourceTree = BUILT_PRODUCTS_DIR;
};
/* End PBXProductsBuildPhase section */
  };
  rootObject = 999999999999999999999991;
}
ENDXCODE

echo "=== Step 2: Creating Xcode scheme ==="
mkdir -p "$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes"
cat > "$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes/$PROJECT_NAME.xcscheme" << 'ENDSCHEME'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion = "1500" version = "1.7">
  <BuildAction parallelizeBuildables = "YES" buildImplicitDependencies = "YES">
    <BuildActionEntries>
      <BuildActionEntry buildForTesting = "YES" buildForRunning = "YES" buildForProfiling = "YES" buildForArchiving = "YES" buildForAnalyzing = "YES">
        <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "555555555555555555555551" BuildableName = "RemoteControl.app" BlueprintName = "RemoteControl" ReferencedContainer = "container:RemoteControl.xcodeproj"/>
      </BuildActionEntry>
    </BuildActionEntries>
  </BuildAction>
  <TestAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv = "YES"/>
  <LaunchAction buildConfiguration = "Debug" selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle = "0" useCustomWorkingDirectory = "NO" ignoresPersistentStateOnLaunch = "NO" debugDocumentVersioning = "YES" debugServiceExtension = "internal" allowLocationSimulation = "YES">
    <BuildableProductRunnable runnableDebuggingMode = "0">
      <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "555555555555555555555551" BuildableName = "RemoteControl.app" BlueprintName = "RemoteControl" ReferencedContainer = "container:RemoteControl.xcodeproj"/>
    </BuildableProductRunnable>
  </LaunchAction>
  <ProfileAction buildConfiguration = "Release" shouldUseLaunchSchemeArgsEnv = "YES" savedToolIdentifier = "" useCustomWorkingDirectory = "NO" debugDocumentVersioning = "YES">
    <BuildableProductRunnable runnableDebuggingMode = "0">
      <BuildableReference BuildableIdentifier = "primary" BlueprintIdentifier = "555555555555555555555551" BuildableName = "RemoteControl.app" BlueprintName = "RemoteControl" ReferencedContainer = "container:RemoteControl.xcodeproj"/>
    </BuildableProductRunnable>
  </ProfileAction>
  <AnalyzeAction buildConfiguration = "Debug"/>
  <ArchiveAction buildConfiguration = "Release" revealArchiveInOrganizer = "YES"/>
</Scheme>
ENDSCHEME

echo "=== Step 3: Running xcodebuild ==="
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

BUILD_EXIT=$?
if [ $BUILD_EXIT -ne 0 ]; then
  echo "=== xcodebuild failed with exit code: $BUILD_EXIT ==="
  exit $BUILD_EXIT
fi

echo "=== Step 4: Packaging IPA ==="
APP_PATH="build/Build/Products/Release-iphoneos/$PROJECT_NAME.app"
if [ -d "$APP_PATH" ]; then
  mkdir -p output/Payload
  cp -R "$APP_PATH" "output/Payload/"
  cd output
  zip -r "$PROJECT_NAME.ipa" Payload/
  mv "$PROJECT_NAME.ipa" ../
  echo "=== IPA created successfully! ==="
else
  echo "=== ERROR: App not found at $APP_PATH ==="
  echo "Looking for .app anywhere..."
  find build -name "*.app" -type d 2>/dev/null || echo "No .app found"
  exit 1
fi
