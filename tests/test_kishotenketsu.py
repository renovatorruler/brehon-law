from metaphrand import Story
from metaphrand.kishotenketsu import descent, movements, shape, structures, turns
from metaphrand.pipeline import check
from metaphrand.render import FountainRenderer


def _ktk(*, nested=False, turn_on="ten", sid="kishotenketsu"):
    """A kishōtenketsu with one beat per movement; a turn marked on the given role's beat.

    ``turn_on`` may be a role ("ki".."ketsu") or "none" for no turn. With ``nested`` the
    structure hangs inside an act of a three-act root instead of being the root.
    """
    s = Story()
    if nested:
        root = s.three_act("premise")
        act = s.instantiate(root.id, "the act", kind="act", id="act1")
        node, *_ = s.kishotenketsu("idea", parent_id=act.id, id=sid,
                                   ki="setup", sho="develop", ten="turn", ketsu="resolve")
    else:
        node, *_ = s.kishotenketsu("idea", id=sid,
                                   ki="setup", sho="develop", ten="turn", ketsu="resolve")
    for role in ("ki", "sho", "ten", "ketsu"):
        attrs = {"turn": 1} if role == turn_on else {}
        s.instantiate(f"{sid}-{role}", f"the {role}", manifestation=f"{role} beat",
                      kind="beat", id=f"{sid}-{role}-beat", attributes=attrs)
    return s


def test_standalone_structure_built():
    s = _ktk()
    root = s.get(s.root_id)
    assert root.kind == "kishotenketsu"
    roles = movements(s, root)
    assert [r for r in ("ki", "sho", "ten", "ketsu") if r in roles] == ["ki", "sho", "ten", "ketsu"]
    assert len(structures(s)) == 1


def test_shape_passes_with_turn_in_ten():
    assert shape(_ktk(turn_on="ten")).passed


def test_shape_passes_with_turn_in_ketsu():
    assert shape(_ktk(turn_on="ketsu")).passed


def test_turn_before_the_ten_fails():
    rep = shape(_ktk(turn_on="ki"))
    assert not rep.passed
    assert any("before the ten" in r for r in rep.reasons)


def test_no_turn_fails():
    rep = shape(_ktk(turn_on="none"))
    assert not rep.passed
    assert any("no turn" in r for r in rep.reasons)


def test_missing_movement_fails():
    s = Story()
    node = s.instantiate(None, "idea", kind="kishotenketsu", id="k")
    s.set_root(node.id)
    for role in ("ki", "sho", "ten"):  # ketsu omitted
        s.instantiate(node.id, role, kind="movement", id=f"k-{role}", attributes={"role": role})
    rep = shape(s)
    assert not rep.passed
    assert any("missing" in r and "ketsu" in r for r in rep.reasons)


def test_iterated_turns_allowed():
    """Several turns (the spiral) are fine; the shape still passes."""
    s = _ktk(turn_on="ten")
    ketsu = movements(s, s.get(s.root_id))["ketsu"]
    s.instantiate(ketsu.id, "second turn", manifestation="another turn",
                  kind="beat", id="turn-2", attributes={"turn": 2})
    assert len(turns(s)) == 2
    assert shape(s).passed


def test_standalone_renders_movements_in_order():
    script = FountainRenderer().render(_ktk())
    assert script.index("KI") < script.index("SH") < script.index("TEN") < script.index("KETSU")
    assert script.index("ki beat") < script.index("ketsu beat")


def test_nested_in_three_act_passes_and_renders_in_place():
    s = _ktk(nested=True)
    assert shape(s).passed
    script = FountainRenderer().render(s)
    assert "KI" in script and "TEN" in script and "ten beat" in script


def test_pipeline_accepts_and_gates_kishotenketsu():
    rep = check(_ktk())
    by = {stage.name: stage for stage in rep.stages}
    assert by["spine"].passed
    assert "kishotenketsu" in by and by["kishotenketsu"].passed
    assert "doorways" not in by  # a three-act device, skipped for a pure kishōtenketsu spine
    assert "descent" not in by   # not a descent -> the descent gate stays silent


# -- the descent gate (opt-in via descent=True) --------------------------------

def _descent(*, turns_values=(1, 2, 3), ending="no_exception"):
    """A descent-flagged kishōtenketsu: deepening turns in the ten, a closing ketsu beat."""
    s = Story()
    _, ki, sho, ten, ketsu = s.kishotenketsu(
        "descent", id="d", descent=True, ki="setup", sho="develop", ten="turn", ketsu="resolve")
    s.instantiate(ki.id, "open", manifestation="open", kind="beat", id="d-open")
    for i, v in enumerate(turns_values):
        s.instantiate(ten.id, f"turn {v}", manifestation=f"turn {v}", kind="beat",
                      id=f"d-turn-{i}", attributes={"turn": v})
    attrs = {"ending": ending} if ending else {}
    s.instantiate(ketsu.id, "close", manifestation="the loop restarts", kind="beat",
                  id="d-close", attributes=attrs)
    return s


def test_descent_flag_sets_attribute():
    assert _descent().get("d").attributes.get("descent") is True


def test_descent_passes_when_recurs_escalates_and_ends_no_exception():
    assert descent(_descent(turns_values=(1, 2, 3))).passed


def test_descent_too_few_turns_fails():
    rep = descent(_descent(turns_values=(1, 2)))  # 2 < default min_turns 3
    assert not rep.passed and any("must recur" in r for r in rep.reasons)


def test_descent_non_increasing_turns_fail():
    rep = descent(_descent(turns_values=(1, 3, 2)))
    assert not rep.passed and any("must deepen" in r for r in rep.reasons)


def test_descent_without_no_exception_ending_fails():
    rep = descent(_descent(ending=None))
    assert not rep.passed and any("no-exception" in r for r in rep.reasons)


def test_descent_not_applicable_when_unflagged():
    rep = descent(_ktk())  # a plain (non-descent) kishōtenketsu
    assert rep.flagged == 0 and not rep.passed


def test_pipeline_runs_descent_gate_when_flagged():
    by = {st.name: st for st in check(_descent()).stages}
    assert "descent" in by and by["descent"].passed
    assert by["kishotenketsu"].passed
