#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/verification
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/module-cache}"
RESOURCE_DIR="$PWD/Sources/PinyinDictionary/Resources"
cmp DATA-LICENSE.md "$RESOURCE_DIR/ThirdPartyNotices.md"
cmp LICENSE "$RESOURCE_DIR/SoftwareLicense.txt"
swiftc -O -parse-as-library Sources/PinyinDictionary/Dictionary.swift Tools/VerifySources.swift -o .build/verification/verify-sources
.build/verification/verify-sources "$RESOURCE_DIR"
swiftc -O -parse-as-library Sources/PinyinDictionary/Dictionary.swift Tools/VerifyIndex.swift -o .build/verification/verify-index
.build/verification/verify-index "$RESOURCE_DIR/dictionary-index.plist"
swiftc -O -parse-as-library Sources/PinyinDictionary/Dictionary.swift Tools/VerifyHomophones.swift -o .build/verification/verify-homophones
.build/verification/verify-homophones "$RESOURCE_DIR/dictionary-index.plist"
