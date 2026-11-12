#!/usr/bin/env python3
"""GitHub Pages 用のページ（docs/）を生成する。

  python3 appstore/tools/build_site.py

docs/ の index.html / support.html / privacy.html / privacy-choices.html と
docs/img/ を上書きする。文面を変えるときはこのファイルを編集して実行する。Pillow が必要。
"""
import pathlib
from PIL import Image
R = pathlib.Path(__file__).resolve().parents[2]; D = R / "docs"
(D / "img").mkdir(parents=True, exist_ok=True)
ISSUES = "https://github.com/changch223/love-signal-ai/issues"
STORE = "https://apps.apple.com/app/id6744615409"
UPDATED = {"ja": "2026年11月12日", "en": "November 12, 2026", "zh-hans": "2026年11月12日", "zh-hant": "2026年11月12日"}
LANGS = [("ja", "日本語", "ja"), ("en", "English", "en"), ("zh-hans", "简体中文", "zh-Hans"), ("zh-hant", "繁體中文", "zh-Hant")]
APP = {"ja": "脈ありAIジャッジ", "en": "Love Signal AI", "zh-hans": "恋爱信号AI判定", "zh-hant": "戀愛訊號AI判定"}

Image.open(R / "icon/icon.png").convert("RGB").resize((256, 256), Image.LANCZOS).save(D / "img/icon.png")
for n in ["01_result", "02_input", "03_loading", "04_home"]:
    im = Image.open(R / f"appstore/screenshots-6.3/ja/{n}.png").convert("RGB")
    im.resize((480, round(480 * im.height / im.width)), Image.LANCZOS).save(D / f"img/{n}.jpg", quality=86)

CSS = """
:root{--ink:#5A3038;--sub:#8C6A72;--pink:#E84C7A;--line:#F1D5DB;--bg1:#FFE3E6;--bg2:#FFF6EE;--card:#fff}
*{box-sizing:border-box}
body{margin:0;background:linear-gradient(var(--bg1),var(--bg2)) fixed;color:var(--ink);font:16px/1.85 -apple-system,BlinkMacSystemFont,"Hiragino Sans","PingFang SC","PingFang TC","Noto Sans JP",sans-serif}
.wrap{max-width:760px;margin:0 auto;padding:24px 20px 64px}
header{display:flex;flex-wrap:wrap;gap:12px 20px;align-items:center;justify-content:space-between;margin-bottom:28px}
.brand{display:flex;align-items:center;gap:10px;font-weight:800;font-size:18px;color:var(--ink);text-decoration:none}
.brand img{width:40px;height:40px;border-radius:10px}
nav{display:flex;flex-wrap:wrap;gap:6px 16px;font-size:14px}
a{color:var(--pink)}
.langs{display:flex;flex-wrap:wrap;gap:8px;margin:0 0 24px;padding:0;list-style:none;font-size:14px}
.langs a{display:block;padding:4px 14px;border:1px solid var(--line);border-radius:99px;background:var(--card);text-decoration:none;font-weight:700}
section{background:var(--card);border:1px solid var(--line);border-radius:18px;padding:24px;margin-bottom:24px}
h1{font-size:26px;line-height:1.4;margin:0 0 6px}
h2{font-size:17px;margin:26px 0 6px}
p,ul{margin:0 0 10px}
ul{padding-left:1.3em}
.meta{color:var(--sub);font-size:14px}
.cta{display:inline-block;margin:10px 0 4px;padding:10px 26px;border-radius:99px;background:var(--pink);color:#fff;font-weight:800;text-decoration:none}
.shots{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin:0 0 24px}
.shots img{width:100%;height:auto;border-radius:14px;display:block}
footer{color:var(--sub);font-size:13px;text-align:center;margin-top:32px}
"""
NAV = {"index.html": {"ja": "ホーム", "en": "Home"}, "support.html": {"ja": "サポート", "en": "Support"},
       "privacy.html": {"ja": "プライバシーポリシー", "en": "Privacy"}, "privacy-choices.html": {"ja": "プライバシーの選択", "en": "Privacy Choices"}}

