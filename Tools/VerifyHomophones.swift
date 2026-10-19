import Foundation

@main struct VerifyHomophones {
    static func main() throws {
        let data = try DictionaryData.loadIndex(at: URL(fileURLWithPath: CommandLine.arguments[1]))
        func matches(_ entry: Entry, character: String, reading: String) -> Bool {
            let syllables = entry.cantonese.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            return [entry.traditional, entry.simplified].contains { word in
                let chars = word.map(String.init)
                return chars.count == syllables.count && zip(chars, syllables).contains { $0.0 == character && $0.1 == reading }
            }
        }
        let lei = data.homophoneNavigation(character: "麗", reading: "lei4")
        let selected = lei.results.first { $0.id == lei.selectedID }
        precondition(selected?.traditional == "高句麗", "麗 lei4 should open 高句麗")
        precondition(lei.results.map(\.id) == data.search("麗").map(\.id), "Keep the ordinary 麗 search")
        precondition(lei.results.count > 2)
        precondition(!lei.results.contains { $0.traditional == "麗" && $0.cantonese == "lei4" })
        print("麗 lei4: \(lei.results.count) normal results, selected \(selected!.traditional) [\(selected!.cantonese)]")
        var checked = 0, preserved = 0, rescued = 0
        for reading in data.homophones.keys.sorted() {
            for character in (data.homophones[reading] ?? []).sorted() {
                let navigation = data.homophoneNavigation(character: character, reading: reading)
                guard let entry = navigation.results.first(where: { $0.id == navigation.selectedID }) else { fatalError("Missing real matching entry") }
                precondition(matches(entry, character: character, reading: reading))
                precondition(navigation.results.allSatisfy { $0.id >= 0 })
                precondition(navigation.results.count <= 100)
                let normal = data.search(character)
                if normal.contains(where: { $0.id == entry.id }) {
                    precondition(navigation.results.map(\.id) == normal.map(\.id))
                    preserved += 1
                } else {
                    precondition(navigation.results.last?.id == entry.id)
                    precondition(navigation.results.dropLast().map(\.id) == normal.prefix(99).map(\.id))
                    rescued += 1
                }
                let exact = (data.characterIndex[character] ?? []).map { data.entries[$0] }.first {
                    ($0.traditional == character || $0.simplified == character) && $0.cantonese == reading
                }
                if let exact { precondition(entry.id == exact.id) }
                checked += 1
            }
        }
        print("PASS: \(checked) targets select real matching entries; \(preserved) preserve normal results, \(rescued) retain a match beyond the search cap; no synthetic entries")
    }
}
