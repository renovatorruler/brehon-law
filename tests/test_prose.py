from brehon import Story, canon
from brehon.dossier import Dossier, Fact, attach as attach_bible
from brehon.prose import ProseRenderer


class _Rec:
    """A fake prose client: returns a fixed reply, records the prompts it was given."""

    def __init__(self, reply: str) -> None:
        self.reply = reply
        self.prompts: list[str] = []

    def complete(self, prompt: str, *, system=None) -> str:
        self.prompts.append(prompt)
        return self.reply


def _story():
    s = Story()
    root, ki, sho, ten, ketsu = s.kishotenketsu(
        "idea", id="k", ki="setup", sho="develop", ten="turn", ketsu="resolve")
    s.instantiate(ki.id, "the open", manifestation="He sets the cup down.", kind="beat", id="b1")
    s.instantiate(ten.id, "the turn", manifestation="He signs the page.", kind="beat", id="b2",
                  attributes={"turn": 1})
    s.instantiate(root.id, "REESE", kind="character", id="reese", attributes={"want": "to win"})
    canon.attach(s, [canon.CanonFact("REESE", "corrupt to the core")])
    attach_bible(s, [Dossier("REESE", [Fact("He once believed, long ago.", "submerged")])])
    return s


def test_renders_a_passage_per_beat():
    rec = _Rec("Rendered prose passage.")
    prose = ProseRenderer().render(_story(), rec)
    assert prose.count("Rendered prose passage.") == 2  # one per spine beat (b1, b2)
    assert len(rec.prompts) == 2


def test_prompt_carries_canon_iceberg_and_the_bare_fact():
    rec = _Rec("x")
    ProseRenderer().render(_story(), rec)
    first = rec.prompts[0]
    assert "GROUND TRUTH" in first          # canon fed in
    assert "WHAT YOU KNOW" in first         # the iceberg fed in
    assert "He sets the cup down" in first  # the bare fact of beat 1


def test_continuity_is_fed_forward():
    rec = _Rec("PASSAGE")
    ProseRenderer(tail_chars=500).render(_story(), rec)
    assert "THE STORY SO FAR" in rec.prompts[1]  # the second beat sees the first


def test_empty_when_no_beats():
    s = Story()
    s.three_act("premise")
    assert ProseRenderer().render(s, _Rec("x")) == ""


class _Seq:
    """A fake client that returns a sequence of replies (the last one repeats)."""

    def __init__(self, replies):
        self.replies = list(replies)
        self.i = 0
        self.prompts: list[str] = []

    def complete(self, prompt, *, system=None):
        self.prompts.append(prompt)
        reply = self.replies[min(self.i, len(self.replies) - 1)]
        self.i += 1
        return reply


def test_repair_rewrites_a_flowery_passage():
    client = _Seq(["He moved like a ghost.", "He moved.", "He set the page down."])
    renderer = ProseRenderer(repair=True, max_tries=3)
    prose = renderer.render(_story(), client)
    assert "like a ghost" not in prose      # the simile was rewritten away
    assert "He moved." in prose
    assert renderer.repairs[0][1] == 2       # beat 1 needed two tries


def test_repair_rewrites_a_leak():
    client = _Seq(["He once believed, long ago, and it still showed on him.",
                   "He poured the coffee.", "He signed the page."])
    renderer = ProseRenderer(repair=True)
    prose = renderer.render(_story(), client)
    assert "once believed" not in prose      # the submerged fact was repaired out
    assert renderer.repairs[0] == ("b1", 2, True)