def page(fname, title, sections, extra=""):
    nav = "".join(f'<a href="./{"" if f == "index.html" else f}">{t["ja"]} / {t["en"]}</a>' for f, t in NAV.items())
    langs = "".join(f'<li><a href="#{k}">{n}</a></li>' for k, n, _ in LANGS)
    body = "".join(f'<section id="{k}" lang="{code}">{sections[k]}</section>' for k, _, code in LANGS)
    (D / fname).write_text(f"""<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<link rel="icon" href="img/icon.png">
<style>{CSS}</style>
</head>
<body>
<div class="wrap">
<header><a class="brand" href="./"><img src="img/icon.png" alt="">脈ありAIジャッジ</a><nav>{nav}</nav></header>
{extra}
<ul class="langs">{langs}</ul>
{body}
<footer>© 2026 Chia-Wei Chang</footer>
</div>
</body>
</html>
""", encoding="utf-8")

# ---------- index (marketing) ----------
shots = '<div class="shots">' + "".join(f'<img src="img/{n}.jpg" alt="" loading="lazy">' for n in ["01_result", "02_input", "03_loading", "04_home"]) + "</div>"
index = {
"ja": f"""<h1>脈ありAIジャッジ</h1><p class="meta">写真やトーク画面で、AIが「脈あり度」を判定</p>
<p>ふたりの写真やトークのスクリーンショットを選ぶだけ。AIが脈あり度を 1〜100% で判定し、そう見えた理由と次の一手をアドバイスします。</p>
<ul><li>写真やスクリーンショットは最大3枚まで</li><li>毎日1回は無料。広告を見ると1回分が追加されます</li><li>回数が減るのは、判定に成功したときだけ</li><li>写真は判定のためにAIへ送信し、アプリには保存しません</li></ul>
<a class="cta" href="{STORE}">App Store で見る</a>
<p class="meta">AIの判定は参考としてお楽しみください。<a href="support.html#ja">サポート</a>・<a href="privacy.html#ja">プライバシーポリシー</a></p>""",
"en": f"""<h1>Love Signal AI</h1><p class="meta">AI reads your love signal from photos and chats</p>
<p>Pick a photo of the two of you or a chat screenshot. AI rates your love signal from 1 to 100%, explains why, and suggests your next move.</p>
<ul><li>Up to 3 photos or screenshots</li><li>One free analysis every day. Watch an ad to get one more</li><li>An analysis is only counted when it succeeds</li><li>Photos are sent to AI for the analysis and are not stored in the app</li></ul>
<a class="cta" href="{STORE}">View on the App Store</a>
<p class="meta">AI results are for entertainment and reference only. <a href="support.html#en">Support</a> · <a href="privacy.html#en">Privacy Policy</a></p>""",
"zh-hans": f"""<h1>恋爱信号AI判定</h1><p class="meta">用合照或聊天截图，AI判定恋爱信号</p>
<p>只需选择两人的合照或聊天截图，AI就会以 1〜100% 判定恋爱信号，并告诉你理由和下一步建议。</p>
<ul><li>最多可选择3张照片或截图</li><li>每天可免费判定1次，观看广告可增加1次</li><li>只有判定成功时才会扣除次数</li><li>照片仅为判定发送给AI，不会保存在应用中</li></ul>
<a class="cta" href="{STORE}">在 App Store 查看</a>
<p class="meta">AI的判定仅供娱乐和参考。<a href="support.html#zh-hans">支持</a>・<a href="privacy.html#zh-hans">隐私政策</a></p>""",
"zh-hant": f"""<h1>戀愛訊號AI判定</h1><p class="meta">用合照或聊天截圖，AI判定戀愛訊號</p>
<p>只要選擇兩人的合照或聊天截圖，AI就會以 1〜100% 判定戀愛訊號，並告訴你理由和下一步建議。</p>
<ul><li>最多可選擇3張照片或截圖</li><li>每天可免費判定1次，觀看廣告可增加1次</li><li>只有判定成功時才會扣除次數</li><li>照片僅為判定傳送給AI，不會保存在應用程式中</li></ul>
<a class="cta" href="{STORE}">在 App Store 查看</a>
<p class="meta">AI的判定僅供娛樂和參考。<a href="support.html#zh-hant">支援</a>・<a href="privacy.html#zh-hant">隱私權政策</a></p>""",
}
page("index.html", "脈ありAIジャッジ / Love Signal AI", index, shots)

