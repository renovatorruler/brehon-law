/* THE FOUR OLDS audio play — sc03 v5 for the ear: the simulator is
   furniture, the case is the scene. Target 3:30-4:00.
   Run: CLAUDE_STUDIO_TURN_TIMEOUT_MS=360000 CLAUDE_STUDIO_BUDGET=10 node src/FourOlds_Audio_Sc03.res.mjs */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/a03_barn_net.scene.txt"

let seed: Seed.sceneSeed = {
  id: "audio-03-barn-net-v5",
  slug: "SCENE 3. THE DAWES BARN - NIGHT",
  logline: "Tuesday night at the Dawes barn, for the ear, and the simulator is furniture: trucks up the gravel one by one, the percolator already knocking, one roll call in full ceremony — rehearsal two thousand eight hundred and six — and then the evening's real business: the crew tries the case against this week's parade-winning astronaut, Stitch prosecuting. Taillights, one padlock, wind.",
  cast: [V14Cast.cricket, V14Cast.dutch, V14Cast.stitch, V14Cast.gunny],
  layer: {
    peshat: "four old friends arrive at a barn, open their fifty-year ritual with a roll call, argue about a real astronaut's landing, and go home",
    sod: "pure character, heard blind: four voices distinct inside two words each, the fifty years carried by one spoken number, the friendship carried by the argument — and the last sound is one man alone with the wind and a dark house",
  },
  beats: [
    {
      who: "GUNNY",
      want: "the evening opened and closed to the standard",
      wall: "the evening's actual business is an argument he cannot keep order over",
      turn: "the roll call in full ceremony — 'Apollo Eighteen. Lunar descent rehearsal. Number two thousand, eight hundred and six.' — solemnity at barn scale, nobody laughs; his order-keeping fails all evening; he closes formally anyway: 'Net closed. Same time Tuesday.' / 'God willing.'",
      subtext: "ceremony as love; the number is the fifty years",
    },
    {
      who: "STITCH",
      want: "to try the case against this week's parade-winning astronaut — prosecutor, star witness, and jury",
      wall: "Dutch, who has the figures written down, with dates",
      turn: "he prosecutes: the computer flew it, the landing came in long, 'and that fella's got a patch on his arm and a parade in Houston' — numbers rounding up as he goes, tall-tale rules of evidence invented when caught, total conviction, and he wins the room anyway",
      subtext: "retired varsity trying the league that forgot them",
    },
    {
      who: "DUTCH",
      want: "the record correct, even in a kangaroo court",
      wall: "the correction never changes the verdict",
      turn: "he corrects Stitch's figure from the ledger — page flip audible, the date read aloud — the correction is accepted into evidence, changes nothing, and Dutch joins the unanimous verdict anyway: not one of those boys would have cleared his physical",
      subtext: "accuracy as devotion",
    },
    {
      who: "CRICKET",
      want: "his coffee, his chair, and his crew making this exact noise",
      wall: "the percolator was already going when Gunny walked in, and Gunny noticed",
      turn: "'You slept out here again.' deflected with an operational fact and never answered; he is the flat center all evening; he adjudicates one disputed point in a single sentence; his silence at the verdict is read, correctly, as concurrence",
      subtext: "the widower texture arrives as inference",
    },
  ],
  rules: Belt.Array.concat(
    [
      "THE SIMULATOR IS FURNITURE — hard law from the director. NO operational drill content of any kind: no descent, no readouts, no altitude calls, no instrument faults, no kicks, no contact light, no landing by anyone in this barn, no headsets, no radio-filtered lines. The simulator exists ONLY as: its electrical hum in the room bed, the roll call, and the net-closed line.",
      "SHORT — three and a half to four audio minutes. LEAN SOUND: no more than fifteen ACTION sound entries in the whole scene. Structure: the signature bed (wind on boards, the trainer's hum, the percolator's uneven knock — the beds); gravel and three truck arrivals compressed (engines, doors, gaits, greetings by name); the percolator beat ('You slept out here again.'); the roll call; THE CASE — the main event, almost entirely dialogue, sound only where a cup or a ledger page genuinely lands; the formal close; three engines leaving one by one, the padlock's single pull, wind, a screen door far off, and nothing else on the property.",
      "THE CASE is the engine: Stitch prosecuting this week's real astronaut, Dutch's documented corrections, Gunny's failing order, Cricket's one-sentence adjudication. Specific, technical, personally affronted, dead straight. The skill it implies is CLAIMED, never demonstrated.",
      "CIVILIAN LEGIBILITY, once: the roll call names the mission and the count, and that is all the scene ever explains.",
      "Nobody mentions Peg. The empty house is the last sound's job.",
    ],
    AudioRules.common,
  ),
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=4)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    let sc2 = await Write.liftDialogue(~path=out, ~maxTries=3)
    let _ = Write.emit(sc2, ~txt=out)
    switch Write.verify(out) {
    | Ok() => Js.log("OK audio-03-v5")
    | Error(m) => Js.log("BAD audio-03-v5 — " ++ m)
    }
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED:\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
