#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/module-cache}"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"
Tools/build-icon.sh
Tools/build-index.sh
swift build --disable-sandbox -c release
BIN_DIR=$(swift build --disable-sandbox -c release --show-bin-path)
APP="$PWD/dist/拼音字典.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/PinyinDictionary" "$APP/Contents/MacOS/"
cp Assets/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
# Copy the resource bundle itself, avoiding nested bundles on repeated builds.
ditto "$BIN_DIR/PinyinDictionary_PinyinDictionary.bundle" "$APP/Contents/Resources/PinyinDictionary_PinyinDictionary.bundle"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>PinyinDictionary</string>
<key>CFBundleIdentifier</key><string>org.pinyin-dictionary.app</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleName</key><string>拼音字典</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --deep --sign - "$APP"
codesign --verify --deep --strict "$APP"
printf '已建立：%s\n' "$APP"