# ---------- support ----------
support = {
"ja": f"""<h1>サポート</h1><p class="meta">脈ありAIジャッジ</p>
<h2>判定できない・エラーが出る</h2><p>App Store でアプリを最新版に更新し、通信環境の良いところでもう一度お試しください。バージョン2.0以降では、判定に失敗しても回数は減りません。</p>
<h2>回数について</h2><p>毎日1回、無料で判定できます（日付が変わると戻ります）。回数がないときは、広告を最後まで見ると1回分が追加されます。追加された回数は、判定に失敗しても残ります。</p>
<h2>広告を見たのに判定できなかった</h2><p>バージョン2.0以降では、広告で得た回数は「追加」として残っています。入力画面でもう一度判定ボタンを押してください。広告は出ません。</p>
<h2>写真の扱い</h2><p>選んだ写真と補足は、判定のためにAI（Google の Gemini）へ送信されます。アプリにも運営者のサーバーにも保存しません。詳しくは<a href="privacy.html#ja">プライバシーポリシー</a>をご覧ください。</p>
<h2>お問い合わせ</h2><p>不具合の報告やご質問は、<a href="{ISSUES}">GitHub の Issues</a> からお送りください。端末の機種、iOS のバージョン、アプリのバージョン、表示されたメッセージを書いていただけると助かります。</p>""",
"en": f"""<h1>Support</h1><p class="meta">Love Signal AI</p>
<h2>The analysis fails or shows an error</h2><p>Update the app to the latest version on the App Store and try again with a good connection. From version 2.0, a failed analysis is not counted.</p>
<h2>About analyses</h2><p>You get one free analysis every day (it refreshes when the date changes). When you have none left, watch an ad to the end to get one more. An extra analysis is kept if the analysis fails.</p>
<h2>I watched an ad but got no result</h2><p>From version 2.0, the analysis you earned is kept as "Extra". Tap the analyze button again on the input screen. No ad will play.</p>
<h2>Your photos</h2><p>The photos and notes you choose are sent to AI (Google's Gemini) to create the analysis. They are not stored in the app or on our server. See the <a href="privacy.html#en">Privacy Policy</a>.</p>
<h2>Contact</h2><p>To report a problem or ask a question, please open an issue on <a href="{ISSUES}">GitHub Issues</a>. Including your device model, iOS version, app version and the message you saw helps a lot.</p>""",
"zh-hans": f"""<h1>支持</h1><p class="meta">恋爱信号AI判定</p>
<h2>无法判定或出现错误</h2><p>请在 App Store 将应用更新到最新版本，并在网络良好的环境下重试。2.0及以上版本中，判定失败不会扣除次数。</p>
<h2>关于次数</h2><p>每天可免费判定1次（日期变更后恢复）。没有次数时，完整观看广告即可增加1次。增加的次数在判定失败时会保留。</p>
<h2>看了广告却没有判定结果</h2><p>2.0及以上版本中，通过广告获得的次数会保留为“额外”。请在输入页面再次点击判定按钮，不会再播放广告。</p>
<h2>关于照片</h2><p>你选择的照片和补充说明会发送给AI（Google 的 Gemini）用于判定，不会保存在应用或运营者的服务器中。详情请查看<a href="privacy.html#zh-hans">隐私政策</a>。</p>
<h2>联系我们</h2><p>如需反馈问题或咨询，请通过 <a href="{ISSUES}">GitHub Issues</a> 联系。请附上设备型号、iOS 版本、应用版本和显示的提示信息。</p>""",
"zh-hant": f"""<h1>支援</h1><p class="meta">戀愛訊號AI判定</p>
<h2>無法判定或出現錯誤</h2><p>請在 App Store 將 App 更新到最新版本，並在網路良好的環境下重試。2.0以上版本中，判定失敗不會扣除次數。</p>
<h2>關於次數</h2><p>每天可免費判定1次（日期變更後恢復）。沒有次數時，完整觀看廣告即可增加1次。增加的次數在判定失敗時會保留。</p>
<h2>看了廣告卻沒有判定結果</h2><p>2.0以上版本中，透過廣告獲得的次數會保留為「額外」。請在輸入頁面再次點擊判定按鈕，不會再播放廣告。</p>
<h2>關於照片</h2><p>你選擇的照片和補充說明會傳送給AI（Google 的 Gemini）用於判定，不會保存在 App 或營運者的伺服器中。詳情請參閱<a href="privacy.html#zh-hant">隱私權政策</a>。</p>
<h2>聯絡我們</h2><p>如需回報問題或詢問，請透過 <a href="{ISSUES}">GitHub Issues</a> 聯絡。請附上裝置型號、iOS 版本、App 版本和顯示的訊息。</p>""",
}
page("support.html", "サポート / Support - 脈ありAIジャッジ", support)

