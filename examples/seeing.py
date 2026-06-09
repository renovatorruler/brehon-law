"""THE SEEING — the undercover/cult story, encoded as a managed beat sheet.

An undercover cop with no self of his own is sent into a cult that promises to make
its members famous artists, and can't tell anymore which of his selves is the cover.
Tone: a deadpan tragicomedy in the key of *Patriot* (the flesh carries that).
The data structure fixes the deep craft (the transformation, the mirror, the two
doorways, which beat fills which slot, the cast, the submerged backstory) and hands
the rest — the flesh, the continuity, the words — to the writer.

Run with:  python -m examples.seeing
"""

from metaphrand import Story
from metaphrand.dossier import Dossier, Fact, attach as attach_bibles
from metaphrand.prompt import to_beat_list
from metaphrand.world import (
    ALLY, GUARDIAN, HERALD, HERO, MENTOR, SHADOW, SHAPESHIFTER, TRICKSTER,
    Character, World,
)


def build() -> Story:
    s = Story()
    root, before, after = s.mirror(
        "A man who dissolved himself into his function until there was no self left to "
        "leak -- a professional nobody -- is handed a self by people who are lying to "
        "him, and has to decide, with the law screaming in his ear, whether the truest "
        "thing he ever made was a con or a confession",
        manifestation="At the Collective's rebirth rite, told to burn the man who "
        "couldn't and make the truest thing he has in front of them all, the cop who "
        "came to perform sincerity makes something real, and cannot tell afterward "
        "whether he conned them or confessed.",
        previous="the professional nobody, emptiness wearing competence",
        next="the man who found a self, and what it cost him",
        title="THE SEEING",
        narrator_voice="am_adam",
        cast={"DANNY": "am_michael", "MARSH": "am_onyx", "NORA": "af_sarah",
              "ELI": "am_liam", "REYES": "af_kore", "PRIYA": "af_bella",
              "COWAN": "am_puck", "AUGUST": "am_echo", "BRENNAN": "am_fenrir"},
    )
    # Logline (the loop, then the exception): the ordinary world is the cop who
    # disappears into role after role; the exception is a self he might want.
    root.attributes["logline"] = (
        "An undercover cop who has spent his career disappearing into one fake "
        "identity after another, with nothing of his own left underneath, is sent to "
        "infiltrate a cult that makes its members feel like real artists, and the "
        "role he is there to play becomes the first true self he has ever had.")

    # -- BEFORE the rite: the empty man, seen, and seduced ------------
    # Everything up to the Midpoint lives here, so the spine is genuinely
    # chronological and a cold open on the rite flashes back through all of it.
    s.instantiate(before.id, "Danny is a police detective who works undercover. He closes out a months-long job, shaking the suspect's hand under the false name he has worn for a year while the arrests go down behind him, then drives back to a borrowed apartment and sits there with the part switched off and nothing under it",
                  kind="beat", id="b-cover", attributes={"function": "Opening Image"})
    s.instantiate(before.id, "A young man named Eli, who belonged to an art collective that promises to turn its members into famous artists, is found drowned. The police call it a suicide and close the case. His older sister Nora does not buy it, and she keeps after the department until they agree to open it again",
                  kind="beat", id="b-river")  # the case that starts it
    s.instantiate(before.id, "Danny's lieutenant, Reyes, hands him the case and sends him into the collective undercover, since a group like this only opens to the people it draws in. She picks him for it, and the reason is an ugly one: there is so little of him that nothing personal can leak, and nothing of his own gets in the way",
                  kind="beat", id="b-theme", attributes={"function": "Theme Stated", "character": "REYES", "dialogue": "yes"})
    s.instantiate(before.id, "What is left of Danny's own life barely fills the apartment. There is an ex-wife's number he never dials and a roll of film he keeps meaning to develop and never does. He eats his dinner standing at the sink. He has always been better at wearing other people than at being himself",
                  kind="beat", id="b-empty", attributes={"function": "Set-Up"})
    s.instantiate(before.id, "A letter catches up with him at the cover name, from his last job: a nineteen-year-old named Petey, doing eleven years because Danny got close to him and then testified. Petey still writes to the man who put him away, asking when he is getting out, and Danny never writes back",
                  kind="beat", id="b-petey")  # the cost of the job
    s.instantiate(before.id, "Danny goes in. At his first Seeing, the collective's central ritual, the members sit him in the middle of the circle and take turns naming what they see in him, his gifts, his wounds, the greatness they swear is waiting in him. It is the closest attention anyone has ever paid him, and instead of shrugging it off he stays in the chair",
                  kind="beat", id="b-inside", attributes={"function": "Catalyst"})
    s.instantiate(before.id, "He keeps telling himself it is only the job. But his reports to Reyes get shorter, he stays at the loft a little later every week, and before long he is sleeping there",
                  kind="beat", id="b-debate", attributes={"function": "Debate"})
    s.instantiate(before.id, "He stops by the grave of Brennan, the older detective who trained him and was the closest thing he had to a father. Brennan once told him that his knack for vanishing into other people was also a wound, and that one day he would have to choose between them. Danny did not listen",
                  kind="beat", id="b-brennan")  # the dead mentor
    s.instantiate(before.id, "The cover calls for him to make art, so for the first time in thirty years he picks up a pencil. He makes one true thing, they hang it on the wall, and the whole room goes quiet in front of it. That night he does not go home",
                  kind="beat", id="b-firsttrue", attributes={"doorway": 1})
    s.instantiate(before.id, "Nora, who still has no idea he is a cop, catches him outside the gallery and pushes her dead brother's unmailed letters into his hands. She is after the truth and will not take anything performed or polite. No one has ever asked that much of Danny in his life",
                  kind="beat", id="b-nora", attributes={"function": "B Story", "character": "NORA", "dialogue": "yes"})
    s.instantiate(before.id, "He sinks further into the life. They keep a seat for him at the table, the leader, Marsh, walks him around the building with a hand on his shoulder, and the calls from his own department start going to voicemail",
                  kind="beat", id="b-fun", attributes={"function": "Fun and Games"})
    s.instantiate(before.id, "He also sees how the whole machine runs. The members sign their savings over to Marsh as patronage, the collective's gallery washes the money clean, and the work the members make leaves the building under Marsh's name and comes back as cash",
                  kind="beat", id="b-money")  # the economics
    s.instantiate(before.id, "A newcomer named Priya, twenty years old and the real thing, gets moved into the same chair Eli used to sit in, and the group starts telling her she is going to be great",
                  kind="beat", id="b-priya")  # the clock starts
    s.instantiate(before.id, "An older member, August, a dentist who sold his practice to come inside, breaks down in the circle while they promise him he has a gift no one else has, and he writes the collective another check",
                  kind="beat", id="b-august")  # the world's daily life

    # -- the MIRROR is the Midpoint: DANNY'S rite (con or confession?) -

    # -- AFTER the rite: the consequences, and the test --------------
    s.instantiate(after.id, "At a fair, a buyer mistakes a photo of Eli for Mr. Marsh's assistant. Danny pulls the thread and there it is: Marsh has been selling Eli's paintings as his own for years. Eli found that out, and that is what put him in the river. Priya is walking the same road",
                  kind="beat", id="b-truth", attributes={"function": "Bad Guys Close In"})
    s.instantiate(after.id, "Cowan, the true believer who keeps Marsh's real books and quietly cleans up after the members who fall apart, starts to make Danny for a cop and begins watching the doors",
                  kind="beat", id="b-cowan")  # suspicion mounts
    s.instantiate(after.id, "One night Danny drives past the house that used to be his. His ex-wife's car is parked in the driveway of a life that went on without him. He does not slow down",
                  kind="beat", id="b-maria")  # the cost
    s.instantiate(after.id, "Reyes brings him in and tapes a wire to his chest. The plan is simple: get Marsh on tape the night they rebirth Priya, then bring the whole thing down. To hold on to his badge, which by now is just one more part he was handed, Danny has to destroy the one life that finally fit him",
                  kind="beat", id="b-wire", attributes={"doorway": 2})
    s.instantiate(after.id, "Alone with the wire lying on the table, Danny cannot even say which of his two selves it is meant for. The thing the collective keeps offering him, to be seen, to be somebody, is the same thing that put Eli in the river, and he is walking straight at the same edge",
                  kind="beat", id="b-abyss", attributes={"function": "Dark Night of the Soul"})
    s.instantiate(after.id, "Four in the morning, the wire and the badge side by side on the kitchen table. The question the collective kept putting to him, and the one he could never answer, is what he is actually after, and at that table, for the first time in his life, he answers it out loud",
                  kind="beat", id="b-what", attributes={"function": "Break into Three"})
    s.instantiate(after.id, "It is the night of Priya's rebirth rite. Wired to hand the police their case against Marsh, Danny instead steps into the circle, pulls Priya out before it can close around her, and brings the whole thing down with his own real name on the record",
                  kind="beat", id="b-finale", attributes={"function": "Finale"})
    s.instantiate(after.id, "Months later, Danny finally develops that roll of film. In the pictures there is a man who is, at last, actually somewhere. Across a diner table, Nora looks at him and sees him plainly, with no cover and no act left between them",
                  kind="beat", id="b-final", attributes={"function": "Final Image"})

    # -- CAST: the archetypal ensemble --------------------------------
    World([
        Character("danny", "DANNY", HERO, "to stay no one, in clean and out clean", "m"),
        Character("marsh", "MARSH", SHADOW, "to confer the greatness he was denied", "m"),
        Character("nora", "NORA", ALLY, "to make someone admit what really happened to her brother", "f"),
        Character("eli", "ELI", HERALD, "to have been seen all the way down (he is dead)", "m"),
        Character("reyes", "REYES", GUARDIAN, "to keep the badge a real self, and her officer on the right side of it", "f"),
        Character("priya", "PRIYA", SHAPESHIFTER, "to be the great one they promised her", "f"),
        Character("brennan", "BRENNAN", MENTOR, "the road already walked: the gift is the wound (he is dead)", "m"),
        Character("cowan", "COWAN", TRICKSTER, "to keep the Collective's secrets and his place in it", "m"),
        Character("august", "AUGUST", ALLY, "to not have been ordinary", "m"),
    ]).attach(s)

    # -- BACKSTORY: the iceberg (full bible in stories/the-seeing/seeing_bible.md) --
    attach_bibles(s, [
        Dossier("DANNY", [
            Fact("Black coffee he lets go cold, eats standing up, sleeps fine in a stranger's bed and not in his own.", "surface"),
            Fact("Four foster houses by fifteen; learned to read a new house in an afternoon and become the kid it wanted; never unpacked the bag.", "submerged"),
            Fact("Drew as a boy to disappear into the page; a teacher said he vanished into a page the way other kids vanish out a door, and he stopped the next day, because being seen was worse than being hit.", "submerged"),
            Fact("Took undercover work for the self-erasure, not despite it; suspects there is no one under the covers and cannot look at the suspicion.", "submerged"),
            Fact("Pisces sun, Gemini moon, Scorpio rising, Sun conjunct Neptune -- the self that dissolves when he reaches for it; a kid named Petey does eleven years on his word and writes to the cover name.", "submerged"),
        ]),
        Dossier("MARSH", [
            Fact("Paint under his nails each morning from a tube he never otherwise opens.", "surface"),
            Fact("A real young painter once, ended by a critic in four sentences he can still recite, outdone by a rival who couldn't draw; built the Collective because he could not be let in the gate.", "submerged"),
            Fact("Sells the members' work under his own name and calls it tuition; tells them their fame is ripening out of the light.", "submerged"),
            Fact("Recognizes Danny on sight as another empty one, the only kind who really understands the offer; he is courting a mirror, not conning a mark.", "submerged"),
            Fact("Loved Eli, and went down to the river alone every week for a month after, at the hour the boy went in.", "submerged"),
        ]),
        Dossier("ELI", [
            Fact("A gifted painter, twenty-three, no family but the Collective; ruled a suicide, pulled from the river.", "surface"),
            Fact("He was the proof the others were sold on; his paintings left the building under Marsh's name for four years while he was told his hour was coming.", "submerged"),
            Fact("A buyer called him Marsh's assistant, the floor went out, and the self the Collective built him died, and the boy with it.", "submerged"),
        ]),
        Dossier("NORA", [
            Fact("Night-shift x-ray tech; reads bones for a living and trusts what's there over what people swear.", "surface"),
            Fact("Raised Eli after their mother left, signed him into the class that became the cult, and will not forgive herself; keeps his unmailed letters in a coffee can.", "submerged"),
            Fact("She is the only one who loved Eli for himself and not the promise -- the real version of the thing the cult forges.", "submerged"),
        ]),
        Dossier("REYES", [
            Fact("Twenty-two years on the job, a pension she can taste, a daughter at the academy.", "surface"),
            Fact("Believes the badge is a real self you can put on and have it be true -- the law as its own cult, and she its truest member.", "submerged"),
        ]),
    ])

    return s


if __name__ == "__main__":
    print(to_beat_list(build()))
