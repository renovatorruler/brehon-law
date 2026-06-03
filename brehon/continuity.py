"""The Continuity gate — the beats must form one connected world.

Every other gate judges a beat by itself. Continuity judges the SEQUENCE: a
reader has to be able to track where everyone is, what just happened, what time
it is. The system kept producing locally-perfect beats that globally contradict
— a man in a warehouse, then a trailer, then a kitchen; a daughter holding his
hand in one beat and calling from down the hall in the next.

This faculty carries state across the beats. The deterministic scan catches the
two clearest breaks — a character in two places at once (bilocation), and the
camera teleporting between unconnected places. A model-backed ``read`` catches
the subtler contradictions a word-tracker can't.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Iterator

if TYPE_CHECKING:
    from brehon.generate import LLMClient
    from brehon.metaphor import Metaphor
    from brehon.story import Story

# People we can track across beats by a relation word.
_PEOPLE = {
    "daughter", "son", "wife", "husband", "mother", "father", "brother",
    "sister", "boy", "girl", "kid", "child", "baby", "mom", "dad",
}
# Common place nouns, to notice the camera jumping between them.
_PLACES = {
    "warehouse", "trailer", "kitchen", "hall", "hallway", "bedroom", "porch",
    "dock", "street", "office", "car", "truck", "bar", "field", "woods",
    "forest", "cabin", "barn", "yard", "garage", "basement", "attic", "alley",
    "church", "bridge", "river", "beach", "cell", "ward", "tent", "bay", "mill",
    "lighthouse", "station", "hospital", "school", "diner", "motel",
}
_REMOTE = re.compile(
    r"\b(?:voice|calling|calls|cries|crying|shouts?|shouting|yell\w*|screams?|"
    r"screaming)\b[^.]{0,40}?\bfrom\b|\bdown the hall\b|\bfrom (?:the )?(?:other|"
    r"next) room\b|\bfrom outside\b|\bin the (?:other|next) room\b|\bin the distance\b",
    re.IGNORECASE,
)
_PRESENT = re.compile(
    r"\b(?:hand|shoulder|arm|face|cheek|beside|holds?|holding|held|wraps?|wrapping|"
    r"pulls?|pulling|grips?|gripping|hugs?|hugging|embrac\w*|cradl\w*)\b",
    re.IGNORECASE,
)
_WORD = re.compile(r"[a-z]+")


def _people_in(text: str) -> set[str]:
    return {w for w in _WORD.findall(text.lower()) if w in _PEOPLE}


def _place_in(text: str) -> str:
    for w in _WORD.findall(text.lower()):
        if w in _PLACES:
            return w
    return ""


def _ordered(story: "Story") -> Iterator["Metaphor"]:
    """Page nodes (manifestation-bearing) in narrative order."""
    if story.root_id is None:
        return
    root = story.get(story.root_id)
    if root.kind == "mirror":
        states = [m for m in story.children(root.id) if m.kind == "state"]
        previous = next((s for s in states if s.attributes.get("role") == "previous"), None)
        following = next((s for s in states if s.attributes.get("role") == "next"), None)
        if previous is None and states:
            previous = states[0]
        if following is None and len(states) > 1:
            following = states[1]
        if previous is not None:
            for n in story.walk(previous.id):
                if n.manifestation.strip():
                    yield n
        if root.manifestation.strip():
            yield root
        if following is not None:
            for n in story.walk(following.id):
                if n.manifestation.strip():
                    yield n
    else:
        for act in (m for m in story.children(root.id) if m.kind == "act"):
            for child in story.children(act.id):
                node = story.get(child.id)
                if node.manifestation.strip():
                    yield node


@dataclass
class ContinuityReport:
    places: list[str]
    breaks: list[str]            # deterministic contradictions
    reader: list[str] = field(default_factory=list)  # model-found contradictions

    @property
    def passed(self) -> bool:
        return not self.breaks and not self.reader

    def summary(self) -> str:
        found = self.breaks + self.reader
        if not found:
            return "continuous"
        head = "; ".join(found[:3]) + ("…" if len(found) > 3 else "")
        return f"{len(found)} continuity break(s): {head}"


def scan(story: "Story") -> tuple[list[str], list[str]]:
    """Deterministic pass: returns (place-per-beat, contradictions)."""
    nodes = list(_ordered(story))
    places: list[str] = []
    present: list[set[str]] = []
    remote: list[set[str]] = []
    for node in nodes:
        text = node.manifestation + " " + str(node.attributes.get("dialogue", ""))
        people = _people_in(text)
        present.append(people if _PRESENT.search(text) else set())
        remote.append(people if _REMOTE.search(text) else set())
        places.append(_place_in(node.manifestation))

    breaks: list[str] = []
    for i in range(len(nodes) - 1):
        for who in present[i] & remote[i + 1]:
            breaks.append(
                f"bilocation: the {who} is present in {nodes[i].id!r} but calls "
                f"from elsewhere in {nodes[i + 1].id!r}")
        for who in remote[i] & present[i + 1]:
            breaks.append(
                f"bilocation: the {who} is elsewhere in {nodes[i].id!r} but "
                f"present in {nodes[i + 1].id!r}")

    seq = [p for p in places if p]
    jumps = sum(1 for a, b in zip(seq, seq[1:]) if a != b)
    if len(set(seq)) >= 3 and jumps >= 2:
        ordered_unique: list[str] = []
        for p in seq:
            if not ordered_unique or ordered_unique[-1] != p:
                ordered_unique.append(p)
        breaks.append(
            "the camera jumps between unconnected places ("
            + " -> ".join(ordered_unique) + ") with no transition")
    return places, breaks


def read(story: "Story", client: "LLMClient") -> list[str]:
    """Model pass: a script supervisor reads the sequence for contradictions."""
    from brehon.generate import _extract_json  # lazy: avoid an import cycle

    nodes = list(_ordered(story))
    if not nodes:
        return []
    numbered = "\n".join(f"{i + 1}. {n.manifestation}" for i, n in enumerate(nodes))
    prompt = (
        "Read these beats in order, as one continuous scene-sequence. List any "
        "CONTINUITY contradictions — a character in two places at once, a location "
        "that jumps with no transition, an impossible timeline. If it is fully "
        "consistent, return an empty list.\n\n"
        f"{numbered}\n\n"
        'Return JSON: {"contradictions": ["...", ...]}'
    )
    try:
        data = _extract_json(client.complete(
            prompt, system="You are a script supervisor checking continuity. Output only JSON."))
    except Exception:
        return []
    return [str(x) for x in data.get("contradictions", []) if str(x).strip()][:8]


def continuity(story: "Story", client=None) -> ContinuityReport:
    """The full gate: the deterministic scan, plus the model reader if available."""
    places, breaks = scan(story)
    reader = read(story, client) if client is not None else []
    return ContinuityReport(places, breaks, reader)