# ---------- privacy ----------
G1 = "https://policies.google.com/privacy"; G2 = "https://policies.google.com/technologies/partner-sites"
privacy = {
"ja": f"""<h1>プライバシーポリシー</h1><p class="meta">脈ありAIジャッジ ／ 最終更新日: {UPDATED['ja']}</p>
<p>「脈ありAIジャッジ」（以下「本アプリ」）は、Chia-Wei Chang（以下「運営者」）が提供します。</p>
<h2>1. 判定のために送信する情報</h2><p>判定を行うとき、あなたが選んだ写真（最大3枚）と、入力した補足のテキストを送信します。これらは運営者の中継サーバーを経由して Google LLC の生成AIサービス（Gemini API）へ送信され、判定結果の作成にのみ使われます。初めて判定を行う前に、アプリ内で送信についての同意を確認します。</p><p>運営者は、送信された写真・テキスト・判定結果を、アプリ内にも中継サーバーにも保存しません。Google による取り扱いは、Google の規約とプライバシーポリシーに従います。</p>
<h2>2. 広告のために収集される情報</h2><p>本アプリは Google AdMob による広告を表示します。AdMob は、広告の配信・効果測定・不正防止のために、端末の情報（端末の種類、OS、IPアドレス、広告の表示や操作の記録など）を収集することがあります。詳しくは <a href="{G1}">Google プライバシーポリシー</a>と、<a href="{G2}">Google のサービスを使用するサイトやアプリから収集した情報の利用</a>をご確認ください。</p>
<h2>3. 端末内に保存する情報</h2><p>次の情報は端末内にのみ保存し、外部へ送信しません。アプリを削除すると消えます。</p><ul><li>残りの分析回数と、無料回数を最後に更新した日</li><li>AIへの送信に同意したかどうか</li><li>判定を1回以上完了したかどうか</li></ul>
<h2>4. 収集しない情報</h2><p>本アプリはアカウント登録を必要とせず、氏名・メールアドレス・電話番号・位置情報・連絡先を収集しません。</p>
<h2>5. 写真へのアクセス</h2><p>写真の選択には iOS 標準の写真選択画面を使います。本アプリが受け取るのは、あなたが選んだ写真だけです。判定結果の画像を保存するときにのみ、写真への追加の許可を求めます。</p>
<h2>6. お子さまの利用</h2><p>本アプリは13歳未満の方を対象としていません。</p>
<h2>7. 変更</h2><p>本ポリシーを変更する場合は、このページで告知します。</p>
<h2>8. お問い合わせ</h2><p>Chia-Wei Chang ／ <a href="{ISSUES}">GitHub の Issues</a></p>""",
"en": f"""<h1>Privacy Policy</h1><p class="meta">Love Signal AI / Last updated: {UPDATED['en']}</p>
<p>"Love Signal AI" (the "App") is provided by Chia-Wei Chang ("we").</p>
<h2>1. Information sent for an analysis</h2><p>When you run an analysis, the photos you choose (up to 3) and the optional note you type are sent through our relay server to Google LLC's generative AI service (Gemini API) and are used only to create your result. The App asks for your consent before your first analysis.</p><p>We do not store your photos, notes or results in the App or on our relay server. Google's handling of the data is governed by Google's terms and privacy policy.</p>
<h2>2. Advertising</h2><p>The App shows ads through Google AdMob. AdMob may collect device information (such as device type, OS, IP address and ad interaction data) to deliver and measure ads and to prevent fraud. See the <a href="{G1}">Google Privacy Policy</a> and <a href="{G2}">How Google uses information from sites or apps that use its services</a>.</p>
<h2>3. Stored on your device only</h2><p>The following is stored only on your device, is not sent anywhere, and is removed when you delete the App.</p><ul><li>The number of analyses you have left and the date your free analysis was last refreshed</li><li>Whether you agreed to sending data to AI</li><li>Whether you have completed an analysis</li></ul>
<h2>4. Not collected</h2><p>The App requires no account and does not collect your name, email address, phone number, location or contacts.</p>
<h2>5. Photo access</h2><p>Photos are chosen with the standard iOS photo picker, so the App only receives the photos you select. Add-only photo library permission is requested only when you save your result image.</p>
<h2>6. Children</h2><p>The App is not directed to children under 13.</p>
<h2>7. Changes</h2><p>Changes to this policy will be posted on this page.</p>
<h2>8. Contact</h2><p>Chia-Wei Chang / <a href="{ISSUES}">GitHub Issues</a></p>""",
"zh-hans": f"""<h1>隐私政策</h1><p class="meta">恋爱信号AI判定 ／ 最后更新：{UPDATED['zh-hans']}</p>
<p>“恋爱信号AI判定”（以下简称“本应用”）由 Chia-Wei Chang（以下简称“运营者”）提供。</p>
<h2>1. 为判定而发送的信息</h2><p>进行判定时，会发送你选择的照片（最多3张）和输入的补充说明。这些内容经由运营者的中转服务器发送至 Google LLC 的生成式AI服务（Gemini API），仅用于生成判定结果。首次判定前，应用内会先征求你的同意。</p><p>运营者不会在应用内或中转服务器上保存发送的照片、文字和判定结果。Google 对数据的处理遵循 Google 的条款和隐私政策。</p>
<h2>2. 为广告而收集的信息</h2><p>本应用通过 Google AdMob 展示广告。AdMob 可能会为投放广告、衡量效果和防止欺诈而收集设备信息（设备类型、操作系统、IP 地址、广告展示和操作记录等）。详情请参阅 <a href="{G1}">Google 隐私政策</a>和 <a href="{G2}">Google 如何使用来自合作网站或应用的信息</a>。</p>
<h2>3. 仅保存在设备上的信息</h2><p>以下信息仅保存在设备上，不会发送到外部，删除应用后即被清除。</p><ul><li>剩余分析次数，以及免费次数最后更新的日期</li><li>是否已同意向AI发送数据</li><li>是否已完成过至少一次判定</li></ul>
<h2>4. 不收集的信息</h2><p>本应用无需注册账号，不收集姓名、电子邮箱、电话号码、位置信息或通讯录。</p>
<h2>5. 照片访问</h2><p>选择照片时使用 iOS 标准的照片选择界面，本应用只会获得你选择的照片。仅在保存判定结果图片时，才会请求向相册添加照片的权限。</p>
<h2>6. 儿童</h2><p>本应用不面向13岁以下的儿童。</p>
<h2>7. 变更</h2><p>本政策如有变更，将在本页面公布。</p>
<h2>8. 联系方式</h2><p>Chia-Wei Chang ／ <a href="{ISSUES}">GitHub Issues</a></p>""",
"zh-hant": f"""<h1>隱私權政策</h1><p class="meta">戀愛訊號AI判定 ／ 最後更新：{UPDATED['zh-hant']}</p>
<p>「戀愛訊號AI判定」（以下稱「本 App」）由 Chia-Wei Chang（以下稱「營運者」）提供。</p>
<h2>1. 為判定而傳送的資訊</h2><p>進行判定時，會傳送你選擇的照片（最多3張）和輸入的補充說明。這些內容經由營運者的中繼伺服器傳送至 Google LLC 的生成式AI服務（Gemini API），僅用於產生判定結果。首次判定前，App 內會先徵求你的同意。</p><p>營運者不會在 App 內或中繼伺服器上保存傳送的照片、文字和判定結果。Google 對資料的處理依照 Google 的條款和隱私權政策。</p>
<h2>2. 為廣告而收集的資訊</h2><p>本 App 透過 Google AdMob 顯示廣告。AdMob 可能會為了放送廣告、評估成效和防止詐欺而收集裝置資訊（裝置類型、作業系統、IP 位址、廣告顯示和操作記錄等）。詳情請參閱 <a href="{G1}">Google 隱私權政策</a>和 <a href="{G2}">Google 如何使用來自合作夥伴網站或應用程式的資訊</a>。</p>
<h2>3. 僅保存在裝置上的資訊</h2><p>以下資訊僅保存在裝置上，不會傳送到外部，刪除 App 後即會清除。</p><ul><li>剩餘分析次數，以及免費次數最後更新的日期</li><li>是否已同意向AI傳送資料</li><li>是否已完成過至少一次判定</li></ul>
<h2>4. 不收集的資訊</h2><p>本 App 不需註冊帳號，不收集姓名、電子郵件、電話號碼、位置資訊或聯絡人。</p>
<h2>5. 照片存取</h2><p>選擇照片時使用 iOS 標準的照片選擇畫面，本 App 只會取得你選擇的照片。僅在儲存判定結果圖片時，才會要求加入照片的權限。</p>
<h2>6. 兒童</h2><p>本 App 不以13歲以下的兒童為對象。</p>
<h2>7. 變更</h2><p>本政策如有變更，將在本頁面公告。</p>
<h2>8. 聯絡方式</h2><p>Chia-Wei Chang ／ <a href="{ISSUES}">GitHub Issues</a></p>""",
}
page("privacy.html", "プライバシーポリシー / Privacy Policy - 脈ありAIジャッジ", privacy)

