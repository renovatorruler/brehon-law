# metaphrand

**Turn an idea into a finished story.**

Metaphrand is a scaffolding for stories. You hand it a one-line idea; it gives the model a structure to grow the story up, and a stack of gates that hold the result to the bar. The structure is the engine's, the prose is the model's, and the bar is enforced by code. The story stands on the graph, not on the model — so the same seed renders the same story every time.

It's named for the thing it deals in: a *metaphrand* (Julian Jaynes's term) is the abstract idea a metaphor points at, and a story, here, is a graph of them.

## The journey: idea → story

A story moves through stages, and the engine has a tool for each. Drive the whole thing from a premise, or step in by hand at any stage.

1. **The idea.** A one-line premise becomes the root metaphor — the transformation the whole story will concretize.
2. **A shape.** Choose a spine: `three_act`, `mirror` (the two-world transformation), or `kishōtenketsu` (the four-movement turn). They compose and nest.
3. **A world.** Populate the cast (each a person with their own want), braid the A-story with B-stories that refract it, fix the world's canon, and sink each character's backstory below the waterline as an iceberg the page must not spill.
4. **A voice.** Give every character a voice drawn from their chart, and set the narrator's grain — so nobody sounds like the model's default. (`docs/VOICE_FROM_CHART.md`, `docs/VOICE_GUIDE.md`)
5. **A draft.** Render the graph — a Fountain screenplay, close prose, or a multi-voice audio cut.
6. **The sweeps.** Run the draft through the gates, and let the repair loop rewrite what fails.

The craft behind each stage is written down in `docs/`: the grammar (`STORY_SPEC.md`), the development pipeline (`STORY_FRAMEWORK.md`), and how the writing should sound (`VOICE_GUIDE.md`).

## The model

A story is a **directed acyclic graph of metaphors** — not the English-class kind. We mean it as Jaynes did: an abstract idea (the *meaning*) is always carried by a concrete thing on the page (the *manifestation*). "Her skin was cold" isn't a simile of anything; its bare presence carries meaning. The thing that happens *is* the metaphor.

- Each **metaphor** has an abstract `meaning` and, at the leaves, a concrete `manifestation` — the line, the image, the action.
- A concrete metaphor is an **instantiation** of a more abstract one. Descending the graph is concretizing; the leaves are what appears on the page.
- The root is the **structure**; its meaning is the controlling premise.
- It's a **DAG, not a tree**: one beat can hang under both the structural spine and a theme at once, so "her skin was cold" can serve the midpoint *and* a motif without being duplicated. Edges only flow abstract → concrete, so the graph stays acyclic.

The graph is the canonical artifact. It serializes to a **canonical JSON** (nodes sorted by id, narrative order preserved) that round-trips byte-for-byte. The graph is the source of truth; turning it into words is a separate, deliberately fuzzy layer — the wording can vary, the story can't.

```python
from metaphrand import Story

story = Story()
root = story.three_act("Love demands a death of the self")
act2 = story.instantiate(root.id, "The self is besieged by another", kind="act")
beat = story.instantiate(
    act2.id, "Her skin was cold",
    manifestation="She does not pull her hand away. Her skin is cold.",
    kind="beat",
)
theme = story.instantiate(root.id, "The absence of another's warmth", kind="theme")
story.link(theme.id, beat.id)   # one beat, two parents — the DAG at work
story.save("story.json")
```

## Generating from a premise

The graph need not be hand-authored. `generate_story` asks a pluggable `LLMClient` — by default a local, open-source `ollama` model, so no API keys — to propose the whole story as one JSON document, then assembles it through the same `Story` API. Only the *proposal* is fuzzy; the graph it lands in is the deterministic seed every other layer speaks, with bad edges and voices repaired rather than trusted.

```python
from metaphrand.generate import generate_story
from metaphrand.render import FountainRenderer

story = generate_story("A lighthouse keeper's light was built to wreck ships")
print(FountainRenderer().render(story))        # a Fountain screenplay
story.save("stories/samples/generated.json")   # the deterministic seed
```

## The gates

The model fills the slots; the gates hold the bar. `metaphrand.pipeline.check` runs a story through them in order — spine, doorways, arrangement, the world's fullness, the weave's focus, concreteness (no flowery metaphrand on the page), embodiment, canon consistency, show-don't-tell, the visual / sound-off test, density (flesh on the bones), and the backstory leak — and `repair` feeds each failure back for a rewrite. Gates are the system; the model is the worker inside each one.

## Layout

| Path | What it is |
| --- | --- |
| `metaphrand/` | The engine — the metaphor graph, the structures, the world layers, the gates, the renderers, and the generation seam. |
| `docs/` | The craft: the grammar (`STORY_SPEC`), the development pipeline (`STORY_FRAMEWORK`), the prose voice + scene discipline (`VOICE_GUIDE`), and character voices from charts (`VOICE_FROM_CHART`). |
| `examples/` | One walk-through per structure and stage — hand-built seeds, end-to-end generation, audio. |
| `stories/` | One folder per world (`civil-war/`, `ray/`, `the-seeing/`, `deeper/`, …): the seeds, drafts, and bibles for each story, plus `samples/` of raw engine output. |
| `tests/` | The graph, the gates, and the determinism guarantees. |

### Inside `metaphrand/`

Flat on disk, but it reads as the journey:

- **The graph** — `metaphor.py` (the unit), `story.py` (the DAG, the structures, canonical JSON).
- **The world** — `world.py` (cast + fullness), `weave.py` (A/B threads), `canon.py` (ground truth), `dossier.py` (the iceberg), `arrangement.py` (story-time vs plot-time).
- **The gates** — `doorways.py`, `concreteness.py`, `showing.py`, `cinema.py`, `density.py`, `embodiment.py`, `kishotenketsu.py` (shape + descent).
- **The render** — `render.py` (Fountain), `prose.py` (close prose), `audio.py` / `audiodrama.py` / `soundscape.py` (voice + sound).
- **The seam** — `generate.py` (premise → graph via a local model), `prompt.py`, `repair.py` (gate → rewrite), `pipeline.py` (runs the whole sweep).

## Start

```bash
pip install -e ".[dev]"
pytest
python -m examples.three_act          # a tiny hand-built story graph

# generate a screenplay from a one-line premise (local ollama model, no API keys):
python -m examples.generate "A lighthouse keeper's light was built to wreck ships"

# render a stored seed to multi-voice audio (Python <=3.12; needs espeak-ng):
pip install -e ".[audio]"
python -m examples.render_audio stories/samples/generated.json out.wav
```

The model layer talks to a local open-source `ollama` model by default, so there are no API keys to manage. The graph, its gates, and its determinism stand without any model at all.
