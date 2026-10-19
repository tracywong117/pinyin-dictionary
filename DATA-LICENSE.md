# 字典資料來源及授權 / Dictionary data licences

本專案的 MIT License 適用於原創 Swift 程式碼、編譯／驗證工具、原創 app 圖示和一般專案文件，**不適用於字典原始資料、生成的資料索引或本聲明中的第三方內容**。
The software MIT licence does not cover the bundled dictionary data or generated data index.

## CC-Canto

- 名稱：CC-Canto — A Cantonese dictionary for everyone
- 隨附版本：2017-02-02
- 著作權：Copyright (c) 2015–17 Pleco Inc.（保留隨附原檔的聲明）
- 官方下載及授權說明：https://cantonese.org/download.html
- 原檔指定網站：http://cccanto.org/
- 授權：Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
- 授權條款：https://creativecommons.org/licenses/by-sa/3.0/legalcode
- 易讀摘要：https://creativecommons.org/licenses/by-sa/3.0/
- 隨附檔案：`cccanto-webdist.txt`

隨附的原始文字檔未修改，原有版權、授權及來源註釋均保留。釋義以原英文顯示，未作翻譯。原資料建議配合 CC-CEDICT 使用；本專案沒有另外打包 CC-CEDICT。
The bundled source file is unchanged. Original notices are retained.

## Rime Cantonese / 粵拼詞庫

- 名稱：Rime Cantonese `jyut6ping3.words` 粵拼詞庫
- 隨附版本：2026.08.10（依本地檔案標頭）
- 署名：粵語計算語言學基礎建設組 (CanCLID) 及 rime-cantonese / rime-cantonese-upstream 貢獻者
- 專案：https://github.com/rime/rime-cantonese
- 詞表標頭指定的上游：https://github.com/CanCLID/rime-cantonese-upstream
- 上游貢獻者及資料來源：https://github.com/CanCLID/rime-cantonese-upstream#readme
- 授權：Creative Commons Attribution 4.0 International (CC BY 4.0)
- 授權條款：https://creativecommons.org/licenses/by/4.0/legalcode
- 易讀摘要：https://creativecommons.org/licenses/by/4.0/
- 隨附檔案：`jyut6ping3.words.dict.yaml`

隨附的原詞表未修改。這個 words 詞表沒有詞義及普通話讀音。本專案沒有使用另採 ODbL 的 `jyut6ping3.maps`，亦沒有打包 Rime 輸入法引擎。
The bundled words source file is unchanged; the Rime engine and maps table are not included.

## 合併資料及同音字索引 / Generated data

`dictionary-index.plist` 由以上兩份資料產生。處理包括：解析字詞及拼音、標準化補充詞表的拼音空白、按「字詞＋粵拼」去重（優先保留 CC-Canto）、建立中文字及拼音反向索引，並從能逐字對齊的詞條建立同音字清單。

在本專案貢獻者就新增的資料選取、編排或其他改編貢獻享有權利的範圍內，該等貢獻採 Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)。原始 CC-Canto 與 Rime 資料仍受其各自授權約束；這個聲明不聲稱重新授權第三方原作。

To the extent copyright or database rights exist in this project's new selection, arrangement, or adaptation contributions to the generated data, those contributions are licensed under CC BY-SA 4.0. The underlying third-party material remains subject to its original licences above.

- 新增整理貢獻署名：PinyinDictionary contributors
- 授權條款：https://creativecommons.org/licenses/by-sa/4.0/legalcode
- 易讀摘要：https://creativecommons.org/licenses/by-sa/4.0/

重建方式：`Tools/build-index.sh`。原始檔的版本、來源及 SHA-256 見 `Sources/PinyinDictionary/Resources/source-manifest.json`。本聲明也隨 app 一起提供。

## 再分發及免責聲明

再分發時，請保留原有著作權、署名及授權聲明，提供適用授權的連結，並標示自行作出的修改。對資料的改編須遵守適用的 ShareAlike 條款。不要以額外條款或有效技術限制剝奪這些授權允許的資料重用權利。

本專案不是 Pleco 或 CanCLID 的官方產品，亦不表示獲任何資料提供者背書。資料及本專案的整理結果均按現狀提供，沒有準確性、完整性或適用性的保證。詞中變調和多音字需按語境理解；同音字索引並非獨立校訂的單字讀音表。

This is an independent project, not endorsed by its data providers. Data and generated results are provided as-is, without warranties of accuracy, completeness, or fitness for purpose. The linked legal texts govern each licence.