# ---------- privacy choices ----------
ADS = "https://myadcenter.google.com/"
choices = {
"ja": f"""<h1>プライバシーの選択</h1><p class="meta">脈ありAIジャッジ ／ 最終更新日: {UPDATED['ja']}</p>
<p>本アプリにはアカウントがなく、運営者はあなたの写真・テキスト・判定結果を保存していません。そのため、運営者側で削除・開示するデータはありません。あなたが選べることは次のとおりです。</p>
<h2>AIへの送信</h2><p>写真と補足は、あなたが判定ボタンを押し、初回の確認で同意したときにだけ送信されます。送信したくない場合は、判定を行わないでください。同意の状態は、アプリを削除すると消えます。</p>
<h2>端末内のデータ</h2><p>分析回数などの設定は端末内にのみ保存されています。アプリを削除するとすべて消えます。</p>
<h2>広告</h2><p>広告のパーソナライズは、iPhone の「設定」→「プライバシーとセキュリティ」→「トラッキング」および「Apple の広告」で制限できます。Google の広告設定は <a href="{ADS}">マイ アド センター</a>で変更できます。</p>
<h2>写真へのアクセス</h2><p>写真への追加の許可は、iPhone の「設定」→「アプリ」→ 本アプリ →「写真」でいつでも変更できます。</p>
<h2>お問い合わせ</h2><p><a href="{ISSUES}">GitHub の Issues</a> ／ <a href="privacy.html#ja">プライバシーポリシー</a></p>""",
"en": f"""<h1>Your Privacy Choices</h1><p class="meta">Love Signal AI / Last updated: {UPDATED['en']}</p>
<p>The App has no accounts, and we do not store your photos, notes or results. There is therefore no data held by us to delete or disclose. Your choices are below.</p>
<h2>Sending to AI</h2><p>Photos and notes are sent only when you tap the analyze button and have agreed in the first-use dialog. If you do not want them sent, do not run an analysis. Your consent status is removed when you delete the App.</p>
<h2>Data on your device</h2><p>Settings such as your remaining analyses are stored only on your device. Deleting the App removes all of them.</p>
<h2>Advertising</h2><p>You can limit ad personalization on your iPhone in Settings → Privacy &amp; Security → Tracking, and → Apple Advertising. You can change your Google ad settings in <a href="{ADS}">My Ad Center</a>.</p>
<h2>Photo access</h2><p>You can change the add-only photo permission at any time in Settings → Apps → this App → Photos.</p>
<h2>Contact</h2><p><a href="{ISSUES}">GitHub Issues</a> / <a href="privacy.html#en">Privacy Policy</a></p>""",
"zh-hans": f"""<h1>隐私选择</h1><p class="meta">恋爱信号AI判定 ／ 最后更新：{UPDATED['zh-hans']}</p>
<p>本应用没有账号，运营者不保存你的照片、文字和判定结果，因此运营者一方没有可删除或披露的数据。你可以做出以下选择。</p>
<h2>发送给AI</h2><p>只有在你点击判定按钮并在首次确认中同意后，照片和补充说明才会被发送。如果不希望发送，请不要进行判定。删除应用后，同意状态会被清除。</p>
<h2>设备上的数据</h2><p>分析次数等设置仅保存在设备上，删除应用后会全部清除。</p>
<h2>广告</h2><p>你可以在 iPhone 的“设置”→“隐私与安全性”→“跟踪”以及“Apple 广告”中限制广告个性化。Google 的广告设置可在<a href="{ADS}">我的广告中心</a>更改。</p>
<h2>照片访问</h2><p>你可以随时在 iPhone 的“设置”→“App”→ 本应用 →“照片”中更改权限。</p>
<h2>联系方式</h2><p><a href="{ISSUES}">GitHub Issues</a> ／ <a href="privacy.html#zh-hans">隐私政策</a></p>""",
"zh-hant": f"""<h1>隱私權選擇</h1><p class="meta">戀愛訊號AI判定 ／ 最後更新：{UPDATED['zh-hant']}</p>
<p>本 App 沒有帳號，營運者不保存你的照片、文字和判定結果，因此營運者一方沒有可刪除或揭露的資料。你可以做出以下選擇。</p>
<h2>傳送給AI</h2><p>只有在你點擊判定按鈕並在首次確認中同意後，照片和補充說明才會被傳送。如果不希望傳送，請不要進行判定。刪除 App 後，同意狀態會被清除。</p>
<h2>裝置上的資料</h2><p>分析次數等設定僅保存在裝置上，刪除 App 後會全部清除。</p>
<h2>廣告</h2><p>你可以在 iPhone 的「設定」→「隱私權與安全性」→「追蹤」以及「Apple 廣告」中限制廣告個人化。Google 的廣告設定可在<a href="{ADS}">我的廣告中心</a>變更。</p>
<h2>照片存取</h2><p>你可以隨時在 iPhone 的「設定」→「App」→ 本 App →「照片」中變更權限。</p>
<h2>聯絡方式</h2><p><a href="{ISSUES}">GitHub Issues</a> ／ <a href="privacy.html#zh-hant">隱私權政策</a></p>""",
}
page("privacy-choices.html", "プライバシーの選択 / Your Privacy Choices - 脈ありAIジャッジ", choices)
print(sorted(p.name for p in D.iterdir()), sorted(p.name for p in (D/"img").iterdir()))
