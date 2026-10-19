import Foundation

struct Entry: Identifiable, Codable, Sendable {
    let id: Int
    let traditional: String
    let simplified: String
    let mandarin: String
    let cantonese: String
    let meanings: [String]
    var source: String = "CC-Canto"
}
struct HomophoneNavigation {
    let results: [Entry]
    let selectedID: Int?
}

struct DictionaryData: Codable, Sendable {
    var entries: [Entry] = []
    var homophones: [String: Set<String>] = [:]
    var characterIndex: [String: [Int]] = [:]
    var pronunciationIndex: [String: [Int]] = [:]
    var pronunciationKeys: [String] = []
    var formatVersion = 1

    static func load() throws -> Self {
        #if SWIFT_PACKAGE
        guard let url = Bundle.module.url(forResource: "dictionary-index", withExtension: "plist") else { throw CocoaError(.fileNoSuchFile) }
        return try loadIndex(at: url)
        #else
        throw CocoaError(.fileNoSuchFile)
        #endif
    }
    static func loadIndex(at url: URL) throws -> Self {
        let data = try PropertyListDecoder().decode(Self.self, from: Data(contentsOf: url, options: .mappedIfSafe))
        guard data.formatVersion == 1, !data.entries.isEmpty else { throw CocoaError(.fileReadCorruptFile) }
        return data
    }
    // Used by the build tool only. The app loads the prebuilt index instead.
    static func buildIndex(from directory: URL) throws -> Self {
        let url = directory.appendingPathComponent("cccanto-webdist.txt")
        let text = try String(contentsOf: url, encoding: .utf8)
        let regex = try NSRegularExpression(pattern: #"^(\S+)\s+(\S+)\s+\[([^\]]*)\]\s+\{([^}]+)\}\s+/(.*)/\s*(?:#.*)?$"#)
        var data = Self()
        for line in text.components(separatedBy: .newlines) where !line.hasPrefix("#") && !line.isEmpty {
            let ns = line as NSString
            guard let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: ns.length)) else { continue }
            let fields = (1...5).map { ns.substring(with: match.range(at: $0)) }
            let entry = Entry(id: data.entries.count, traditional: fields[0], simplified: fields[1], mandarin: fields[2], cantonese: fields[3], meanings: fields[4].split(separator: "/").map(String.init))
            data.entries.append(entry)
        }
        let supplementURL = directory.appendingPathComponent("jyut6ping3.words.dict.yaml")
        let supplement = try String(contentsOf: supplementURL, encoding: .utf8)
        var known = Set(data.entries.flatMap { entry in
            [entry.traditional, entry.simplified].map { $0 + "\t" + entry.cantonese }
        })
        var inBody = false
        for line in supplement.components(separatedBy: .newlines) {
            if line.trimmingCharacters(in: .whitespacesAndNewlines) == "..." { inBody = true; continue }
            guard inBody, !line.hasPrefix("#") else { continue }
            let fields = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard fields.count >= 2 else { continue }
            let word = String(fields[0]).trimmingCharacters(in: .whitespaces)
            let reading = fields[1].split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
            guard !word.isEmpty, !reading.isEmpty,
                  reading.split(separator: " ").allSatisfy({ $0.range(of: #"^[a-z]+[1-6]$"#, options: .regularExpression) != nil }),
                  known.insert(word + "\t" + reading).inserted else { continue }
            data.entries.append(Entry(id: data.entries.count, traditional: word, simplified: word, mandarin: "", cantonese: reading, meanings: [], source: "Rime 粵拼詞庫"))
        }
        // Only align whole entries with exactly one syllable per character.
        for entry in data.entries {
            let syllables = entry.cantonese.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            let chars = Array(entry.traditional)
            if chars.count == syllables.count {
                for (character, syllable) in zip(chars, syllables) where syllable.range(of: #"^[a-z]+[1-6]$"#, options: .regularExpression) != nil && character.unicodeScalars.allSatisfy({ (0x3400...0x9FFF).contains($0.value) || (0x20000...0x323AF).contains($0.value) }) {
                    data.homophones[syllable, default: []].insert(String(character))
                }
            }
        }
        guard !data.entries.isEmpty else { throw CocoaError(.fileReadCorruptFile) }
        for entry in data.entries {
            let characters = Set((entry.traditional.lowercased() + entry.simplified.lowercased()).map(String.init))
            for character in characters { data.characterIndex[character, default: []].append(entry.id) }
            for pronunciation in Set([entry.cantonese.lowercased(), entry.mandarin.lowercased()]) where !pronunciation.isEmpty {
                data.pronunciationIndex[pronunciation, default: []].append(entry.id)
            }
        }
        data.pronunciationKeys = data.pronunciationIndex.keys.sorted()
        return data
    }
    // Navigation is keyed by both the character and the clicked tone-bearing syllable.
    // Read the complete posting list rather than the first 100 general search results.
    func homophoneNavigation(character: String, reading: String) -> HomophoneNavigation {
        let candidates = (characterIndex[character.lowercased()] ?? []).map { entries[$0] }
        let exact = candidates.filter {
            ($0.traditional == character || $0.simplified == character) && $0.cantonese == reading
        }
        let examples = candidates.filter { entry in
            let syllables = entry.cantonese.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            return [entry.traditional, entry.simplified].contains { word in
                let characters = word.map(String.init)
                return characters.count == syllables.count && zip(characters, syllables).contains {
                    $0.0 == character && $0.1 == reading
                }
            }
        }.filter { entry in !exact.contains { $0.id == entry.id } }
         .sorted {
             if $0.traditional.count != $1.traditional.count { return $0.traditional.count < $1.traditional.count }
             return $0.id < $1.id
         }
        let preferred = exact.first ?? examples.first
        var results = search(character)
        // Preserve the normal character search. If its 100-result cap hides the
        // matching pronunciation, retain that real entry as the final visible row.
        if let preferred, !results.contains(where: { $0.id == preferred.id }) {
            if results.count >= 100 { results.removeLast() }
            results.append(preferred)
        }
        return HomophoneNavigation(results: results, selectedID: preferred?.id)
    }

    func search(_ query: String) -> [Entry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        func rank(_ e: Entry) -> Int {
            if e.traditional == q || e.simplified == q { return 0 }
            if e.traditional.hasPrefix(q) || e.simplified.hasPrefix(q) { return 1 }
            if e.cantonese.lowercased() == q || e.mandarin.lowercased() == q { return 2 }
            return 3
        }
        // Start with the rarest query character, then verify the entire substring.
        // This preserves contains-search without visiting every dictionary entry.
        let postingLists = Set(q.map(String.init)).map { characterIndex[$0] ?? [] }
        var candidateIDs = Set<Int>()
        if let smallest = postingLists.min(by: { $0.count < $1.count }) {
            for id in smallest {
                let entry = entries[id]
                if entry.traditional.contains(q) || entry.simplified.contains(q) { candidateIDs.insert(id) }
            }
        }
        // Binary search the sorted pronunciation keys and visit only matching prefixes.
        var low = 0, high = pronunciationKeys.count
        while low < high {
            let mid = (low + high) / 2
            if pronunciationKeys[mid] < q { low = mid + 1 } else { high = mid }
        }
        var position = low
        while position < pronunciationKeys.count && pronunciationKeys[position].hasPrefix(q) {
            candidateIDs.formUnion(pronunciationIndex[pronunciationKeys[position]] ?? [])
            position += 1
        }
        return Array(candidateIDs.map { entries[$0] }.sorted {
            let a = rank($0), b = rank($1)
            if a != b { return a < b }
            if $0.traditional.count != $1.traditional.count { return $0.traditional.count < $1.traditional.count }
            return $0.id < $1.id
        }.prefix(100))
    }
}

