#!/usr/bin/env python
"""Table read with visuals — cold-open pilot (graphic-novel register).

One ink panel per beat + Kokoro multi-voice audio -> one MP4.
Reuses the grandfathered pipelines (metaphrand.audio for Kokoro,
cinema.backends for images). ReScript migration debt noted.

Run: PYTHONPATH=/Users/dusty/dev/metaphrand \
     /Users/dusty/dev/metaphrand/.venv/bin/python tools/tableread_sc01.py
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
import wave

sys.path.insert(0, "/Users/dusty/dev/metaphrand")

from metaphrand.audio import KokoroBackend, parse_screenplay  # noqa: E402
from cinema.backends import image, save_png  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(HERE, "stories/four-olds/draft/sc01_cold_open.fountain")
OUT = os.path.join(HERE, "stories/four-olds/tableread")
PANELS = os.path.join(OUT, "panels")
SEGS = os.path.join(OUT, "segs")
for d in (OUT, PANELS, SEGS):
    os.makedirs(d, exist_ok=True)

# ---- cast (all American voices -> one Kokoro pipeline) --------------------------
NARRATOR = "am_michael"
CAST = {
    "ANCHOR": "af_nicole",
    "COMMENTATOR": "am_onyx",
    "MARWANI": "am_fenrir",
    "SENATOR": "am_eric",
    "HALE": "am_adam",
    "RADIO": "af_sarah",
    "BUCK": "am_liam",
}

INK = ("Black-and-white brush-ink graphic novel panel, heavy expressive linework, "
       "flat gray screentone shading, deep blacks, dramatic cinematic composition. "
       "No text, no lettering, no captions, no speech bubbles, no watermarks. ")

# ---- split the scene into beats on sluglines -------------------------------------
def beats_from_fountain(path: str):
    text = open(path, encoding="utf-8").read()
    lines = text.splitlines()
    beats, cur_cap, cur = [], None, []
    slug = re.compile(r"^(INT\.|EXT\.|ON A |ON HIS |INSERT )", re.I)
    for ln in lines:
        s = ln.strip()
        if s.startswith("> ") and s.endswith(" <"):  # centered title card
            if cur_cap is not None:
                beats.append((cur_cap, "\n".join(cur)))
            beats.append(("__TITLE__", re.sub(r"[>*<]", "", s).strip()))
            cur_cap, cur = None, []
            continue
        if slug.match(s):
            if cur_cap is not None:
                beats.append((cur_cap, "\n".join(cur)))
            cur_cap, cur = s.rstrip(":"), []
            continue
        if re.match(r"^(CUT TO|FADE|SMASH)", s):
            continue
        cur.append(ln)
    if cur_cap is not None and cur:
        beats.append((cur_cap, "\n".join(cur)))
    return beats


PROMPTS = {
    0: "Election-night cable news studio, a huge electoral map wall glowing behind two stunned news anchors at a curved desk, balloons drifting down over the desk, monitors everywhere.",
    1: "A vast inauguration crowd on the National Mall seen from behind, all faces turned to an enormous jumbotron screen showing a young president at a podium, tiny flags dotting the crowd.",
    2: "Inside a military cargo plane, rows of shrink-wrapped pallets stacked with banded bricks of cash, a loadmaster with a clipboard walking the line, harsh utility light.",
    3: "A grand European hall with chandeliers, ministers applauding around a long table as two officials sign an enormous document, champagne on silver trays.",
    4: "Extreme close-up of a smartphone in a rough hand, a government news alert notification on the cracked screen, dark kitchen background.",
    5: "A senate hearing room, one lone man in a suit at the witness table dwarfed by the high dais of senators above him, press cameras crowding the foreground.",
    6: "A small-town American diner counter at morning, six weathered regulars on stools seen from behind, an old TV glowing on the wall, a waitress with a coffee pot standing still.",
}


def caption_panel(png_path: str, caption: str, size=(1920, 1080)) -> str:
    from PIL import Image, ImageDraw, ImageFont
    img = Image.open(png_path).convert("RGB")
    img = img.resize(size)
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Courier New Bold.ttf", 34)
    except OSError:
        font = ImageFont.load_default()
    pad = 16
    text = caption.upper()
    bbox = d.textbbox((0, 0), text, font=font)
    w, h = bbox[2] - bbox[0], bbox[3] - bbox[1]
    d.rectangle([28, 28, 28 + w + pad * 2, 28 + h + pad * 2], fill=(12, 12, 12))
    d.text((28 + pad, 28 + pad - bbox[1]), text, font=font, fill=(240, 240, 240))
    out = png_path.replace(".png", "_cap.png")
    img.save(out)
    return out


def title_card(text: str, path: str, size=(1920, 1080)) -> str:
    from PIL import Image, ImageDraw, ImageFont
    img = Image.new("RGB", size, (0, 0, 0))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Courier New Bold.ttf", 120)
    except OSError:
        font = ImageFont.load_default()
    bbox = d.textbbox((0, 0), text, font=font)
    d.text(((size[0] - bbox[2]) / 2, (size[1] - bbox[3]) / 2), text,
           font=font, fill=(235, 235, 235))
    img.save(path)
    return path


def beat_wav(utts, backend, path: str, tail: float = 0.7) -> float:
    rate = backend.sample_rate
    gap = b"\x00\x00" * int(rate * 0.35)
    with wave.open(path, "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(rate)
        for i, u in enumerate(utts):
            if i:
                out.writeframes(gap)
            out.writeframes(backend.synth(u.text, u.voice))
        out.writeframes(b"\x00\x00" * int(rate * tail))
    with wave.open(path) as w:
        return w.getnframes() / w.getframerate()


def main() -> int:
    beats = beats_from_fountain(SRC)
    print(f"{len(beats)} beats")
    backend = KokoroBackend(lang_code="a")

    seg_files = []
    img_i = 0
    for n, (cap, body) in enumerate(beats):
        seg = os.path.join(SEGS, f"seg{n:02}.mp4")
        if cap == "__TITLE__":
            panel = title_card(body, os.path.join(PANELS, f"beat{n:02}_title.png"))
            wav = os.path.join(SEGS, f"seg{n:02}.wav")
            with wave.open(wav, "wb") as w:
                w.setnchannels(1); w.setsampwidth(2); w.setframerate(24000)
                w.writeframes(b"\x00\x00" * int(24000 * 3.0))
        else:
            raw = os.path.join(PANELS, f"beat{n:02}.png")
            if not os.path.exists(raw):
                print(f"gen panel {n}: {cap}")
                save_png(raw, image(INK + PROMPTS[img_i], pro=False, aspect="16:9"))
            panel = caption_panel(raw, cap)
            utts = parse_screenplay(body, CAST, NARRATOR)
            print(f"beat {n}: {len(utts)} utterances")
            wav = os.path.join(SEGS, f"seg{n:02}.wav")
            beat_wav(utts, backend, wav)
            img_i += 1
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-loop", "1", "-i", panel,
             "-i", wav, "-c:v", "libx264", "-tune", "stillimage", "-r", "24",
             "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "128k", "-shortest", seg],
            check=True)
        seg_files.append(seg)

    lst = os.path.join(SEGS, "list.txt")
    with open(lst, "w") as f:
        for s in seg_files:
            f.write(f"file '{s}'\n")
    from datetime import datetime
    stamp = datetime.now().strftime("%Y-%m-%d_%H%M")
    final = os.path.join(OUT, f"TABLEREAD_cold-open_{stamp}_v1.mp4")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0",
                    "-i", lst, "-c", "copy", final], check=True)
    print("OUT:", final)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
