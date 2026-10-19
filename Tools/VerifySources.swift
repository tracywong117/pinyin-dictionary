import Foundation
import CryptoKit

@main struct VerifySources {
    struct Manifest: Decodable { let sources: [Source] }
    struct Source: Decodable { let file: String; let sha256: String; let bytes: Int }
    static func main() throws {
        let directory = URL(fileURLWithPath: CommandLine.arguments[1])
        let manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: directory.appendingPathComponent("source-manifest.json")))
        for source in manifest.sources {
            let data = try Data(contentsOf: directory.appendingPathComponent(source.file))
            let checksum = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            precondition(data.count == source.bytes && checksum == source.sha256, "Source checksum mismatch: \(source.file). If deliberately updating the dictionary, update its manifest and provenance too.")
        }
        let index = try DictionaryData.loadIndex(at: directory.appendingPathComponent("dictionary-index.plist"))
        let rebuilt = try DictionaryData.buildIndex(from: directory)
        // Compare logical contents: binary plist ordering of sets is not deterministic.
        let encoder = JSONEncoder(); encoder.outputFormatting = .sortedKeys
        let actual = try encoder.encode(index.entries)
        let expected = try encoder.encode(rebuilt.entries)
        precondition(actual == expected)
        precondition(index.homophones == rebuilt.homophones)
        precondition(index.characterIndex == rebuilt.characterIndex)
        precondition(index.pronunciationIndex == rebuilt.pronunciationIndex)
        precondition(index.pronunciationKeys == rebuilt.pronunciationKeys)
        print("PASS: source checksums and bundled index match the source dictionaries")
    }
}
