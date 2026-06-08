"""Render an audio-drama script to finished audio — the engine's soundscape stage.

Two phases, so mix levels can be tuned without re-synthesizing speech:

1. ``build_voices`` — parse the :mod:`brehon.audiodrama` script, voice every line
   with **Kokoro** (a distinct, consistent voice per character; narrator-Gary and
   in-scene-Gary are one voice), and **cache** each clip to disk with a layout
   (timings, scene spans, timed spot effects).
2. ``mix_layout`` — a **dialogue-forward** mix: every voice normalized to a target
   level (the reference), ambience beds and Foley forced well below it and **ducked**
   hard under speech, a telephone filter on processed (phone/TV) lines, spot effects
   placed and peak-capped so they support rather than blast. Re-runnable instantly.

Beds/Foley are real Freesound recordings (ambience chosen for smoothness — low crest
factor — so a scene reads as a place, not a sequence of events).

Needs ``kokoro``, ``numpy``, ``soundfile``, ``ffmpeg`` and a Freesound key at
``~/.config/freesound/api_key``.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import urllib.parse
import urllib.request

import numpy as np
import soundfile as sf

from brehon.audiodrama import Line, SoundCue, parse_audio_drama

SR = 24000
GAP = 0.30

KOKORO_CAST = {
    "GARY": "am_michael", "HALLORAN": "am_eric", "ROYCE": "am_onyx", "SAL": "am_fenrir",
    "LIND": "am_adam", "GUTHRIE": "am_liam", "BRINKMAN": "am_puck", "DESK SERGEANT": "am_echo",
    "DEV OFFICER": "am_santa",
    "DONNA": "af_heart", "FOSS": "af_nicole", "CAROL": "af_bella", "IRENE": "af_sarah",
    "AIDE": "af_aoede", "LOPEZ": "af_kore",
}
NARRATOR_VOICE = "am_michael"

_KEY = open(os.path.expanduser("~/.config/freesound/api_key")).read().strip()
_HDR = {"Authorization": f"Token {_KEY}"}
_CACHE = "/tmp/tr/ad_cache"
_VOICE_DIR = "/tmp/tr/ad_voice"


# ── Freesound resolve ────────────────────────────────────────────────────────
def _fetch(url: str) -> bytes:
    last = None
    for hdr in (_HDR, {}):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers=hdr), timeout=60).read()
        except Exception as e:  # noqa: BLE001
            last = e
    raise last


def _search(query: str, dmin: float, dmax: float) -> list:
    params = {"query": query, "fields": "id,name,duration,license,username,previews,num_downloads",
              "filter": f"duration:[{dmin} TO {dmax}]", "sort": "downloads_desc", "page_size": 8}
    url = "https://freesound.org/apiv2/search/text/?" + urllib.parse.urlencode(params)
    raw = urllib.request.urlopen(urllib.request.Request(url, headers=_HDR), timeout=30).read()
    return [r for r in json.loads(raw).get("results", []) if r.get("previews")]


def _search_fallback(query: str, dmin: float, dmax: float) -> list:
    words = query.split()
    for n in range(len(words), 1, -1):
        res = _search(" ".join(words[:n]), dmin, dmax)
        if res:
            return res
    return _search(words[0], dmin, dmax) if words else []


def _dl_wav(r: dict, dst: str) -> None:
    prev = r["previews"].get("preview-hq-mp3") or r["previews"].get("preview-lq-mp3")
    open(dst + ".mp3", "wb").write(_fetch(prev))
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", dst + ".mp3",
                    "-ar", str(SR), "-ac", "1", dst], check=True)


def _crest(wav: str) -> float:
    x, _ = sf.read(wav)
    if x.ndim > 1:
        x = x.mean(1)
    pk = np.max(np.abs(x)) + 1e-9
    rm = np.sqrt(np.mean(x ** 2)) + 1e-9
    return float(20 * np.log10(pk / rm))


def resolve(query: str, kind: str, *, candidates: int = 3) -> "str | None":
    os.makedirs(_CACHE, exist_ok=True)
    tag = "bed" if kind == "ambience" else "fx"
    key = f"{tag}_{hashlib.md5(query.encode()).hexdigest()[:10]}"
    out = f"{_CACHE}/{key}.wav"
    if os.path.exists(out):
        return out
    try:
        if kind == "ambience":
            cands = _search_fallback(query, 12, 600)[:candidates]
            scored = []
            for i, r in enumerate(cands):
                tmp = f"{_CACHE}/{key}_c{i}.wav"
                _dl_wav(r, tmp)
                scored.append((_crest(tmp), -r["duration"], tmp))
            if not scored:
                return None
            scored.sort()  # smoothest (lowest crest), then longest
            os.replace(scored[0][2], out)
            for _, _, t in scored[1:]:
                for p in (t, t + ".mp3"):
                    if os.path.exists(p):
                        os.remove(p)
        else:
            cands = _search_fallback(query, 0.3, 25)
            if not cands:
                return None
            _dl_wav(cands[0], out)
        return out
    except Exception as e:  # noqa: BLE001
        print(f"  (resolve failed: {query!r}: {e})", flush=True)
        return None


# ── signal helpers ───────────────────────────────────────────────────────────
def _norm_rms(x, db, max_gain_db=24.0):
    """Scale to a target RMS in dBFS, capping the boost so near-silence can't blow up."""
    rms = float(np.sqrt(np.mean(x ** 2))) + 1e-9
    gain = min(10 ** (db / 20) / rms, 10 ** (max_gain_db / 20))
    return (x * gain).astype(np.float32)


