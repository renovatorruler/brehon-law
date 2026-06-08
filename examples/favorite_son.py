"""FAVORITE SON (working title) — the descent story, encoded into the engine.

A kishōtenketsu DESCENT: a corrupt man the reader keeps hoping is secretly good, who keeps
escaping into a deeper, darker corruption, until we are left with the corrupt man who made
it all the way. The redemption is the con; there is no hidden virtue at the bottom. PaRDeS
for the depths (Peshat→Sod), the *ten* for the drops, the loop for the pages, resignation
for the floor.

This file is the deterministic SEED: a kishōtenketsu root marked ``descent=True``, the six
incidents as beats across ki/shō/ten/ketsu with deepening turns and a no-exception ending,
the themes/motifs that braid them, the cast, and the authoritative CANON. Run it to render
the spine, run every gate (including the descent gate), and persist the whole story — with
the canon-conditioned bibles re-attached — to ``stories/favorite_son.story.json``.
"""

from __future__ import annotations

import os
import sys

from brehon import canon
from brehon.story import Story

PREMISE = (
    "A corrupt political fixer the public keeps needing to believe is secretly good. "
    "Twenty years ago DANIEL REESE was the true-believer protege of RUTH, the one real "
    "anti-corruption crusader the state ever had. The machine destroyed her; the lesson "
    "Reese took was not to fight harder but that believers always lose -- so he joined "
    "the people who killed her and has worn her cause as a costume ever since. He recruits "
    "a new true believer, CLAIRE (Ruth reborn), and spends her faith to bury the one "
    "investigation that could jail the machine. The redemption arc he sells is the con."
)

# Authoritative world ground-truth — what canon-conditioned write_bible and the
# consistency gate enforce. Each line fixes a place the stateless loop once drifted.
CANON = [
    canon.CanonFact(
        "DANIEL REESE",
        "Twenty years ago he was RUTH's true-believer protege. The machine destroyed her; he took "
        "the lesson that believers always lose and joined her killers. He is corrupt to the core "
        "with NO hidden virtue and NO secret good plan, and has no blood relation to anyone."),
    canon.CanonFact(
        "CLAIRE SOTO",
        "A new true believer, Ruth reborn in spirit ONLY -- NO blood relation to Ruth or anyone. "
        "Reese recruits her and spends her faith. She is the reader's avatar, not secretly running "
        "her own game."),
    canon.CanonFact(
        "RUTH",
        "The one pure anti-corruption crusader. The machine destroyed her (a manufactured scandal, "
        "then ruin, then death). She NEVER framed anyone and was never corrupt. Mentor to young Reese."),
    canon.CanonFact(
        "VINCENT CARDELL",
        "The cold machine boss who destroyed Ruth and installed Reese. He is NOT conflicted, guilt-"
        "ridden, or sympathetic, and does not protect Claire. He owns Reese."),
    canon.CanonFact(
        "MARA ELLIS",
        "Ruth's surviving loyal ally; she holds the real evidence and waits for someone honest, and "
        "brings it to Claire. She did not name or raise Claire."),
    canon.CanonFact(
        "THE WORLD",
        "A U.S. state owned by one political machine for fifty years; a special Commission holds the "
        "evidence that could jail the bosses; Reese's plan is to win power over it and bury it under "
        "Claire's trusted signature."),
]


