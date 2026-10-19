#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/index-tool
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/module-cache}"
# Keep the app's copy of the notices in sync with the repository's canonical files.
cp DATA-LICENSE.md Sources/PinyinDictionary/Resources/ThirdPartyNotices.md
cp LICENSE Sources/PinyinDictionary/Resources/SoftwareLicense.txt
swiftc -O -parse-as-library Sources/PinyinDictionary/Dictionary.swift Tools/BuildIndex.swift -o .build/index-tool/build-index
.build/index-tool/build-index Sources/PinyinDictionary/Resources Sources/PinyinDictionary/Resources/dictionary-index.plist
