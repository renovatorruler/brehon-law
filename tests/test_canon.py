from brehon import Story
from brehon.canon import CanonFact, attach, block, consistency, facts
from brehon.dossier import Dossier, Fact, attach as attach_bible, write_bible


class _FakeClient:
    """Returns a fixed reply; records the prompts it was given."""

    def __init__(self, reply: str) -> None:
        self.reply = reply
        self.prompts: list[str] = []

    def complete(self, prompt: str, *, system=None) -> str:
        self.prompts.append(prompt)
        return self.reply


def _story(*names):
    s = Story()
    s.three_act("premise")  # root id defaults to "three-act"
    for name in names:
        s.instantiate("three-act", name, kind="character", id=name.lower())
    return s


def test_canonfact_roundtrips():
    f = CanonFact("CLAIRE", "Ruth reborn, no blood relation")
    assert CanonFact.from_dict(f.to_dict()) == f


def test_attach_and_read():
    s = _story("CLAIRE")
    attach(s, [CanonFact("CLAIRE", "Ruth reborn"), CanonFact("RUTH", "the pure crusader")])
    fs = facts(s)
    assert [f.entity for f in fs] == ["CLAIRE", "RUTH"]


def test_block_renders_ground_truth():
    s = _story("CLAIRE")
    attach(s, [CanonFact("CLAIRE", "Ruth reborn, no blood relation")])
    b = block(s)
    assert "GROUND TRUTH" in b and "CLAIRE" in b and "Ruth reborn" in b


def test_block_empty_without_canon():
    assert block(_story("CLAIRE")) == ""


def test_write_bible_conditions_on_canon_and_prior_characters():
    s = _story("CLAIRE", "RUTH")  # walked in this order
    attach(s, [CanonFact("CLAIRE", "Ruth reborn, no blood relation")])
    client = _FakeClient('{"facts": [{"text": "a fact", "depth": "submerged"}]}')
    write_bible(s, "premise", client)
    assert len(client.prompts) == 2
    assert "GROUND TRUTH" in client.prompts[0]          # canon fed into the first bible
    assert "ALREADY ESTABLISHED" in client.prompts[1]    # the prior character carried forward
    assert "CLAIRE" in client.prompts[1]


def test_consistency_passes_without_canon():
    assert consistency(_story("CLAIRE"), None).passed   # early-out; client untouched


def test_consistency_flags_a_contradiction():
    s = _story("CLAIRE")
    attach(s, [CanonFact("CLAIRE", "Ruth reborn, no blood relation")])
    attach_bible(s, [Dossier("CLAIRE", [Fact("Claire is Ruth's niece.", "submerged")])])
    client = _FakeClient(
        '{"contradictions": [{"fact": "Claire is Ruth\'s niece.", '
        '"canon": "Ruth reborn, no blood relation"}]}')
    rep = consistency(s, client)
    assert not rep.passed
    assert rep.conflicts[0][0] == "CLAIRE"


def test_consistency_passes_when_clean():
    s = _story("CLAIRE")
    attach(s, [CanonFact("CLAIRE", "Ruth reborn")])
    attach_bible(s, [Dossier("CLAIRE", [Fact("Claire maps corruption like a disease.", "submerged")])])
    assert consistency(s, _FakeClient('{"contradictions": []}')).passed
