import json

from brehon import Story
from brehon.continuity import continuity, scan


def _mirror(mirror_manif, *, prev=None, nxt=None):
    s = Story()
    root, p, n = s.mirror("t", manifestation=mirror_manif, previous="p", next="n",
                          narrator_voice="x")
    for i, m in enumerate(prev or []):
        s.instantiate(p.id, "m", kind="beat", manifestation=m, id=f"p{i}")
    for i, m in enumerate(nxt or []):
        s.instantiate(n.id, "m", kind="beat", manifestation=m, id=f"n{i}")
    return s


def test_bilocation_is_flagged():
    s = _mirror(
        "He stands in the kitchen holding his daughter's hand.",
        nxt=["His daughter's voice calls from down the hall."],
    )
    _, breaks = scan(s)
    assert any("bilocation" in b and "daughter" in b for b in breaks)


def test_place_teleport_is_flagged():
    s = _mirror(
        "He pauses.",
        prev=["Eli works in the warehouse.", "He locks the trailer door."],
        nxt=["He stands in the kitchen.", "He climbs to the bridge."],
    )
    _, breaks = scan(s)
    assert any("jumps between" in b for b in breaks)


def test_coherent_story_passes():
    s = _mirror(
        "He stands in the kitchen.",
        prev=["He enters the kitchen.", "He sets the cup on the kitchen table."],
        nxt=["He leaves the kitchen and shuts the door behind him."],
    )
    _, breaks = scan(s)
    assert breaks == []


class _ReaderClient:
    def complete(self, prompt, *, system=None):
        return json.dumps({"contradictions": ["the stove clock reads noon, then dawn"]})


def test_model_reader_adds_findings():
    rep = continuity(_mirror("He waits.", nxt=["He waits more."]), _ReaderClient())
    assert not rep.passed
    assert any("clock" in r for r in rep.reader)
