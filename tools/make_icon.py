"""Lumora uygulama ikonunu üretir (1024x1024; light, dark, tinted)."""
import math, sys
from PIL import Image, ImageDraw, ImageFilter, ImageChops

S = 2048
OUT = sys.argv[1]

def radial(size, inner, outer, cx=0.5, cy=0.5, r=0.75):
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            d = min(1.0, math.hypot(x/size-cx, y/size-cy)/r)
            px[x, y] = tuple(int(inner[i]*(1-d)+outer[i]*d) for i in range(3))
    return img

def build(bg_inner, bg_outer, glow, core, sym, transparent_bg=False):
    small = 256
    bg = radial(small, bg_inner, bg_outer, cy=0.42, r=0.8).resize((S, S), Image.BICUBIC)
    if transparent_bg:
        bg = Image.new("RGB", (S, S), (0, 0, 0))
    canvas = bg.convert("RGBA")
    c = S/2
    # bloom
    bloom = Image.new("RGBA", (S, S), (0,0,0,0))
    d = ImageDraw.Draw(bloom)
    R = S*0.36
    d.ellipse([c-R, c-R, c+R, c+R], fill=glow+(200,))
    bloom = bloom.filter(ImageFilter.GaussianBlur(S*0.09))
    canvas = Image.alpha_composite(canvas, bloom)
    # tick ring
    ring = Image.new("RGBA", (S, S), (0,0,0,0))
    d = ImageDraw.Draw(ring)
    rr = S*0.355
    for i in range(72):
        a = i/72*2*math.pi
        major = i % 6 == 0
        ln = S*(0.03 if major else 0.016)
        w = int(S*(0.006 if major else 0.0035))
        x1, y1 = c+math.cos(a)*rr, c+math.sin(a)*rr
        x2, y2 = c+math.cos(a)*(rr-ln), c+math.sin(a)*(rr-ln)
        d.line([x1, y1, x2, y2], fill=glow+(235 if major else 140,), width=w)
    canvas = Image.alpha_composite(canvas, ring)
    # orb
    orb = Image.new("RGBA", (S, S), (0,0,0,0))
    od = ImageDraw.Draw(orb)
    r0 = S*0.25
    steps = 120
    for k in range(steps):
        t = k/steps
        r = r0*(1-t)
        col = tuple(int(glow[i]*(1-t**0.6)+core[i]*(t**0.6)) for i in range(3))
        od.ellipse([c-r, c-r, c+r, c+r], fill=col+(255,))
    canvas = Image.alpha_composite(canvas, orb)
    # özgün el feneri çizimi (SF Symbols ikonlarda kullanılamaz)
    p = Image.new("RGBA", (S, S), (0,0,0,0))
    pd = ImageDraw.Draw(p)
    col = sym+(255,)
    u = S*0.01
    cy = c + u*1.5
    # kafa (üstte geniş, alta doğru daralan)
    pd.polygon([(c-11*u, cy-13*u), (c+11*u, cy-13*u), (c+6*u, cy-4*u), (c-6*u, cy-4*u)], fill=col)
    pd.rounded_rectangle([c-11.5*u, cy-16*u, c+11.5*u, cy-12.2*u], radius=1.2*u, fill=col)
    # gövde
    pd.rounded_rectangle([c-6*u, cy-4.6*u, c+6*u, cy+16*u], radius=2*u, fill=col)
    # açma düğmesi
    pd.rounded_rectangle([c-1.8*u, cy+0.5*u, c+1.8*u, cy+6*u], radius=1.8*u, fill=(255,240,210,255))
    # ışık hüzmesi çizgileri
    for dx, dy, ex, ey in [(-9,-19,-13,-25),(0,-20,0,-27),(9,-19,13,-25)]:
        pd.line([c+dx*u, cy+dy*u, c+ex*u, cy+ey*u], fill=col, width=int(1.7*u))
        for (x,y) in [(c+dx*u, cy+dy*u),(c+ex*u, cy+ey*u)]:
            pd.ellipse([x-0.85*u, y-0.85*u, x+0.85*u, y+0.85*u], fill=col)
    canvas = Image.alpha_composite(canvas, p)
    return canvas.convert("RGB").resize((1024, 1024), Image.LANCZOS)

warm = (255, 226, 170)
build((34, 35, 42), (5, 5, 6), warm, (255, 255, 255), (30, 26, 20)).save(f"{OUT}/AppIcon.png")
build((20, 20, 24), (0, 0, 0), warm, (255, 250, 240), (30, 26, 20)).save(f"{OUT}/AppIcon-Dark.png")
# Tinted: gri tonlu, iOS kendi rengiyle boyar
g = build((0,0,0), (0,0,0), (200,200,200), (255,255,255), (40,40,40), transparent_bg=True).convert("L").convert("RGB")
g.save(f"{OUT}/AppIcon-Tinted.png")
print("done")
