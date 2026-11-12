# GitHub Pages（サポート・プライバシーの公開ページ）

App Store Connect に登録する URL のページを、GitHub Pages で公開しています。
以前の `https://appfreelife.com/?p=244` はリンク切れのため、こちらに移しました。

## 目次

1. [App Store Connect に登録する URL](#1-app-store-connect-に登録する-url)
2. [ページの内容](#2-ページの内容)
3. [仕組み](#3-仕組み)
4. [文面を変えるとき](#4-文面を変えるとき)
5. [確認しておくこと](#5-確認しておくこと)
6. [うまく表示されないとき](#6-うまく表示されないとき)

---

## 1. App Store Connect に登録する URL

| 項目 | URL | 登録する場所 |
|---|---|---|
| サポート URL | https://changch223.github.io/love-signal-ai/support.html | アプリのバージョンページ（言語ごと） |
| マーケティング URL | https://changch223.github.io/love-signal-ai/ | アプリのバージョンページ（言語ごと） |
| プライバシーポリシー URL | https://changch223.github.io/love-signal-ai/privacy.html | 「App のプライバシー」（言語ごと） |
| ユーザプライバシー選択 URL | https://changch223.github.io/love-signal-ai/privacy-choices.html | 「App のプライバシー」（任意の項目） |

- 4言語（日本語・英語・簡体字・繁体字）を1ページにまとめてあるので、全言語に同じ URL を登録できます。
- 言語を指定してリンクしたい場合は、末尾に `#ja` `#en` `#zh-hans` `#zh-hant` を付けます。例: `…/privacy.html#en`
- サポート URL とマーケティング URL は、審査中のバージョンでは変更できないことがあります。その場合は、審査が終わってから、または次のバージョンを作るときに差し替えてください。プライバシーポリシー URL は「App のプライバシー」からいつでも変更できます。

---

## 2. ページの内容

| ページ | ファイル | 内容 |
|---|---|---|
| ホーム | `docs/index.html` | アプリの紹介、スクリーンショット4枚、App Store へのリンク |
| サポート | `docs/support.html` | よくある質問（判定できない、回数、広告、写真の扱い）と問い合わせ先 |
| プライバシーポリシー | `docs/privacy.html` | 送信する情報、広告、端末内の情報、収集しない情報、写真へのアクセス |
| プライバシーの選択 | `docs/privacy-choices.html` | AIへの送信、端末内のデータ、広告の設定、写真の許可を変える方法 |

- 運営者名は「Chia-Wei Chang」としています。
- 問い合わせ先は GitHub の Issues（https://github.com/changch223/love-signal-ai/issues）です。メールアドレスは載せていません。

---

## 3. 仕組み

- リポジトリ `changch223/love-signal-ai`（ローカルのフォルダ名は `myakuari`）の、`main` ブランチの `docs/` フォルダをそのまま公開しています。
- `main` に push すると、1〜2分で公開ページに反映されます。
- 設定の場所: GitHub のリポジトリ → Settings → Pages（Source: Deploy from a branch、Branch: `main` / `/docs`）。
- `docs/.nojekyll` は、GitHub にファイルを加工させずそのまま配信させるための空ファイルです。消さないでください。
- 公開には、リポジトリが公開（Public）である必要があります（無料プランの場合）。リポジトリを非公開にすると、これらの URL は表示されなくなります。

```
docs/
├── index.html            ホーム（マーケティング URL）
├── support.html          サポート URL
├── privacy.html          プライバシーポリシー URL
├── privacy-choices.html  ユーザプライバシー選択 URL
├── img/                  アイコンとスクリーンショット
└── .nojekyll
```

---

## 4. 文面を変えるとき

ページは `appstore/tools/build_site.py` から生成しています。4言語の文面はこのスクリプトの中にあります。

1. `appstore/tools/build_site.py` の該当する文面を書き換える。
2. 実行する（Pillow が必要です。`pip install pillow`）。

   ```
   python3 appstore/tools/build_site.py
   ```

3. `docs/` をコミットして `main` に push する。

`docs/*.html` を直接書き換えても公開はされますが、次にスクリプトを実行すると上書きされます。変更はスクリプト側に入れてください。

プライバシーポリシーを変えたときは、スクリプト内の `UPDATED`（最終更新日）も直します。`appstore/PRIVACY_POLICY.md` は同じ内容の控えなので、あわせて更新してください。

---

## 5. 確認しておくこと

- **問い合わせ先。** GitHub の Issues は、GitHub のアカウントがない人には使えません。問い合わせ用のメールアドレスがあれば、サポートページとプライバシーポリシーに載せることを勧めます。
- **運営者名。** 個人名で公開されます。屋号などに変えたい場合は、スクリプト内の「Chia-Wei Chang」を置き換えます。
- **app-ads.txt。** AdMob 用の `app-ads.txt` は、別のリポジトリ `changch223/changch223.github.io` にあり、https://changch223.github.io/app-ads.txt で公開されています。マーケティング URL を同じドメイン（`changch223.github.io`）にしたので、AdMob はこのファイルを見つけられます。URL を登録したあと、AdMob → アプリ → app-ads.txt の状態が「承認済み」になっているか確認してください（反映に1日ほどかかることがあります）。
- **旧 URL。** `https://appfreelife.com/?p=244` を参照している場所（AdMob のアプリ設定、SNS のプロフィールなど）がほかにあれば、あわせて差し替えてください。

---

## 6. うまく表示されないとき

| 症状 | 確認すること |
|---|---|
| 404 になる | URL が `love-signal-ai` になっているか（`myakuari` では表示されません）。push から2分ほど待ったか |
| 変更が反映されない | GitHub のリポジトリ → Actions に「pages build and deployment」の失敗がないか。ブラウザのキャッシュを消して再読み込みしたか |
| 画像が出ない | `docs/img/` がコミットされているか |
| すべて表示されなくなった | リポジトリが非公開になっていないか。Settings → Pages の設定が `main` / `/docs` のままか |
