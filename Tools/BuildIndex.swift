import Foundation

@main struct BuildIndex {
    static func main() throws {
        guard CommandLine.arguments.count == 3 else {
            fatalError("Usage: build-index <resources-directory> <index-output-path>")
        }
        let directory = URL(fileURLWithPath: CommandLine.arguments[1])
        let output = URL(fileURLWithPath: CommandLine.arguments[2])
        let started = Date()
        let index = try DictionaryData.buildIndex(from: directory)
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        try encoder.encode(index).write(to: output, options: .atomic)
        print("Built index: \(index.entries.count) entries, \(index.characterIndex.count) character keys, \(index.pronunciationKeys.count) pronunciation keys (\(String(format: "%.2f", Date().timeIntervalSince(started))) s)")
    }
}
