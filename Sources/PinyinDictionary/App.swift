import SwiftUI
import AppKit

@MainActor final class DictionaryModel: ObservableObject {
    @Published var data = DictionaryData()
    @Published var loading = true
    @Published var error: String?
    func load() async {
        do { data = try await Task.detached(priority: .userInitiated) { try DictionaryData.load() }.value }
        catch { self.error = "無法載入字典：\(error.localizedDescription)" }
        loading = false
    }
}

@main struct PinyinDictionaryApp: App {
    var body: some Scene {
        WindowGroup("拼音字典") { ContentView().frame(minWidth: 760, minHeight: 520) }
        .defaultSize(width: 960, height: 680)
    }
}
struct HomophoneTarget {
    let character: String
    let reading: String
}
struct ContentView: View {
    @StateObject private var model = DictionaryModel()
    @State private var showLicenses = false
    @State private var query = ""
    @State private var results: [Entry] = []
    @State private var selectedID: Int?
    @State private var homophoneTarget: HomophoneTarget?
    @FocusState private var searchFocused: Bool
    private var selected: Entry? { results.first { $0.id == selectedID } }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "character.book.closed.fill").font(.largeTitle).foregroundStyle(.teal)
                VStack(alignment: .leading) {
                    Text("拼音字典").font(.title.bold())
                    Text("粵拼 · 同音字 · 普通話").foregroundStyle(.secondary)
                }
                Spacer()
                Text("離線字典").font(.system(size: 16)).foregroundStyle(.secondary)
            }
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("輸入中文字、詞語或拼音，例如：香港、soeng2", text: $query)
                    .textFieldStyle(.plain).focused($searchFocused)
                    .onSubmit { if selectedID == nil { selectedID = results.first?.id } }
                if !query.isEmpty { Button { query = ""; searchFocused = true } label: { Image(systemName: "xmark.circle.fill") }.buttonStyle(.plain).help("清除搜尋") }
            }.padding(12).background(.quaternary, in: RoundedRectangle(cornerRadius: 10))
            if model.loading {
                Spacer(); HStack { Spacer(); ProgressView("正在載入字典…"); Spacer() }; Spacer()
            } else if let error = model.error {
                Text(error).foregroundStyle(.red); Spacer()
            } else if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "text.magnifyingglass").font(.system(size: 46)).foregroundStyle(.teal)
                    Text("輸入一個字，發現更多詞語").font(.title2)
                    Text("支援繁體、簡體及帶聲調數字的拼音搜尋").foregroundStyle(.secondary)
                    HStack { ForEach(["香港", "食", "心"], id: \.self) { word in Button(word) { query = word } } }
                }.frame(maxWidth: .infinity)
                Spacer()
            } else if results.isEmpty {
                Text("找不到「\(query)」").font(.title2)
                Text("這份字典以粵語詞彙為主，未必收錄所有單字。試試相關詞語或其他拼音。").foregroundStyle(.secondary)
                Spacer()
            } else {
                HSplitView {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("詞語建議（最多 100 項）").font(.system(size: 16)).foregroundStyle(.secondary)
                        ScrollViewReader { proxy in
                        List(results, selection: $selectedID) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.traditional).font(.system(size: 23))
                                Text(entry.cantonese).font(.system(size: 16)).foregroundStyle(.secondary)
                            }.padding(.vertical, 4).tag(entry.id).id(entry.id)
                        }.listStyle(.inset)
                        .onChange(of: selectedID) { id in
                            if let id { proxy.scrollTo(id, anchor: .center) }
                        }
                        .onAppear {
                            if let selectedID { proxy.scrollTo(selectedID, anchor: .center) }
                        }
                        }
                    }.frame(minWidth: 190, idealWidth: 240, maxWidth: 300)
                    ScrollView {
                        if let entry = selected {
                            VStack(alignment: .leading, spacing: 22) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(entry.traditional).font(.system(size: 36, weight: .semibold))
                                    if entry.simplified != entry.traditional { Text(entry.simplified).foregroundStyle(.secondary) }
                                }
                                section("粵語拼音（粵拼）", text: entry.cantonese)
                                section("普通話拼音", text: entry.mandarin.isEmpty ? "原字典未提供普通話讀音" : entry.mandarin)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.meanings.isEmpty ? "意思" : "意思（原字典英文釋義）").font(.system(size: 19, weight: .semibold))
                                    if entry.meanings.isEmpty {
                                        Text("粵拼補充詞條，未提供詞義及普通話讀音。").foregroundStyle(.secondary)
                                    }
                                    Text("來源：\(entry.source)").font(.system(size: 16)).foregroundStyle(.secondary)
                                    ForEach(Array(entry.meanings.enumerated()), id: \.offset) { index, meaning in Text("\(index + 1). \(meaning)") }
                                }
                                Divider()
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("粵語同音字").font(.system(size: 19, weight: .semibold))
                                    Text("按相同粵拼及聲調配對；從字典詞條推算，可能包含多音字的不同讀法。").font(.system(size: 16)).foregroundStyle(.secondary)
                                    ForEach(Array(entry.cantonese.split(whereSeparator: { $0.isWhitespace }).map(String.init).enumerated()), id: \.offset) { _, syllable in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(syllable).font(.system(size: 19, weight: .semibold)).foregroundStyle(.teal)
                                            let chars = (model.data.homophones[syllable] ?? []).sorted()
                                            if chars.isEmpty {
                                                Text("字典中未找到其他同音字").foregroundStyle(.secondary)
                                            } else {
                                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 54), spacing: 10)], alignment: .leading, spacing: 10) {
                                                    ForEach(chars, id: \.self) { character in
                                                        Button {
                                                            homophoneTarget = HomophoneTarget(character: character, reading: syllable)
                                                            query = character
                                                            updateResults()
                                                        } label: {
                                                            Text(character)
                                                                .font(.system(size: 27))
                                                                .frame(maxWidth: .infinity, minHeight: 46)
                                                                .contentShape(Rectangle())
                                                        }
                                                        .buttonStyle(.bordered)
                                                        .tint(entry.traditional.contains(character) ? .gray : .teal)
                                                        .help("查看「\(character)」的讀音和意思")
                                                        .accessibilityLabel("查看\(character)，\(syllable)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }.textSelection(.enabled).padding(20).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }.id(selected.map { "\($0.traditional):\($0.cantonese):\($0.id)" }).frame(minWidth: 400)
                }
            }
            Text("CC-Canto（Pleco，CC BY-SA 3.0）+ Rime 粵拼詞庫（CanCLID，CC BY 4.0）· \(model.data.entries.count) 個詞條")
                .font(.system(size: 15)).foregroundStyle(.secondary)
        }.font(.system(size: 18)).padding(22)
        .task {
            if let iconURL = Bundle.module.url(forResource: "AppIcon", withExtension: "icns"), let icon = NSImage(contentsOf: iconURL) {
                NSApplication.shared.applicationIconImage = icon
            }
            await model.load(); updateResults(); searchFocused = true
        }
        .onChange(of: query) { _ in updateResults() }
        .sheet(isPresented: $showLicenses) { LicensesView() }
        .toolbar {
            ToolbarItem { Button { searchFocused = true } label: { Label("搜尋", systemImage: "magnifyingglass") }.keyboardShortcut("f", modifiers: .command) }
            ToolbarItem { Button { showLicenses = true } label: { Label("資料來源與授權", systemImage: "info.circle") } }
        }
    }
    private func updateResults() {
        if let target = homophoneTarget, target.character == query {
            let navigation = model.data.homophoneNavigation(character: target.character, reading: target.reading)
            results = navigation.results
            selectedID = navigation.selectedID
        } else {
            homophoneTarget = nil
            results = model.data.search(query)
            selectedID = results.first?.id
        }
    }
    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) { Text(title).font(.system(size: 19, weight: .semibold)); Text(text).font(.system(size: 23)).foregroundStyle(.teal) }
    }
}
