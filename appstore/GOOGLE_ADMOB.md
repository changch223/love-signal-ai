# Google 側の対応資料（AdMob・Gemini）

AdMob のポリシー違反の審査リクエストに使う文面と、Google 側で確認しておくことをまとめたものです。
`▼` の下のコードブロックが、そのまま貼り付ける文面です。

- アプリ: Love Signal AI Detection App!（App Store / アプリ ID 6744615409）
- 指摘内容: **獎勵實施 - 未提供承諾的獎勵**（リワードの実装 - 約束した報酬を提供していない）
- 制限開始日: **2026-11-13**

## 目次

1. [いまの状態と、いつ申請するか](#1-いまの状態といつ申請するか)
2. [審査リクエストの手順](#2-審査リクエストの手順)
3. [審査リクエストの文面](#3-審査リクエストの文面)
4. [リワード広告ポリシーとの照合](#4-リワード広告ポリシーとの照合)
5. [テストデバイスの登録](#5-テストデバイスの登録)
6. [AdMob でほかに確認すること](#6-admob-でほかに確認すること)
7. [Gemini API（Google AI / Google Cloud）で確認すること](#7-gemini-apigoogle-ai--google-cloudで確認すること)

---

## 1. いまの状態と、いつ申請するか

| 時点 | 状態 | 申請できるか |
|---|---|---|
| 2026-11-12 21:26 以降（現在） | サーバーを修正済み。公開中の 1.x でも、広告視聴後に判定が実行される | できる。3章の「A」の文面を使う |
| 2.0 公開後 | 報酬が回数として必ず付与され、判定が失敗しても残る | 「A」で通らなかった場合や、再度指摘された場合に「B」の文面を使う |

審査担当者が見るのは、公開されているバージョンです。申請する前に、App Store 版の実機で「回数 0 → 広告を最後まで見る → 判定結果が出る」を必ず1回確認してください。

公開中の 1.x には弱点が残っています。広告を見たあとに通信エラーなどで判定が失敗すると、報酬は失われます。サーバー障害は直っているので通常は成功しますが、確実に解消されるのは 2.0 からです。

---

## 2. 審査リクエストの手順

1. AdMob にログインし、左メニューの「ポリシー センター」を開く（メールの「前往政策中心」ボタンからも開けます）。
2. 「問題のあるアプリ」から Love Signal AI Detection App! を選ぶ。
3. 指摘内容「獎勵實施 - 未提供承諾的獎勵」を開き、「修正」または「審査をリクエスト」を選ぶ。
4. 修正済みであることを確認するチェックボックスがあればチェックし、説明欄に3章の文面を貼る。
5. 送信する。結果はメールとポリシー センターに届きます。

画面の項目名は AdMob の表示言語や時期によって少し違うことがあります。説明欄がない場合は、チェックして送信するだけで構いません。

---

## 3. 審査リクエストの文面

AdMob の表示言語に合わせて、どれか1つを貼ってください。内容は同じです。

### A. いま申請する場合（サーバー修正後、2.0 公開前）

▼ 日本語
```
リワード広告の視聴後に実行されるAI判定が、利用していたAIモデルの提供終了によりすべて失敗し、ユーザーに報酬（判定1回）が提供されない状態になっていました。2026年11月12日にサーバー側を修正し、現在は広告の視聴完了後に判定が正常に実行され、結果が表示されます。

確認方法：アプリを起動 → 写真を1枚選ぶ → 無料回数が0の状態で判定ボタンを押す → リワード広告を最後まで視聴 → 判定結果の画面が表示されます。

あわせて、報酬の付与方法を見直したバージョン2.0をApp Storeの審査に提出します。2.0では、報酬は視聴完了時に必ず「追加分析回数」として付与され、判定が失敗した場合も回数が残ります。
```

▼ English
```
The AI analysis that runs after a rewarded ad was failing for every user because the AI model we relied on had been retired, so the promised reward (one analysis) was not delivered. We fixed the server on November 12, 2026. The analysis now runs normally after the ad completes and the result is shown.

How to verify: open the app → choose a photo → with no free analyses left, tap the analyze button → watch the rewarded ad to the end → the result screen appears.

We are also submitting version 2.0 to App Store review, which changes how the reward is granted: the reward is always added as an "extra analysis" credit when the ad completes, and the credit is kept if the analysis fails.
```

▼ 繁體中文
```
獎勵廣告觀看完畢後執行的AI判定，因為所使用的AI模型停止提供而全部失敗，導致使用者無法獲得承諾的獎勵（判定1次）。我們已於2026年11月12日修正伺服器，目前在廣告觀看完畢後，判定可以正常執行並顯示結果。

確認方式：開啟App → 選擇一張照片 → 在免費次數為0的狀態下點擊判定按鈕 → 完整觀看獎勵廣告 → 顯示判定結果畫面。

此外，我們將提交調整獎勵發放方式的2.0版本至App Store審查。在2.0中，廣告觀看完畢時一定會以「額外分析次數」發放獎勵，即使判定失敗，次數也會保留。
```

### B. 2.0 公開後に申請する場合

▼ 日本語
```
リワード広告の視聴後に実行されるAI判定が、利用していたAIモデルの提供終了によりすべて失敗し、報酬が提供されない状態になっていました。サーバー側を修正し、さらにアプリをバージョン2.0に更新して、報酬の付与方法を変更しました。

・判定ボタンに「広告を見て判定する／見終わると、必ず1回判定できます」と、報酬の内容を視聴前に表示しています。
・報酬は広告の視聴完了時に、必ず「追加分析回数」+1として付与されます。
・回数が減るのは判定が成功したときだけです。通信エラーなどで判定が失敗しても回数は残り、広告を見直さずに再試行できます。

確認方法：アプリを起動 → 写真を1枚選ぶ → 無料回数が0の状態で判定ボタンを押す → リワード広告を最後まで視聴 → 判定結果の画面が表示されます。
```

▼ English
```
The AI analysis that runs after a rewarded ad was failing for every user because the AI model we relied on had been retired, so the promised reward was not delivered. We fixed the server and updated the app to version 2.0, which changes how the reward is granted.

• Before the ad, the button states the reward: "Watch Ad & Analyze / Finish the ad and you always get 1 analysis".
• When the ad completes, the reward is always granted as +1 "extra analysis" credit.
• A credit is only used when an analysis succeeds. If the analysis fails, for example because of a connection error, the credit is kept and the user can retry without watching another ad.

How to verify: open the app → choose a photo → with no free analyses left, tap the analyze button → watch the rewarded ad to the end → the result screen appears.
```

▼ 繁體中文
```
獎勵廣告觀看完畢後執行的AI判定，因為所使用的AI模型停止提供而全部失敗，導致無法發放獎勵。我們已修正伺服器，並將App更新至2.0版本，調整了獎勵的發放方式。

・觀看廣告前，按鈕上會顯示獎勵內容：「觀看廣告後判定／看完廣告，一定可以判定1次」。
・廣告觀看完畢時，一定會以「額外分析次數」+1 發放獎勵。
・只有判定成功時才會扣除次數。即使因網路錯誤等原因判定失敗，次數也會保留，無需再次觀看廣告即可重試。

確認方式：開啟App → 選擇一張照片 → 在免費次數為0的狀態下點擊判定按鈕 → 完整觀看獎勵廣告 → 顯示判定結果畫面。
```

---

## 4. リワード広告ポリシーとの照合

AdMob のリワード広告で求められる点と、2.0 の実装を照らし合わせたものです。

| 求められること | 2.0 の実装 | 該当箇所 |
|---|---|---|
| 視聴はユーザーが自分で選ぶ | 広告は判定ボタンを押したときだけ表示する。自動では表示しない | `AnalysisView.startAnalysisFlow` |
| 報酬の内容を視聴前に明示する | ボタンに「広告を見て判定する／見終わると、必ず1回判定できます」と表示 | `cta_ad` / `cta_ad_sub` |
| 視聴を完了したら約束した報酬を渡す | 報酬確定の時点で `extraChances` を +1 する | `showAd` の `onReward` |
| 報酬が失われない | 回数は判定が成功したときだけ減る。失敗しても残る | `consumeChance`（成功時のみ） |
| 途中で閉じた場合に不利益を与えない | 報酬未獲得で閉じたときは何も起きない。回数も減らない | `onDismiss` の `earned` |
| 広告を用意できないときの扱い | 読み込み中はボタンを無効にする。失敗時はタップで再読み込み。在庫がないときは広告なしで判定できる | `CTAState` |

2.0 では、最初の判定が終わるまで起動時広告とバナー広告を表示しません。

---

## 5. テストデバイスの登録

自分の本番広告を繰り返し見たりタップしたりすると、無効なトラフィックと判定されることがあります。審査中は特に避けてください。

方法は2つあります。

**AdMob の管理画面で登録する（コード変更なし）**

1. AdMob → 設定 → 「テストデバイス」→「テストデバイスを追加」。
2. プラットフォームに iOS を選び、端末の広告 ID（IDFA）を入力する。
3. 登録後、広告に「テスト広告」のラベルが出ることを確認してからテストする。

このアプリは ATT の許可を求めていないため、端末の IDFA が取得できず、この方法では登録できないことがあります。その場合は次の方法を使います。

**コードで指定する（デバッグ時のみ）**

Xcode から実機で起動すると、広告を読み込んだときのログに、この端末をテストデバイスにするための ID が表示されます。その ID を `MobileAds.shared.requestConfiguration.testDeviceIdentifiers` に設定します。リリースビルドに入らないよう `#if DEBUG` で囲んでください。必要ならこちらで追加します。

---

## 6. AdMob でほかに確認すること

提出前に一度見ておく項目です。該当しなければ対応は不要です。

- **app-ads.txt**: AdMob → アプリ → app-ads.txt の状態が「承認済み」か。未設定だと配信が制限されることがあります。App Store Connect の「マーケティング URL」に登録したサイトの直下に `app-ads.txt` を置きます。
- **EEA・英国・スイスへの配信**: これらの地域で配信する場合、Google 認定の同意管理（AdMob の「プライバシーとメッセージ」の GDPR メッセージ）が必要です。現在のアプリには同意メッセージの表示（UMP SDK）が入っていません。該当地域で公開しているなら、次のリリースで対応が必要です。
- **ATT（App Tracking Transparency）**: 現在のアプリは ATT の許可ダイアログを出していません。この状態ではパーソナライズ広告は限定的になります。収益を上げたい場合の検討項目で、ポリシー上の必須ではありません。
- **広告ユニット**: リワード（`…/1338217532`）、バナー（`…/6056788210`）、起動時（`…/9709092766`）の3つ。リワードの報酬設定（数量・アイテム名）は、アプリ側では数量を使わず「視聴完了 = 1回」として扱っています。

---

## 7. Gemini API（Google AI / Google Cloud）で確認すること

今回の障害は、アプリが指定していたモデルの提供終了が原因でした。再発を防ぐための確認項目です。

- **課金プラン**: Google AI Studio の API キーが無料枠のままだと、送信した内容が Google のサービス改善に使われる規約になっていることがあります。アプリは「アプリには保存しません」と表示していますが、Google 側の扱いは別です。課金を有効にしたプロジェクトのキーに切り替えることを勧めます。プライバシーポリシーの記載もそれに合わせます。
- **モデルの切り替え**: 使用モデルは Cloud Run の環境変数 `GEMINI_MODELS`（カンマ区切り、先頭から順に試す）で変えられます。未設定時は `gemini-2.5-flash,gemini-3.8-flash` です。アプリの更新は不要です。
- **提供終了の通知**: Google AI のモデル提供終了の案内（メール、リリースノート）を受け取れる状態にしておく。
- **エラー率の監視**: Cloud Run → 該当サービス → 指標で、4xx / 5xx の割合にアラートを設定する。今回は判定成功率が 0% のまま2か月気づけませんでした。
- **プロキシの認証トークンと回数制限**: トークンは Git に入れない形に変え、プロキシに回数制限を入れました。Cloud Run への新しいトークンの登録が必要です。手順は `PROXY_TOKEN.md` にあります。
