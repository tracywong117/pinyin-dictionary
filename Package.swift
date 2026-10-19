// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PinyinDictionary",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "PinyinDictionary", targets: ["PinyinDictionary"])
    ],
    targets: [
        .executableTarget(
            name: "PinyinDictionary",
            resources: [.process("Resources")]
        )
    ]
)
