import Foundation

extension DictionaryData {
    func baselineSearch(_ query: String) -> [Entry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        func rank(_ e: Entry) -> Int {
            if e.traditional == q || e.simplified == q { return 0 }
            if e.traditional.hasPrefix(q) || e.simplified.hasPrefix(q) { return 1 }
            if e.cantonese.lowercased() == q || e.mandarin.lowercased() == q { return 2 }
            return 3
        }
        return Array(entries.filter { $0.traditional.contains(q) || $0.simplified.contains(q) || $0.cantonese.lowercased().hasPrefix(q) || $0.mandarin.lowercased().hasPrefix(q) }.sorted {
            let a = rank($0), b = rank($1)
            if a != b { return a < b }
            if $0.traditional.count != $1.traditional.count { return $0.traditional.count < $1.traditional.count }
            return $0.id < $1.id
        }.prefix(100))
    }
}
@main struct VerifyIndex {
    static func main() throws {
        let path = URL(fileURLWithPath: CommandLine.arguments[1])
        let start = Date()
        let data = try DictionaryData.loadIndex(at: path)
        let loadTime = Date().timeIntervalSince(start)
        var queries = ["", "   ", "好", "你", "香港", "食", "心", "廣東", "aa", "a", "soeng2", "hou2", "ni3", "not-a-match", "𠵼", "ABC", " guong2 "]
        for i in stride(from: 0, to: data.entries.count, by: 2300) {
            let entry = data.entries[i]
            queries.append(entry.traditional)
            queries.append(String(entry.traditional.suffix(2)))
            queries.append(entry.cantonese)
            queries.append(String(entry.cantonese.prefix(3)))
            if !entry.mandarin.isEmpty { queries.append(entry.mandarin) }
        }
        for q in queries {
            let actual = data.search(q).map(\.id)
            let expected = data.baselineSearch(q).map(\.id)
            precondition(actual == expected, "Results differ: \(q)")
        }
        let samples = ["香", "香港", "食", "心", "soeng2", "hou2", "ni3", "a"]
        var indexed: Double = 0, baseline: Double = 0
        var checksum = 0
        for q in samples {
            let first = Date()
            for _ in 0..<5 { checksum += data.search(q).count }
            let middle = Date()
            for _ in 0..<5 { checksum += data.baselineSearch(q).count }
            let last = Date()
            let fast = middle.timeIntervalSince(first) / 5 * 1000
            let slow = last.timeIntervalSince(middle) / 5 * 1000
            indexed += fast; baseline += slow
            print("\(q): index \(String(format: "%.2f", fast)) ms, scan \(String(format: "%.2f", slow)) ms")
        }
        precondition(checksum > 0)
        print("PASS: \(queries.count) equivalence checks; \(data.entries.count) entries; load \(String(format: "%.2f", loadTime)) s; mean index \(String(format: "%.2f", indexed / Double(samples.count))) ms / scan \(String(format: "%.2f", baseline / Double(samples.count))) ms")
    }
}
