#!/usr/bin/env python3
"""App Store 用スクリーンショット（1320x2868, 6.9インチ）を生成する。

  python3 appstore/tools/make_screenshots.py [作業用ディレクトリ]

screenshots-raw/<言語>/<画面>.png（シミュレータの素の画面）に見出しと端末枠を付けて
screenshots/<言語>/ に書き出す。Google Chrome と Pillow が必要。
"""
import html, pathlib, subprocess, sys, tempfile
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[1]
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1320, 2868

# 掲載順: 結果 → 入力 → 判定中 → ホーム
SLIDES = ["result", "input", "loading", "home"]
HEADLINES = {
    "ja":      ["AIがふたりの\n「脈あり度」を判定", "写真かトーク画面を\n選ぶだけ", "約10秒で\n結果とアドバイス", "毎日1回、\n無料で判定"],
    "en":      ["AI reads your\nlove signal", "Just pick a photo\nor a chat screenshot", "Result and advice\nin about 10 seconds", "One free analysis\nevery day"],
    "zh-Hans": ["AI判定两人的\n恋爱信号", "只需选择合照\n或聊天截图", "约10秒得到\n结果与建议", "每天免费\n判定1次"],
    "zh-Hant": ["AI判定兩人的\n戀愛訊號", "只要選擇合照\n或聊天截圖", "約10秒得到\n結果與建議", "每天免費\n判定1次"],
}
FONTS = {
    "ja": '"Hiragino Sans","Hiragino Kaku Gothic ProN",sans-serif',
    "en": '"SF Pro Rounded","SF Pro Display",-apple-system,"Helvetica Neue",sans-serif',
    "zh-Hans": '"PingFang SC",sans-serif',
    "zh-Hant": '"PingFang TC",sans-serif',
}

PAGE = """<!doctype html><html lang="{lang}"><meta charset="utf-8"><style>
html,body{{margin:0;width:{w}px;height:{h}px;overflow:hidden}}
body{{background:radial-gradient(900px 700px at 85% 4%,#FFC4D2 0%,rgba(255,196,210,0) 70%),linear-gradient(#FFDDE2,#FFF4EA);
  font-family:{font};display:flex;flex-direction:column;align-items:center}}
h1{{margin:0;height:590px;box-sizing:border-box;padding:150px 70px 0;display:flex;align-items:center;justify-content:center;
  text-align:center;white-space:pre-line;font-size:{size}px;line-height:1.28;font-weight:800;color:#5A3038;letter-spacing:.01em}}
img{{width:1010px;border:14px solid #1D1420;border-radius:118px;box-shadow:0 40px 90px rgba(140,60,80,.28);display:block}}
</style><h1>{headline}</h1><img src="{src}"></html>"""

def main():
    work = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(tempfile.mkdtemp())
    work.mkdir(parents=True, exist_ok=True)
    for lang, lines in HEADLINES.items():
        out_dir = ROOT / "screenshots" / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        for i, (slide, headline) in enumerate(zip(SLIDES, lines), start=1):
            raw = work / f"{lang}-{slide}-raw.png"
            raw.write_bytes((ROOT / "screenshots-raw" / lang / f"{slide}.png").read_bytes())
            page = work / f"{lang}-{slide}.html"
            page.write_text(PAGE.format(lang=lang, w=W, h=H, font=FONTS[lang], headline=html.escape(headline),
                                        size=92 if lang == "en" else 104, src=raw.name), encoding="utf-8")
            shot = work / f"{lang}-{slide}.png"
            subprocess.run([CHROME, "--headless=new", "--hide-scrollbars", "--force-device-scale-factor=1",
                            f"--window-size={W},{H}", f"--screenshot={shot}", page.as_uri()],
                           check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            # App Store はアルファ付き画像を受け付けないので RGB で保存
            image = Image.open(shot).convert("RGB")
            assert image.size == (W, H), image.size
            image.save(out_dir / f"{i:02d}_{slide}.png")
            print(out_dir.name, f"{i:02d}_{slide}.png")

if __name__ == "__main__":
    main()
