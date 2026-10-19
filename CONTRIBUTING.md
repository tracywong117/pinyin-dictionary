# 參與貢獻

歡迎透過 GitHub Issues 提交問題，或用 Pull Request 改善介面、效能及文件。

## 回報問題

請提供 macOS 版本、使用的 Mac 架構（Apple Silicon / Intel）、輸入的字詞或拼音、預期結果及實際結果。若與讀音有關，請附上可靠來源；請勿貼上尚未獲准再分發的整份字典。

## 開發及驗證

1. 以 Xcode 開啟 `Package.swift`，或使用 `./build-app.sh` 建立 app。
2. 修改字典原資料後，以 `Tools/build-index.sh` 重新生成索引。
3. 執行 `Tools/verify.sh`，確認搜尋排序及同音字跳轉維持正確。
4. 在 Pull Request 說明變更原因及驗證結果。

程式碼貢獻依 MIT License 提交；資料整理貢獻按 `DATA-LICENSE.md` 說明處理。新增第三方資料時須一併提供來源及授權。原詞表應優先向上游回報修正，避免在本專案無說明地修改。
