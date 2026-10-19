import SwiftUI

struct LicensesView: View {
    @Environment(\.dismiss) private var dismiss
    private let notices = Bundle.module.url(forResource: "ThirdPartyNotices", withExtension: "md")
        .flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "授權說明無法載入，請查看專案的 DATA-LICENSE.md。"
    private let software = Bundle.module.url(forResource: "SoftwareLicense", withExtension: "txt")
        .flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? "請查看專案的 LICENSE。"
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("資料來源與授權").font(.title2.bold())
                Spacer()
                Button("完成") { dismiss() }.keyboardShortcut(.defaultAction)
            }
            HStack(spacing: 18) {
                Link("CC-Canto", destination: URL(string: "https://cantonese.org/download.html")!)
                Link("Rime Cantonese", destination: URL(string: "https://github.com/rime/rime-cantonese")!)
            }
            HStack(spacing: 14) {
                Link("CC BY-SA 3.0", destination: URL(string: "https://creativecommons.org/licenses/by-sa/3.0/")!)
                Link("CC BY 4.0", destination: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
                Link("CC BY-SA 4.0", destination: URL(string: "https://creativecommons.org/licenses/by-sa/4.0/")!)
            }
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(notices)
                    Divider()
                    Text("程式碼授權 / Software licence").font(.headline)
                    Text(software)
                }.font(.system(size: 15)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
            }
        }.padding(22).frame(width: 680, height: 580)
    }
}
