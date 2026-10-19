#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/icon-tool Assets
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PWD/.build/module-cache}"
swiftc -O -parse-as-library Tools/MakeAppIcon.swift -o .build/icon-tool/make-icon
.build/icon-tool/make-icon Assets
cp Assets/AppIcon.icns Sources/PinyinDictionary/Resources/AppIcon.icns