def build() -> Story:
    s = Story()
    root, ki, sho, ten, ketsu = s.kishotenketsu(
        "We would rather believe a powerful man is secretly good than admit he is exactly "
        "what he looks like; the redemption is the con.",
        id="favorite-son", descent=True,
        ki="the plain read: a good man in a dirty business",
        sho="the interpretation we build for him: the noble con",
        ten="the secret, which is a void: he made it all the way",
        ketsu="we are left reconciled to the man who made it all the way",
        title="Favorite Son", author="brehon",
    )

    # themes (abstract domains) and motifs (concrete recurring vehicles) -> a real DAG
    for tid, meaning in {
        "cycle": "the believer is converted into the thing that destroys believers",
        "orchard": "the descent into him destroys the pure and spares the corrupt",
        "forgiveness": "we forgive power what we crucify the weak for",
    }.items():
        s.instantiate(root.id, meaning, kind="theme", id=tid)
    for mid, meaning in {
        "box": "the sealed evidence that could jail the machine",
        "costume": "Ruth's crusade worn as a disguise by the man who betrayed it",
        "seal": "the saint's signature that buries the truth",
    }.items():
        s.instantiate(root.id, meaning, kind="motif", id=mid)

    # the six incidents, deepening turn by turn, laid across the four movements.
    # (movement, id, meaning, manifestation, attributes, extra theme/motif parents)
    beats = [
        (ki, "b-tape", "the manufactured martyrdom",
         "Two weeks before the vote, a hotel-room video of Reese and a woman who is not his wife "
         "is on every phone in the state. He calls a press conference, does not deny it, and walks "
         "out to applause.", {}, ["forgiveness"]),
        (sho, "b-money", "the threat turned into the shield",
         "Claire lays the wire transfers on the table between them. He does not flinch. When she "
         "leaves, the file is in her bag and she has decided not to file it.", {"turn": 1}, ["cycle"]),
        (sho, "b-false", "the false mirror",
         "He tells her he is only their man to get inside and burn them down. She believes him. So "
         "do we.", {"turn": 2}, ["costume"]),
        (ten, "b-fallguy", "a nobody fed to the wolves to feed the bosses",
         "Reese walks a mid-level clerk past the cameras in handcuffs and calls it the first of "
         "many. The clerk's wife is in the gallery.", {"turn": 3}, ["forgiveness"]),
        (ten, "b-witness", "the saint discredits the honest witness",
         "He slides a folder across to Claire -- the woman's psych records, her debts. Claire is "
         "the one who calls her a plant.", {"turn": 4}, ["orchard", "costume"]),
        (ten, "b-death", "the death he is never charged with",
         "The woman is found in her car in a closed garage. Reese reads her name aloud on the "
         "capitol steps and his voice breaks.", {"turn": 5}, ["orchard"]),
        (ten, "b-burial", "the vault sealed with the saint's name",
         "Reese lays the closing report in front of Claire and uncaps a pen. She signs. The box "
         "goes into the archive and the lock turns.", {"turn": 6}, ["box", "seal"]),
        (ketsu, "b-restart", "the loop runs again where we cannot follow",
         "Months later, a new city. Reese buys coffee for a young lawyer with clean shoes and says "
         "the line he said to Claire.", {"ending": "no_exception"}, ["cycle"]),
    ]
    for movement, bid, meaning, manifestation, attrs, parents in beats:
        s.instantiate(movement.id, meaning, manifestation=manifestation, kind="beat",
                      id=bid, attributes=attrs)
        for parent in parents:
            s.link(parent, bid)

    # cast as character nodes; 'want' seeds the (canon-conditioned) backstory loop
    for name, want in [
        ("DANIEL REESE", "to never again be a believer who loses; to win, and call winning proof"),
        ("CLAIRE SOTO", "to prove the good man exists -- because if he does not, her whole life is a mistake"),
        ("RUTH", "to make the machine answer; the fight that destroyed her"),
        ("VINCENT CARDELL", "to keep the machine's bodies buried and his creature obedient"),
        ("MARA ELLIS", "to finish Ruth's work and put the real evidence in honest hands"),
    ]:
        s.instantiate(root.id, name, kind="character", attributes={"want": want})

    canon.attach(s, CANON)
    return s


def reattach_saved_bibles(story: Story, path: str = "stories/favorite_son.story.json") -> int:
    """Carry the canon-conditioned bibles we already generated onto this re-encoded story.
    Backstory lives on character nodes by name, so it survives a change of spine."""
    if not os.path.exists(path):
        return 0
    saved = {n.meaning: n.attributes.get("backstory")
             for n in Story.load(path).walk() if n.kind == "character"}
    count = 0
    for node in story.walk():
        if node.kind == "character" and saved.get(node.meaning):
            node.attributes["backstory"] = saved[node.meaning]
            count += 1
    return count


if __name__ == "__main__":
    from brehon.pipeline import check
    from brehon.render import FountainRenderer, OutlineRenderer

    story = build()
    reused = reattach_saved_bibles(story)  # read before we overwrite below
    print(f"story: {len(story)} nodes | root={story.root_id} | descent | "
          f"{reused} canon-conditioned bibles re-attached")

    if "--outline" in sys.argv:
        print("\n=== the DAG ===")
        print(OutlineRenderer().render(story))

    print("\n=== render (kishōtenketsu descent) ===")
    print(FountainRenderer().render(story))

    print("=== gates ===")
    for stage in check(story).stages:
        print("  ", stage.line())

    story.save("stories/favorite_son.story.json")
    print("\nsaved -> stories/favorite_son.story.json")

    if "--bible" in sys.argv:  # optional: regenerate bibles from this seed via ollama
        from brehon import dossier
        from brehon.generate import OllamaClient
        warnings: list[str] = []
        dossier.attach(story, dossier.write_bible(story, PREMISE, OllamaClient(), warnings=warnings))
        for w in warnings:
            print("[warn]", w)
        story.save("stories/favorite_son.story.json")
        print("regenerated canon-conditioned bibles -> saved")
