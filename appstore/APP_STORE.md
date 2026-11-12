# App Store 提出資料（バージョン 2.0）

App Store Connect に貼り付ける文面と、提出までの手順をまとめたものです。
`▼` の下のコードブロックが、そのまま貼り付ける文面です。

- バージョン: **2.0**（ビルド 1）
- バンドルID: `CHIA.myakuari`
- 対応言語: 日本語 / 英語 / 簡体字中国語 / 繁体字中国語
- 対応端末: iPhone（iPad 用スクリーンショットは不要）

## 目次

1. [提出チェックリスト](#1-提出チェックリスト)
2. [スクリーンショット](#2-スクリーンショット)
3. [日本語](#3-日本語)
4. [English](#4-english)
5. [简体中文](#5-简体中文)
6. [繁體中文](#6-繁體中文)
7. [App Review へのメモ](#7-app-review-へのメモ)
8. [App のプライバシー（回答の目安）](#8-app-のプライバシー回答の目安)
9. [AdMob とレビュー返信](#9-admob-とレビュー返信)

---

## 1. 提出チェックリスト

- [ ] https://developer.apple.com/account で最新の Program License Agreement に同意する（未同意だと署名・アップロードができない）
- [ ] App Store Connect の「ビジネス」に未同意の契約がないか確認する
- [ ] Xcode の Scheme → Run → Options → App Language を「System Language」に戻す（現在は English 固定）
- [ ] 実機で通しテスト（下の「2.0 のテスト項目」）
- [ ] Xcode で Archive → Distribute App → App Store Connect
- [ ] App Store Connect で 2.0 を作成し、各言語の文面とスクリーンショットを差し替える
- [ ] 「App のプライバシー」の回答を見直す（8章）
- [ ] サポート・マーケティング・プライバシーの各 URL を GitHub Pages のものに差し替える（2章）
- [ ] App Review へのメモを貼る（7章）
- [ ] 審査に提出
- [ ] 公開後、星1レビューに返信する（9章）

### 2.0 のテスト項目

| 操作 | 期待する結果 |
|---|---|
| 初回起動 | 起動時の全画面広告もバナーも出ない |
| 写真も補足も入れずに判定ボタン | エラーが出るだけ。回数は減らず、広告も出ない |
| 初めて判定ボタンを押す | 「AIへの送信について」の確認が出る。キャンセルすると何も送信されない |
| 無料回数で判定 | 判定中の画面 → 結果画面。戻ると無料回数が 0 |
| 機内モードで判定 | 「通信できませんでした。回数は減っていません」と出て、回数はそのまま |
| 回数 0 で判定ボタン | ボタンが「広告を見て判定する」。広告を閉じたあとに判定が始まる |
| 回数 0・広告視聴直後に機内モード | 判定は失敗するが、追加回数が 1 残る。次は広告なしで再試行できる |
| 結果画面の「シェア」 | 結果の画像が共有シートに出る。「画像を保存」で写真に保存できる |
| 1回判定したあとアプリを再起動 | ここから起動時広告とバナーが出る |

自分の本番広告を何度も見ると無効なトラフィックと判定されることがあります。AdMob でテストデバイスを登録してから試してください。

---

## 2. スクリーンショット

2つのサイズを用意しています。App Store Connect の該当する枠に、番号順にアップロードしてください。

| 枠 | サイズ | フォルダ |
|---|---|---|
| iPhone 6.9インチ | 1320 × 2868 | `screenshots/<言語>/` |
| iPhone 6.1 / 6.3インチ | 1206 × 2622 | `screenshots-6.3/<言語>/` |

| 順 | ファイル | 見出し（日本語） |
|---|---|---|
| 1 | `01_result.png` | AIがふたりの「脈あり度」を判定 |
| 2 | `02_input.png` | 写真かトーク画面を選ぶだけ |
| 3 | `03_loading.png` | 約10秒で結果とアドバイス |
| 4 | `04_home.png` | 毎日1回、無料で判定 |

| 言語 | フォルダ |
|---|---|
| 日本語 | `screenshots/ja/` |
| 英語 | `screenshots/en/` |
| 簡体字中国語 | `screenshots/zh-Hans/` |
| 繁体字中国語 | `screenshots/zh-Hant/` |

- `screenshots-raw/` は見出しと枠を付ける前の画面そのものです（同じ 1320 × 2868）。
- 見出しを変えたいときは `tools/make_screenshots.py` の `HEADLINES` を書き換えて実行します。
- 画面の写真は `脈ありカップル写真/goodcouple.png` を使っています。結果の文章はサンプルです。

### 撮り直すとき

デバッグビルドに撮影用の起動引数を入れてあります（リリースビルドには含まれません）。

```
xcrun simctl launch booted CHIA.myakuari -shot result -AppleLanguages "(ja)"
```

`-shot` には `home` / `input` / `loading` / `result` を指定します。入力画面の写真は環境変数 `SIMCTL_CHILD_SHOT_PHOTO` に画像のパスを渡します。

### App Store Connect に登録する URL

GitHub Pages で公開しています（リポジトリの `docs/` フォルダ）。4言語を1ページにまとめてあるので、全言語で同じ URL を使えます。

| 項目 | URL |
|---|---|
| サポート URL | https://changch223.github.io/myakuari/support.html |
| マーケティング URL | https://changch223.github.io/myakuari/ |
| プライバシーポリシー URL | https://changch223.github.io/myakuari/privacy.html |
| ユーザプライバシー選択 URL | https://changch223.github.io/myakuari/privacy-choices.html |

---

## 3. 日本語

▼ 名前（30文字まで）
```
脈ありAIジャッジ - 恋愛診断
```

▼ サブタイトル（30文字まで）
```
写真やトーク画面でAIが脈あり度を判定
```

▼ プロモーション用テキスト（170文字まで）
```
ふたりの写真やトーク画面を選ぶだけ。AIが「脈あり度」をパーセントで判定し、そう見えた理由と次の一手をアドバイスします。毎日1回は無料。判定に失敗したときは回数が減りません。
```

▼ 説明
```
気になるあの人、脈あり？ ふたりの写真やトーク画面を選ぶだけで、AIが「脈あり度」を判定します。

【できること】
・ツーショットやトークのスクリーンショットを最大3枚まで選べます
・ひとこと補足を書くと、状況に合わせて判定します
・脈あり度を 1〜100% で表示
・そう見えた理由、次の一手、応援メッセージが届きます
・結果は画像にして友だちにシェアできます

【料金と回数】
・毎日1回、無料で判定できます
・もっと判定したいときは、広告を見ると1回分が追加されます
・回数が減るのは判定に成功したときだけ。通信エラーなどで失敗したときは減りません

【写真の扱い】
・選んだ写真と補足は、判定のためにGoogleのAI（Gemini）へ送信されます
・初めて判定するときに、送信について確認します
・当アプリでは写真も判定結果も保存しません

【ご注意】
AIの判定は参考としてお楽しみください。結果の正確さを保証するものではありません。
```

▼ キーワード（100文字まで、カンマ区切り）
```
恋愛,診断,脈あり,脈なし,AI,片思い,相性,占い,LINE,トーク,カップル,好きな人,恋,告白,判定
```

▼ このバージョンの最新情報
```
デザインを一新しました。

・判定がすべて「分析失敗」になる不具合を修正しました。ご迷惑をおかけし、申し訳ありませんでした
・判定に失敗したときは、回数が減らないようになりました
・広告を見て得た回数は、判定に失敗しても残ります。広告を見直さずに再試行できます
・判定ボタンに、無料か・広告が出るか・残り何回かを表示するようにしました
・写真がAIへ送信されることを、最初の判定の前に確認するようにしました
・結果画面を見やすくし、結果を画像でシェアできるようにしました
・最初の判定が終わるまで、起動時の広告とバナー広告を表示しないようにしました
```

---

## 4. English

▼ Name (30 characters max)
```
Love Signal AI - Crush Check
```

▼ Subtitle (30 characters max)
```
AI reads photos and chats
```

▼ Promotional Text (170 characters max)
```
Pick a photo or a chat screenshot and AI rates your love signal, explains why, and suggests your next move. One free analysis a day. Failed analyses are never counted.
```

▼ Description
```
Does your crush like you back? Pick a photo of the two of you or a chat screenshot, and AI rates your love signal.

WHAT YOU GET
• Choose up to 3 photos or chat screenshots
• Add a short note for a more personal analysis
• A love signal score from 1 to 100%
• Why it looks that way, your next move, and a word of encouragement
• Share your result as an image

PRICING
• One free analysis every day
• Want more? Watch an ad to get one extra analysis
• An analysis is only counted when it succeeds. If it fails because of a connection problem, nothing is used

YOUR PHOTOS
• The photos and notes you choose are sent to Google's AI (Gemini) to create the analysis
• The app asks for your consent before your first analysis
• This app does not store your photos or your results

PLEASE NOTE
AI results are for entertainment and reference only and are not guaranteed to be accurate.
```

▼ Keywords (100 characters max, comma-separated)
```
love,crush,test,compatibility,couple,relationship,dating,chat,AI,analysis,match,flirt,romance
```

▼ What's New in This Version
```
A completely new design.

• Fixed an issue where every analysis failed. We apologize for the trouble
• A failed analysis no longer uses up one of your analyses
• An analysis earned by watching an ad is kept if the analysis fails, so you can retry without another ad
• The analyze button now tells you whether it is free, whether an ad will play, and how many analyses you have left
• The app now asks for your consent before sending photos to AI for the first time
• A clearer result screen, and you can share your result as an image
• No launch ad or banner ads until you finish your first analysis
```

---

## 5. 简体中文

▼ 名称（最多30个字符）
```
恋爱信号AI判定 - 恋爱测试
```

▼ 副标题（最多30个字符）
```
用合照或聊天截图，AI判定恋爱信号
```

▼ 宣传文本（最多170个字符）
```
只需选择两人的合照或聊天截图，AI就会用百分比判定恋爱信号，并告诉你理由和下一步建议。每天可免费判定1次。判定失败时不会扣除次数。
```

▼ 描述
```
TA对你有感觉吗？只需选择两人的合照或聊天截图，AI就会判定你们的恋爱信号。

【功能】
・最多可选择3张合照或聊天截图
・填写补充说明，判定会更贴合你的情况
・以 1〜100% 显示恋爱信号
・告诉你判定理由、下一步建议和加油打气的话
・可以把结果生成图片分享给朋友

【费用与次数】
・每天可免费判定1次
・想多判定几次，观看广告即可增加1次
・只有判定成功时才会扣除次数。因网络错误等原因失败时不会扣除

【关于照片】
・你选择的照片和补充说明会发送给Google的AI（Gemini）用于判定
・第一次判定前，会先征求你的同意
・本应用不会保存照片和判定结果

【注意】
AI的判定仅供娱乐和参考，不保证结果的准确性。
```

▼ 关键词（最多100个字符，用逗号分隔）
```
恋爱,测试,暗恋,脱单,AI,判定,情侣,配对,聊天,告白,喜欢的人,恋爱信号,桃花,缘分
```

▼ 此版本的新增内容
```
全新设计。

・修复了所有判定都显示“分析失败”的问题。给您带来不便，非常抱歉
・判定失败时，不再扣除次数
・通过观看广告获得的次数，在判定失败时会保留，无需再次观看广告即可重试
・判定按钮会显示是否免费、是否播放广告以及剩余次数
・第一次判定前，会先确认照片将发送给AI
・结果页面更清晰，并且可以把结果生成图片分享
・完成第一次判定之前，不再显示启动广告和横幅广告
```

---

## 6. 繁體中文

▼ 名稱（最多30個字元）
```
戀愛訊號AI判定 - 戀愛測驗
```

▼ 副標題（最多30個字元）
```
用合照或聊天截圖，AI判定戀愛訊號
```

▼ 宣傳文字（最多170個字元）
```
只要選擇兩人的合照或聊天截圖，AI就會用百分比判定戀愛訊號，並告訴你理由和下一步建議。每天可免費判定1次。判定失敗時不會扣除次數。
```

▼ 描述
```
對方對你有感覺嗎？只要選擇兩人的合照或聊天截圖，AI就會判定你們的戀愛訊號。

【功能】
・最多可選擇3張合照或聊天截圖
・填寫補充說明，判定會更貼近你的情況
・以 1〜100% 顯示戀愛訊號
・告訴你判定理由、下一步建議和加油打氣的話
・可以把結果製成圖片分享給朋友

【費用與次數】
・每天可免費判定1次
・想多判定幾次，觀看廣告即可增加1次
・只有判定成功時才會扣除次數。因網路錯誤等原因失敗時不會扣除

【關於照片】
・你選擇的照片和補充說明會傳送給Google的AI（Gemini）用於判定
・第一次判定前，會先徵求你的同意
・本應用不會保存照片和判定結果

【注意】
AI的判定僅供娛樂和參考，不保證結果的準確性。
```

▼ 關鍵字（最多100個字元，用逗號分隔）
```
戀愛,測驗,暗戀,脫單,AI,判定,情侶,配對,聊天,告白,喜歡的人,戀愛訊號,桃花,緣分
```

▼ 此版本的新功能
```
全新設計。

・修正了所有判定都顯示「分析失敗」的問題。造成您的不便，非常抱歉
・判定失敗時，不再扣除次數
・透過觀看廣告獲得的次數，在判定失敗時會保留，無需再次觀看廣告即可重試
・判定按鈕會顯示是否免費、是否播放廣告以及剩餘次數
・第一次判定前，會先確認照片將傳送給AI
・結果頁面更清楚，並且可以把結果製成圖片分享
・完成第一次判定之前，不再顯示啟動廣告和橫幅廣告
```

---

## 7. App Review へのメモ

「App Review に関する情報」→「メモ」に貼ります。ログインは不要なので、サインイン情報は空のままで構いません。

```
No account or sign-in is required.

How to test:
1. Tap the main button on the home screen.
2. Tap a "+" slot and choose any photo, or type a short note.
3. Tap the analyze button. On first use, a consent dialog explains that the selected photos and note are sent to Google's Gemini API to generate the result. Tap "Agree & Analyze".
4. The result screen shows a score, the reasoning, and advice.

Third-party AI: the selected photos and the optional note are sent to Google's Gemini API through our relay server only to generate the result. Neither the app nor our relay server stores them. Users are informed and must consent before the first analysis.

Ads: one analysis per day is free. When no analyses are left, the user can watch a rewarded ad to receive one extra analysis. The reward is granted when the ad completes and is only consumed after a successful analysis. No app-open ad or banner is shown until the user has completed a first analysis.

What changed in 2.0: fixed a server-side model deprecation that made every analysis fail, redesigned all screens, added the AI consent dialog, and added sharing of the result as an image (uses the photo library add-only permission when the user chooses "Save Image").
```

---

## 8. App のプライバシー（回答の目安）

App Store Connect →「App のプライバシー」の回答です。最終的な回答は、AdMob の公開している案内と、実際に使っている SDK の設定に合わせて確認してください。

| データの種類 | 収集するか | 用途 | ユーザーに紐づくか | トラッキング |
|---|---|---|---|---|
| 写真またはビデオ | する（判定時にサーバーへ送信） | App の機能 | 紐づかない | しない |
| その他のユーザーコンテンツ（補足のテキスト） | する | App の機能 | 紐づかない | しない |
| デバイス ID | する（AdMob） | サードパーティ広告 | AdMob の案内に従う | AdMob の案内に従う |
| 広告データ・製品の操作（AdMob） | する | サードパーティ広告、アナリティクス | AdMob の案内に従う | AdMob の案内に従う |
| 診断（クラッシュ、パフォーマンス） | する（AdMob） | アナリティクス | AdMob の案内に従う | しない |

確認が必要な点が2つあります。

- **Gemini API のプラン。** 無料枠で使っている場合、送信した内容が Google のサービス改善に使われる規約になっていることがあります。その場合、アプリ内と説明文の「保存しません」は当アプリについてのみ正しく、Google 側の扱いは別になります。有料枠（Cloud 課金を有効にしたプロジェクト）にしておくことを勧めます。
- **トラッキングの許可（ATT）。** 現在アプリは ATT の許可ダイアログを出していません。この状態では広告 ID は取得されません。「トラッキングに使用」を「はい」と回答する場合は ATT の実装が必要です。

プライバシーポリシーの文案は `PRIVACY_POLICY.md` にあります。

---

## 9. AdMob とレビュー返信

### AdMob ポリシーセンターの審査リクエスト

```
リワード広告視聴後に実行されるAI判定が、利用していたAIモデルの提供終了によりすべて失敗し、報酬が提供されない状態になっていました。サーバー側を修正し、現在は視聴後に判定が正常に実行されます。あわせてアプリを更新し、報酬は視聴完了時に必ず「追加分析回数」として付与され、判定が失敗した場合も回数が残る仕様に変更しました。
```

### 星1レビューへの返信（2.0 公開後）

```
ご迷惑をおかけし、申し訳ありません。ご指摘のとおり、判定がすべて失敗し、回数だけが減って広告だけが表示される状態でした。原因は、利用していたAIモデルの提供終了に当アプリが対応できていなかったことで、完全にこちらの不具合です。バージョン2.0で修正し、判定に成功したときだけ回数を使い、失敗したときは回数が減らないように変更しました。写真は判定のためだけにAIへ送信し、当アプリでは保存していません。最初の判定の前に、送信について確認する画面も追加しました。
```
