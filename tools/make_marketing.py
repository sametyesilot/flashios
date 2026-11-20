"""App Store pazarlama ekran görüntüleri (6.9" — 1320x2868)."""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
W, H = 1320, 2868
GLOW = {1:(255,226,170),2:(94,242,214),3:(255,122,69),4:(140,200,255),5:(230,194,122)}
CAP = {
 "en": ["One tap.\nPure light.","Five stunning\nthemes","Crafted to feel\npremium","Instant. Silent.\nSimple.","Your light,\nyour style"],
 "tr": ["Tek dokunuş.\nSaf ışık.","Beş büyüleyici\ntema","Premium hissi için\ntasarlandı","Anında. Sessiz.\nBasit.","Senin ışığın,\nsenin tarzın"],
}
def font(sz):
    f = ImageFont.truetype("/System/Library/Fonts/SFNSRounded.ttf", sz)
    try: f.set_variation_by_name("Bold")
    except Exception: pass
    return f
os.makedirs("screenshots/appstore", exist_ok=True)
for lang, caps in CAP.items():
    for i in range(1, 6):
        g = GLOW[i]
        bg = Image.new("RGB", (W, H), (6, 6, 8))
        glow = Image.new("RGB", (W, H), (0,0,0)); d = ImageDraw.Draw(glow)
        d.ellipse([W*0.05, H*0.35, W*0.95, H*0.85], fill=tuple(int(c*0.45) for c in g))
        glow = glow.filter(ImageFilter.GaussianBlur(220))
        bg = Image.blend(bg, glow, 0.9)
        d = ImageDraw.Draw(bg)
        d.multiline_text((W/2, 330), caps[i-1], font=font(118), fill=(255,255,255), anchor="mm", align="center", spacing=24)
        shot = Image.open(f"screenshots/raw/{lang}_{i}.png").convert("RGB")
        sw = int(W*0.74); sh = int(shot.height*sw/shot.width)
        shot = shot.resize((sw, sh), Image.LANCZOS)
        mask = Image.new("L", (sw, sh), 0); ImageDraw.Draw(mask).rounded_rectangle([0,0,sw,sh], radius=110, fill=255)
        x, y = (W-sw)//2, 600
        # çerçeve
        frame = Image.new("RGBA", (sw+36, sh+36), (0,0,0,0))
        ImageDraw.Draw(frame).rounded_rectangle([0,0,sw+35,sh+35], radius=128, fill=(28,28,32,255), outline=(80,80,88,255), width=3)
        bg.paste(frame, (x-18, y-18), frame)
        bg.paste(shot, (x, y), mask)
        bg.save(f"screenshots/appstore/{lang}_{i}.png")
print("ok")
