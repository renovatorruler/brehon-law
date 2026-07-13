# The FOUR OLDS audio mix — DME stem architecture

Modeled on a Hollywood re-recording mix. The old mixer treated every sound as a
discrete event in a queue; a real mix runs **stems** (buses) simultaneously and
lays them over/under each other, with **dialogue as king**.

## The stems

- **DIALOGUE** — every voice. Placed on the timeline, normalized to one steady
  dialogue level (the spine). Per-line **perspective** filter and per-space
  **reverb**. Drives the ducking of everything else.
- **ATMOS (backgrounds)** — the continuous **bed** of a space (room tone, crowd
  wash, engine drone). Runs UNDER the dialogue of its segment, **crossfades**
  bed-to-bed on a cut, **sidechain-ducked** by the dialogue bus.
- **SPOT (hard FX / foley)** — discrete synced events (a cork, a chime, a mug, a
  static feed-switch). Layered on top, sent to the same per-space reverb.
- **MUSIC** — score / stings. Ducked under dialogue.
- **MASTER** — sum the stems → glue compression → loudnorm −16 LUFS / −1.5 dBTP
  → limiter.

## The cue format (what the script carries)

Authored as ordinary engine `ACTION:` / dialogue lines, with structured text the
mixer reads. The renderer resolves each description to a PSE recording or a
generated sound; the mixer routes it to a bus.

- `ACTION: ATMOS <space> | <description>` — start a continuous **bed** for
  `<space>`; it runs until the next ATMOS/CUT and sets the current space.
- `ACTION: FX | <description>` — a **spot** effect (inherits the current space).
- `ACTION: CUT <space> | <description>` — a **hard transition** to `<space>`;
  `<description>` is the transition sound (usually static/whoosh); the mixer
  crossfades the outgoing bed to the incoming one across it.
- `ACTION: MUSIC | <description>` — to the **music** bus.
- `NAME (<persp>): text` — dialogue. `<persp>` ∈ `close | off | radio | pa | tv`
  (or none). Perspective sets the futz/reverb: `close` dry & present; `off`
  rolled-off + roomier; `radio|pa|tv` bandpass "futz"; the diner-radio finale is
  a heavy futz — the fidelity drop.

## Spaces

Each `<space>` tag carries a reverb + tone profile: `studio` (close, dead),
`arena` (huge, long tail), `cargobay` (metal hull), `hearing` (dry, tight),
`diner` (small, intimate), `exterior`, `room`. New tags fall back to `room`.

## Why this fixes "nothing blends"

The beds now run continuously *under* the voices and change with each cut; the
dialogue rides on top at a steady level; the static transitions are audible
because they bridge two beds instead of getting chopped into a queue. That is a
broadcast, not a slideshow.
