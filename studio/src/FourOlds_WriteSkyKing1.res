/* THE FOUR OLDS — the Sky King myth, first telling. Pays off sc11's interrupted
   radio tease (Stitch: "Y'all want to hear something about this job—" / Dutch:
   "Not on the air."). Deliberately ends on pure glory, no resolution — the
   reveal of what happened to Sky King is reserved for the second telling
   (FourOlds_WriteSkyKing2.res), during the TLI coast. Engine-written. */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/draft/engine_sky_king_1.scene.txt"

let seed: Seed.sceneSeed = {
  id: "four-olds-sky-king-first-telling",
  slug: "INT. TRI-COUNTY AUCTION BARN - DAY (LATER)",
  logline: "A work break. Stitch finally gets to finish the story the radio net cut him off from telling — a baggage handler who taught himself to fly on a simulator, then one day stole an empty airliner and flew it like he'd always owned it. The telling ends on pure glory, unresolved; nobody in the room thinks to ask what happened to the man afterward.",
  cast: [
    {
      name: "STITCH",
      who: "one of the four old radio-net friends, dry, terse, catastrophic-understatement register. Finally gets to tell a story he was cut off from telling on an open channel. Tells it fondly, admiringly — pure legend, not a cautionary tale.",
      register: "dry, plain, leashed — a story told the way a terse old man actually tells a 'you won't believe this guy' story to a friend: compressed to the essential beats, no incremental corrections, no padding.",
      earnsEloquence: false,
      lexicon: "plain aviation terms, said flat.",
    },
    {
      name: "CRICKET",
      who: "the protagonist, doesn't know this story yet. Checklist-grammar, deflects feelings into practical questions.",
      register: "spare, plain, a handful of words at most per line.",
      earnsEloquence: false,
      lexicon: "plain, procedural.",
    },
  ],
  layer: {
    peshat: "an old friend finally gets to tell the story he wasn't allowed to finish on the radio",
    sod: "this is the exact shape of what Cricket himself is being asked to become — practiced in secret for years, then one day just takes the real thing — though nobody in the room says this out loud, not even to themselves",
  },
  beats: [
    {
      who: "STITCH",
      want: "finally tell the Sky King story he got cut off from telling on the radio",
      wall: "none — Cricket simply doesn't know it yet",
      turn: "tells it clean and short: a baggage handler, never a pilot, practiced on a sim for years; one day stole an empty airliner off the tarmac (nobody aboard — Cricket assumes 'hijacked,' Stitch corrects him in one line); flew it out over the mountains, clean barrel roll, and when fighter jets scrambled to box him in he waved at the pilots. The story just stops there, on the wave — nobody asks what happened to him after",
      subtext: "myth being passed hand to hand between men who don't discuss why a story matters, they just tell it",
    },
  ],
  rules: [
    "RUTHLESSLY SHORT. This is a myth told between two terse old men, not a report — six to ten lines of dialogue total, no more. Every fact in the brief must appear, compressed to the fewest words that carry it. No extra characters, no incremental back-and-forth correction volleys.",
    "The theft must read as theft, never hijacking: nobody was aboard the plane. If Cricket assumes 'hijacked,' Stitch corrects it in exactly one short line, then moves on immediately — do not dwell on the correction.",
    "The story ENDS on the image of Sky King waving at the fighter jets. Do NOT have anyone ask what happened to him afterward, do NOT reveal his fate, do NOT hint at an ending either way — happy or sad. This is deliberate: his fate is reserved for a later scene and must not be spoiled or foreshadowed here even obliquely.",
    "Stitch tells this fondly, admiringly, with something like a grin — pure legend, not a cautionary tale. Keep his tone dry and plain even while admiring; no purple prose, no flowery description of the flight itself (plain physical facts: mountains, barrel roll, jets, a wave).",
    "Fountain screenplay format: a slugline, plain action lines describing only what a camera would see, colon-terminated CHARACTER NAME: dialogue cues (this project's standing convention).",
    "Kill every AI-writing tell: em-dash overuse, rule-of-three, negative parallelism, inflated vocabulary, cute authorial conceits, ironic narrator asides.",
  ],
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=5)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    Js.log("=== ENGINE WROTE: SKY KING FIRST TELLING ===\n")
    Js.log(Cinema_Backends.readText(out))
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED (gate):\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
