/* THE FOUR OLDS audio play — audition scene: sc03 THE BARN NET, adapted
   for the ear from locked v14.1. One scene, for the user's read, before
   the full adaptation wave.
   Run: CLAUDE_STUDIO_TURN_TIMEOUT_MS=360000 CLAUDE_STUDIO_BUDGET=10 node src/FourOlds_Audio_Sc03.res.mjs */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/a03_barn_net.scene.txt"

let seed: Seed.sceneSeed = {
  id: "audio-03-barn-net",
  slug: "SCENE 3. THE DAWES BARN - NIGHT",
  logline: "Tuesday night at the Dawes barn, for the ear: trucks up the gravel one by one, the trainer's hum, headsets on between men eight feet apart — lunar descent rehearsal number 2,806 run with varsity seriousness while the crew relitigates this week's real space news like retired coaches, and a fifty-year-old relay picks tonight to act up. Ends on receding taillights, one padlock, and wind.",
  cast: [V14Cast.cricket, V14Cast.dutch, V14Cast.stitch, V14Cast.gunny],
  layer: {
    peshat: "four old friends arrive, run their weekly Moon-landing rehearsal on headsets in one barn, argue about a real mission's landing, and go home",
    sod: "varsity in a barn, heard blind: the audience must know each voice within two words, feel the fifty years in the count and the percolator, and leave certain these men consider themselves — correctly — the best who ever trained for this; the last sound is one man alone with the wind",
  },
  beats: [
    {
      who: "GUNNY",
      want: "the drill run to the standard — headsets, loop discipline, roll call",
      wall: "the men are eight feet apart and the ear can hear both worlds",
      turn: "the roll call in full ceremony — 'Apollo Eighteen. Lunar descent rehearsal. Number two thousand, eight hundred and six.' — and loop protocol enforced ('Say again.') on a man whose unfiltered voice is audible in the same room: the FILTER ITSELF is the gag, drill voice against room voice",
      subtext: "the unit's standard survives anything, including proximity",
    },
    {
      who: "STITCH",
      want: "to relitigate this week's real mission landing as a man personally insulted by it",
      wall: "Dutch, who has the figures written down and says so",
      turn: "the film review threads THROUGH the drill on both voice channels — the landing they watched came in long, 'and that fella's got a patch on his arm and a parade in Houston' — Dutch corrects the figure from his ledger (paper flip audible), the correction changes nothing, and the verdict is unanimous: not one of those boys would have cleared Dutch's physical",
      subtext: "retired varsity scouting the league that forgot them",
    },
    {
      who: "DUTCH",
      want: "the Bus B fault on the record, and vindication when it comes",
      wall: "gloating is beneath his standard",
      turn: "the fault arrives as SOUND — the hum sags, a buzz stutters under it — Cricket calls the walk; Dutch, off, not moving, one page still turning: 'Kick it. Low left corner.' — boot on sheet metal, the hum steadies clean — and his not-gloating fails by exactly one dry sentence",
      subtext: "fifty years of noticing means he doesn't need to look, and the listener can hear that he didn't",
    },
    {
      who: "CRICKET",
      want: "fly the card through all of it",
      wall: "his crew's noise, which he would not trade for silence",
      turn: "deadpan readouts punctuate the argument — then at three hundred feet the room goes quiet on its own: the argument stops mid-clause, the percolator finishes somewhere off, only breath and the hum — 'Contact light. Engine stop.' — one full held beat of nothing — and the crew appraises HIS landing with the same scouting voices they turned on the television, and it grades out clean, which nobody says warmly",
      subtext: "the silence is the show's scarcest currency, spent here first",
    },
  ],
  rules: Belt.Array.concat(
    [
      "OPEN ON THE SIGNATURE, sound only, before any voice: wind working the boards, the electrical hum of the trainer waking as breakers click in a practiced order, the percolator starting — then gravel under truck tires, one truck, then another, then a third; three engine notes, three door slams, three gaits on the plank floor; the men greet each other by name so the ear meets each voice unfiltered BEFORE the headsets go on.",
      "THE HEADSET GAG is the scene's engine and is audio-native: once headsets are on, drill traffic is (RADIO)-filtered while the SAME MEN's asides continue unfiltered in the room — two sound-worlds, eight feet apart. Gunny polices the loop; the arguments leak between channels; headsets-down at the end returns everything to room voice.",
      "REQUIRED kept beats, adapted for the ear: the roll call in full; the Bus B history with its date; the fault as sound (hum sag, stuttering buzz), 'Steady or does it stutter?', 'Kick it. Low left corner.', the boot on sheet metal, the hum steadying, one dry almost-gloat; the three-hundred-feet silence arriving on its own; 'Contact light. Engine stop.'; the held beat; the scouting verdict on Cricket's landing; 'Net closed. Same time Tuesday.' / 'God willing.'; two clicks keyed and answered around the room; the log entry SPOKEN as he writes it (self-talk law, his register): 'T plus two thousand eight hundred six… Bus B corrected… crew present.'; then departure as sound — chairs, three engines starting one by one, gravel receding, the padlock's single pull, and wind. Nobody says goodbye twice.",
      "THE FILM-REVIEW TANGENT: a real, current mission's landing from this week's news, relitigated in scouting terms — specific, technical, unimpressed. Establish once, naturally, that they all watched it (the diner TV, the news) — no screens exist in this scene; the tangent is pure talk.",
      "END: after the last truck fades, hold the barn bed alone — wind, the hum shutting down breaker by breaker, the padlock, boots to a house, a screen door, and no second voice anywhere on the property. The emptiness is the button; no line lands on it.",
      "LENGTH: eight to ten audio minutes — this is the crew's establishing scene and the show's first full use of the signature system.",
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
    | Ok() => Js.log("OK audio-03")
    | Error(m) => Js.log("BAD audio-03 — " ++ m)
    }
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED:\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
