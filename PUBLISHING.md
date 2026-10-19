# 公開到 GitHub

## 上傳專案

本資料夾就是 repo 根目錄，建議名稱 `pinyin-dictionary`。上傳內容包含 `Sources/`、`Tools/`、`Assets/`、`Package.swift`、編譯腳本及文件。

`.gitignore` 已排除 `.build/`、`.swiftpm/`、`dist/`、macOS 暫存和 Xcode 個人狀態。`dictionary-index.plist` 則刻意保留在 repo，讓剛下載的專案能直接用 Xcode 執行。兩份原詞表及資料授權聲明也需一併保留。

若建立全新的 GitHub repo，本機已有 README、MIT LICENSE 及 `.gitignore`，不必再讓 GitHub 產生另一份。若遠端已建立這些檔案，先合併現有內容，勿用強制推送覆蓋遠端歷史。

repo 的 description 可使用：

> 簡單易用的 macOS 離線拼音字典，以 SwiftUI 製作，支援繁簡體字詞搜尋、粵拼、粵語同音字、普通話拼音及英文釋義，資料來自 CC-Canto 與 Rime 粵拼詞庫。

## 發佈前確認

- 按你的需要確認 `LICENSE` 中的著作權署名；目前為 `PinyinDictionary contributors`。
- 程式碼採 MIT，字典資料及生成索引按 `DATA-LICENSE.md` 分開處理，勿把整份 repo 的資料都標成 MIT。
- 執行 `./build-app.sh` 及 `Tools/verify.sh`，再手動檢查 app。
- 這個專案沒有漢典 PRC。不要把其他專案、個人檔案或尚未確認再分發授權的字典一起上傳。

## app 下載

本機產物為 `dist/拼音字典.app`。可用以下方式製作保留完整 app 結構的 ZIP：

```sh
ditto -c -k --keepParent dist/拼音字典.app "dist/PinyinDictionary-macos-$(uname -m).zip"
```

這個專案只在本機編譯及驗證，沒有設定 GitHub Actions。腳本只編譯目前 Mac 的架構，不是 Universal Binary，沒有自動發佈、公證或使用開發者憑證。若建立 Release，請標示最低 macOS 版本及 CPU 架構；正式發佈可自行設定 bundle identifier、版本號、Developer ID 簽署及公證。

MIT 及第三方資料聲明已包含在資源 bundle，不能在打包時移除。CC 授權本身允許的資料重用權利不應被額外條款或有效技術限制剝奪。

## 更新字典

若刻意更換原詞表，保留來源和授權，更新來源版本、大小及 SHA-256 清單，再執行 `Tools/build-index.sh` 和 `Tools/verify.sh`。校驗失敗時不要直接忽略；應確認資料變動與來源是否符合預期。
