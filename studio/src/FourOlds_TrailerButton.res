/* THE FOUR OLDS trailer — the button exchange as an engine-written micro-scene
   (the 1967 tall tale, director-approved in the trailer script). Written
   through the engine so the performance law holds: receipted scene ->
   performance pass -> Perf.tts.
   Run: CLAUDE_STUDIO_TURN_TIMEOUT_MS=240000 CLAUDE_STUDIO_BUDGET=5 node src/FourOlds_TrailerButton.res.mjs */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/a45_trailer_button.scene.txt"

let brandt: Seed.voiceCard = {
  name: "BRANDT",
  who: "the ESA mission commander, suit radio, asking the only question there is",
  register: "level, professional, genuinely at a loss",
  earnsEloquence: false,
  lexicon: "mission plain.",
}

let seed: Seed.sceneSeed = {
  id: "audio-45-trailer-button",
  slug: "TRAILER BUTTON. TRANQUILITY BASE - SUIT RADIO",
  logline: "Four beats on the suit loop: the commander asks where the old men came from; Stitch answers with the tall tale, dead straight; Dutch corrects the year; Stitch defends the rounding.",
  cast: [brandt, V14Cast.stitch, V14Cast.dutch],
  layer: {
    peshat: "an exchange on the suit radio at Tranquility Base",
    sod: "the tall tale is true in the only way that matters — they were left there",
  },
  beats: [
    {
      who: "BRANDT",
      want: "an explanation",
      wall: "there isn't a sane one",
      turn: "on the suit loop, level: 'Where did you come from?'",
      subtext: "a professional meeting the impossible",
    },
    {
      who: "STITCH",
      want: "to give the official history",
      wall: "Dutch is on the same loop",
      turn: "dead straight, no smile in it: 'Left us up here in sixty-seven. Somebody had to see to the sites.' — Dutch, immediate, flat: 'Seventy-two.' — Stitch, without missing a beat: 'Rounding.'",
      subtext: "the crew's historian at planetary scale; the pettiest correction in human history",
    },
  ],
  rules: Belt.Array.concat(
    [
      "FOUR LINES EXACTLY, these words verbatim — this is a locked trailer button, not a scene to expand:\nBRANDT (RADIO): Where did you come from?\nSTITCH (RADIO): Left us up here in sixty-seven. Somebody had to see to the sites.\nDUTCH (RADIO): Seventy-two.\nSTITCH (RADIO): Rounding.\nNo ACTION lines except one opening suit-radio room tone line. Nothing else.",
    ],
    AudioRules.common,
  ),
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=3)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    switch Write.verify(out) {
    | Ok() => Js.log("OK button scene")
    | Error(m) => Js.log("BAD — " ++ m)
    }
    let _ = await Perform.run(
      ~scenePath=outPath,
      ~outPath="/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/perf/a45_trailer_button.perf.json",
      ~direction="All four lines are on a suit radio loop. BRANDT level and professional. STITCH dead straight, no smile — [deliberate]. DUTCH immediate and flat — [flatly]. The last 'Rounding.' without a beat of hesitation.",
    )
    Js.log("button performed")
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED:\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
