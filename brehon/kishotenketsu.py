"""Kishōtenketsu — the four-part, turn-driven structure, as a composable spine + gate.

Ki (introduction) → Shō (development) → Ten (the turn) → Ketsu (reconciliation).
Where three-act runs on escalating conflict, kishōtenketsu runs on the **ten**: a
recontextualization that makes you re-read what came before. The shape is built with
:meth:`brehon.story.Story.kishotenketsu`, which is *composable* — it can be the root (a
standalone kishōtenketsu story) or nest under any node (a turn inside a three-act act,
or beside other structures). Turning beats are marked ``attributes["turn"] = n``: one
turn is the classic form, several is an iterated descent.

The gate is structural and deterministic, in the spirit of :mod:`brehon.doorways`: every
kishōtenketsu structure must have its four movements present and in order (ki, shō, ten,
ketsu), with at least one turn landing in the *ten* or later — a turn in the setup is no
turn. Whether a turn *genuinely* recontextualizes is a semantic judgement left to the
writer or an LLM check.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from brehon.metaphor import Metaphor
    from brehon.story import Story

ROLES = ("ki", "sho", "ten", "ketsu")


def structures(story: "Story") -> list["Metaphor"]:
    """Every kishōtenketsu structure node in the story (root or nested)."""
    return [n for n in story.walk() if n.kind == "kishotenketsu"]


def movements(story: "Story", node: "Metaphor") -> dict[str, "Metaphor"]:
    """The ``role -> movement`` map for one structure node (its movement children)."""
    out: dict[str, "Metaphor"] = {}
    for child in story.children(node.id):
        role = child.attributes.get("role")
        if child.kind == "movement" and role in ROLES and role not in out:
            out[role] = child
    return out


def turns(story: "Story") -> list[tuple[int, object, "Metaphor"]]:
    """Beats marked as turns: ``(narrative index, turn value, node)``, in order."""
    out: list[tuple[int, object, "Metaphor"]] = []
    for index, node in enumerate(story.walk()):
        value = node.attributes.get("turn")
        if value is not None:
            out.append((index, value, node))
    return out


@dataclass
class KishotenketsuReport:
    count: int                              # number of kishōtenketsu structures found
    reasons: list[str] = field(default_factory=list)

    @property
    def passed(self) -> bool:
        return self.count > 0 and not self.reasons

    def summary(self) -> str:
        if self.count == 0:
            return "kishōtenketsu: no structure present"
        if self.passed:
            n = "1 structure" if self.count == 1 else f"{self.count} structures"
            return f"kishōtenketsu: {n}, four parts in order, turn in/after the ten"
        return "kishōtenketsu: " + "; ".join(self.reasons)


def shape(story: "Story") -> KishotenketsuReport:
    """Each kishōtenketsu structure: four movements present, in ki/shō/ten/ketsu order,
    with at least one turn at or after the ten."""
    nodes = structures(story)
    order = {n.id: i for i, n in enumerate(story.walk())}
    all_turns = turns(story)
    reasons: list[str] = []
    for node in nodes:
        roles = movements(story, node)
        missing = [r for r in ROLES if r not in roles]
        if missing:
            reasons.append(f"{node.id}: missing movement(s) {', '.join(missing)}")
            continue
        positions = [order[roles[r].id] for r in ROLES]
        if positions != sorted(positions):
            reasons.append(f"{node.id}: movements out of order (must be ki, shō, ten, ketsu)")
        ten_pos = order[roles["ten"].id]
        subtree = story.descendants(node.id)
        local = [i for (i, _v, tnode) in all_turns if tnode.id in subtree]
        if not local:
            reasons.append(
                f"{node.id}: no turn marked — set attributes['turn']=n on the turning beat")
        elif not any(i >= ten_pos for i in local):
            reasons.append(
                f"{node.id}: the turn lands before the ten — a turn in the setup is no turn")
    return KishotenketsuReport(len(nodes), reasons)


# ── the descent: an iterated kishōtenketsu, opt-in via descent=True ───────────
DESCENT_ENDINGS = ("no_exception", "resignation", "loop_continues")


def _turn_value(node: "Metaphor") -> int:
    try:
        return int(node.attributes.get("turn"))
    except (TypeError, ValueError):
        return 0


@dataclass
class DescentReport:
    flagged: int                              # kishōtenketsu structures marked descent=True
    reasons: list[str] = field(default_factory=list)

    @property
    def passed(self) -> bool:
        return self.flagged > 0 and not self.reasons

    def summary(self) -> str:
        if self.flagged == 0:
            return "descent: no descent-marked structure"
        if self.passed:
            return "descent: loop recurs, each turn deepens, ends on the no-exception"
        return "descent: " + "; ".join(self.reasons)


def descent(story: "Story", *, min_turns: int = 3) -> DescentReport:
    """The rules of an iterated descent, for any kishōtenketsu marked ``descent=True``:

    * **the loop recurs** — at least ``min_turns`` turns, so the reader is trained to
      expect the escape;
    * **each turn deepens** — the ``turn`` values strictly increase in narrative order
      (number them by darkness);
    * **the no-exception ending** — a closing beat in the *ketsu* whose ``ending`` is one
      of :data:`DESCENT_ENDINGS`, landing at or after the last turn (the loop continues, a
      comeuppance does not).

    Structural only: whether the darkening is *felt*, and whether the ending truly lands as
    resignation, is the writer's judgement — this checks the descent is declared and shaped.
    """
    order = {n.id: i for i, n in enumerate(story.walk())}
    flagged = [n for n in structures(story) if n.attributes.get("descent")]
    reasons: list[str] = []
    for node in flagged:
        subtree = story.descendants(node.id)
        local = sorted((order[t.id], _turn_value(t)) for (_i, _v, t) in turns(story) if t.id in subtree)
        values = [v for _pos, v in local]

        if len(local) < min_turns:
            reasons.append(
                f"{node.id}: the loop must recur to train the reader — found {len(local)} "
                f"turn(s), need >= {min_turns}")
        if not all(values[k] < values[k + 1] for k in range(len(values) - 1)):
            reasons.append(
                f"{node.id}: turns must deepen — number them by increasing darkness "
                f"(turn values, in order, were {values})")

        ketsu = movements(story, node).get("ketsu")
        ending_pos = None
        if ketsu is not None:
            for nid in story.descendants(ketsu.id):
                if str(story.get(nid).attributes.get("ending", "")).lower() in DESCENT_ENDINGS:
                    ending_pos = order[nid] if ending_pos is None else min(ending_pos, order[nid])
        if ending_pos is None:
            reasons.append(
                f"{node.id}: no no-exception ending — a descent closes on the loop continuing, "
                "not a comeuppance (mark the final beat ending='no_exception')")
        elif local and ending_pos < local[-1][0]:
            reasons.append(f"{node.id}: the no-exception ending must land at or after the last turn")
    return DescentReport(len(flagged), reasons)
