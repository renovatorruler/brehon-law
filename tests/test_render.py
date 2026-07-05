from metaphrand import Story
from metaphrand.render import FountainRenderer


def _story_with_one_scene() -> Story:
    s = Story()
    root = s.three_act("a premise", title="Test", credit="written by", author="x")
    act = s.instantiate(root.id, "the setup", kind="act", id="act1")
    s.instantiate(
        act.id, "establish place", kind="beat",
        manifestation="A man stands in an empty room.",
        attributes={"slug": "INT. ROOM - NIGHT"},
        id="b1",
    )
    s.instantiate(
        act.id, "he speaks", kind="beat",
        attributes={"character": "MAN", "parenthetical": "quietly", "dialogue": "Hello."},
        id="b2",
    )
    return s


def test_title_page_emitted_from_root_attributes():
    out = FountainRenderer().render(_story_with_one_scene())
    assert out.startswith("Title: Test\n")
    assert "Credit: written by\n" in out
    assert "Author: x\n" in out


def test_scene_heading_action_and_dialogue_order():
    out = FountainRenderer().render(_story_with_one_scene())
    body = out.split("# ACT ONE", 1)[1]
    assert body.index("INT. ROOM - NIGHT") < body.index("A man stands")
    assert body.index("A man stands") < body.index("MAN")
    assert body.index("MAN") < body.index("(quietly)") < body.index("Hello.")


def test_only_acts_form_the_spine_not_themes_or_motifs():
    s = Story()
    root = s.three_act("p", title="T")
    s.instantiate(root.id, "an act", kind="act", id="act1")
    s.instantiate(root.id, "a theme", kind="theme", id="t1")
    s.instantiate(root.id, "a motif", kind="motif", id="m1")
    out = FountainRenderer().render(s)
    assert out.count("# ACT") == 1
    assert "a theme" not in out and "a motif" not in out


def test_render_is_deterministic():
    s = _story_with_one_scene()
    r = FountainRenderer()
    assert r.render(s) == r.render(Story.from_json(s.to_json()))


def test_blank_lines_are_collapsed():
    out = FountainRenderer().render(_story_with_one_scene())
    assert "\n\n\n" not in out