def _soft(x, ceil=0.9):
    return (ceil * np.tanh(x / ceil)).astype(np.float32)


def _tile(x, n):
    if len(x) == 0:
        return np.zeros(n, np.float32)
    if len(x) >= n:
        return x[:n].copy()
    return np.tile(x, int(np.ceil(n / len(x))))[:n].astype(np.float32)


def _edge_fade(x, sec=0.6):
    k = min(int(SR * sec), len(x) // 2)
    if k <= 0:
        return x
    r = np.linspace(0, 1, k, dtype=np.float32)
    x = x.copy(); x[:k] *= r; x[-k:] *= r[::-1]
    return x


def _envelope(x, win=0.08):
    a = np.abs(x).astype(np.float64)
    k = max(1, int(SR * win))
    c = np.cumsum(np.insert(a, 0, 0))
    e = (c[k:] - c[:-k]) / k
    if len(e) < len(a):
        e = np.concatenate([e, np.full(len(a) - len(e), e[-1] if len(e) else 0.0)])
    return np.clip(e / (np.percentile(e, 90) + 1e-6), 0, 1).astype(np.float32)


def _phone(x, lo=320, hi=3200):
    n = len(x)
    if n == 0:
        return x
    X = np.fft.rfft(x)
    f = np.fft.rfftfreq(n, 1 / SR)
    X[(f < lo) | (f > hi)] = 0
    return np.fft.irfft(X, n).astype(np.float32)


# ── phase 1: voices (cached) ─────────────────────────────────────────────────
def build_voices(script_path: str, max_seconds: float, *, reuse: bool = True) -> dict:
    layout_path = os.path.join(_VOICE_DIR, "layout.json")
    if reuse and os.path.exists(layout_path):
        return json.load(open(layout_path))

    from kokoro import KPipeline
    os.makedirs(_VOICE_DIR, exist_ok=True)
    ad = parse_audio_drama(open(script_path).read())

    def est(t):
        return max(0.8, len(t.split()) / 2.6)
    scenes, tot = [], 0.0
    for s in ad.scenes:
        scenes.append(s)
        tot += sum(est(e.text) + GAP for e in s.elements if isinstance(e, Line))
        if tot >= max_seconds:
            break

    pipe = KPipeline(lang_code="a")

    def say(text, voice):
        chunks = []
        for _, _, audio in pipe(text, voice=voice, speed=1.0):
            arr = audio.detach().cpu().numpy() if hasattr(audio, "detach") else np.asarray(audio)
            chunks.append(arr.astype(np.float32))
        return np.concatenate(chunks) if chunks else np.zeros(int(0.3 * SR), np.float32)

    voices, spans, fx = [], [], []
    t = 0.0
    idx = 0
    for s in scenes:
        s0 = t
        for e in s.elements:
            if isinstance(e, Line):
                voice = NARRATOR_VOICE if e.kind == "narration" else KOKORO_CAST.get(e.speaker, NARRATOR_VOICE)
                clip = say(e.text, voice)
                p = os.path.join(_VOICE_DIR, f"{idx:03d}.wav")
                sf.write(p, clip, SR)
                voices.append({"path": p, "start": t, "dur": len(clip) / SR,
                               "kind": e.kind, "filtered": bool(e.filtered)})
                t += len(clip) / SR + GAP
                idx += 1
            elif isinstance(e, SoundCue) and e.kind in ("sfx", "motif", "bridge"):
                fx.append({"t": t, "query": e.query, "kind": e.kind})
        spans.append({"s0": s0, "s1": t, "amb": s.ambience.query if s.ambience else ""})

    layout = {"voices": voices, "spans": spans, "fx": fx, "total": t,
              "scenes": len(scenes), "lines": idx}
    json.dump(layout, open(layout_path, "w"))
    return layout


# ── phase 2: dialogue-forward mix (instant to re-run) ────────────────────────
def mix_layout(layout: dict, out_wav: str, *,
               nar_db: float = -15.0, dia_db: float = -17.0,   # voices = the reference
               bed_db: float = -36.0, bed_duck: float = 0.90,  # beds well below, duck hard
               fx_db: float = -26.0, fx_peak: float = 0.26, fx_duck: float = 0.6) -> dict:
    total = int(layout["total"] * SR) + SR
    master = np.zeros(total, np.float32)

    # voices: normalize each to the dialogue target (the loudest, most consistent element)
    for v in layout["voices"]:
        x, _ = sf.read(v["path"])
        if x.ndim > 1:
            x = x.mean(1)
        x = x.astype(np.float32)
        if v["filtered"]:
            x = _phone(x)
        x = _norm_rms(x, nar_db if v["kind"] == "narration" else dia_db)
        a = int(v["start"] * SR)
        master[a:a + len(x)] += x

    env = _envelope(master)  # duck everything else against the speech

    beds = 0
    for sp in layout["spans"]:
        if sp["amb"]:
            p = resolve(sp["amb"], "ambience")
            if p:
                x, _ = sf.read(p)
                if x.ndim > 1:
                    x = x.mean(1)
                x = _soft(_norm_rms(x.astype(np.float32), bed_db), 0.4)
                a, b = int(sp["s0"] * SR), min(int(sp["s1"] * SR), total)
                seg = _edge_fade(_tile(x, b - a))
                seg *= (1.0 - bed_duck * env[a:b])
                master[a:b] += seg
                beds += 1

    fxn = 0
    for f in layout["fx"]:
        if f["query"]:
            p = resolve(f["query"], "sfx")
            if p:
                x, _ = sf.read(p)
                if x.ndim > 1:
                    x = x.mean(1)
                x = _norm_rms(x.astype(np.float32), fx_db)
                x = np.clip(x, -fx_peak, fx_peak)              # cap transients below speech
                if f["kind"] in ("motif", "bridge"):
                    x = x * 0.7
                seg = _edge_fade(x, 0.03)
                a = int(f["t"] * SR)
                b = min(a + len(seg), total)
                duck = 1.0 - fx_duck * env[a:b]                # Foley yields to concurrent speech
                master[a:b] += (seg[:b - a] * duck)
                fxn += 1

    master = _soft(master, 0.9)  # gentle master ceiling
    peak = float(np.max(np.abs(master))) or 1.0
    if peak > 0.97:
        master *= 0.97 / peak
    sf.write(out_wav, master, SR)
    return {"scenes": layout["scenes"], "lines": layout["lines"],
            "beds": beds, "fx": fxn, "seconds": layout["total"]}


def render(script_path: str, out_wav: str, *, max_seconds: float = 600.0,
           reuse_voices: bool = True, **mix) -> dict:
    layout = build_voices(script_path, max_seconds, reuse=reuse_voices)
    return mix_layout(layout, out_wav, **mix)


if __name__ == "__main__":
    import sys
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    remix = "--remix" in sys.argv          # reuse cached voices, just re-mix levels
    script, out = args[0], args[1]
    secs = float(args[2]) if len(args) > 2 else 600.0
    info = render(script, out, max_seconds=secs, reuse_voices=remix or os.path.exists(
        os.path.join(_VOICE_DIR, "layout.json")))
    print("RENDERED", json.dumps(info))
