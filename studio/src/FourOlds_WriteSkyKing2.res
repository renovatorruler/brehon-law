/* THE FOUR OLDS — the Sky King myth, second telling. During the 62-hour TLI
   coast (see sc26_tli), Cricket recalls the story from FourOlds_WriteSkyKing1
   and finally asks the question nobody asked the first time. The answer
   recontextualizes the whole story — the exact device from Katsumoto asking
   Algren about the 300 Spartans in Last Samurai, adapted for this film's own
   myth. Engine-written. */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/draft/engine_sky_king_2.scene.txt"

let seed: Seed.sceneSeed = {
  id: "four-olds-sky-king-second-telling",
  slug: "INT. CRATE D - CONTINUOUS",
  logline: "Sixty-two hours to lunar orbit insertion, nothing to do but wait. Cricket and Stitch, out of fifty years of radio habit, are knocking Morse through the crate wall even though they have a live private channel the whole time. Once that's sorted, alone on the line, Cricket finally asks the question nobody asked back in the barn: did Sky King ever get to fly again? The answer sounds like good news for a moment before its second meaning lands.",
  cast: [
    {
      name: "CRICKET",
      who: "the protagonist, sealed in a cargo crate during the coast to the Moon. Checklist-grammar, deflects feelings into practical questions — except this once, when he finally asks the thing he's been carrying since the barn.",
      register: "spare, plain. The question that matters must be asked as flatly and briefly as any checklist item — no hedging, no visible emotion in the phrasing itself.",
      earnsEloquence: false,
      lexicon: "plain, procedural, except the one bare question.",
    },
    {
      name: "STITCH",
      who: "sealed in his own crate, on the same private channel. Told the Sky King story once already, in the barn. Answers this time with something that sounds warm before it reveals what it actually means.",
      register: "dry, plain, unhurried — the answer should read as a simple, almost cheerful fact on first pass.",
      earnsEloquence: false,
      lexicon: "plain, radio-terse.",
    },
  ],
  layer: {
    peshat: "two men on a long boring radio watch; one of them finally asks a question he's been carrying",
    sod: "Cricket is really asking, without knowing he's asking it, whether the thing he is about to do can be survived and whether it is worth it either way — and the answer he gets back is the truest, most terrible, most comforting answer possible: yes, it was worth it, and no, there is no going back once you do it",
  },
  beats: [
    {
      who: "CRICKET",
      want: "stop wasting time knocking Morse through the crate wall when they have had a live mic the whole trip",
      wall: "fifty years of radio-net habit, in both of them",
      turn: "he says it plainly; Stitch owns the habit with one short, sheepish line",
      subtext: "pure texture — clears the channel for what follows, nothing more",
    },
    {
      who: "CRICKET",
      want: "finally ask what actually happened to Sky King, a question that has been sitting with him since the barn",
      wall: "nothing external — the wall is entirely his own reluctance to ask something that clearly matters to him more than an old story should",
      turn: "he asks the plain question — did he ever get to fly it again — and Stitch answers with the exact phrase that recontextualizes everything: he flew it, the rest of his life. It sounds for a moment like a happy answer before the weight of it lands",
      subtext: "Cricket is really asking about himself and the choice bearing down on him, though neither man says so",
    },
  ],
  rules: [
    "RUTHLESSLY SHORT. Eight lines of dialogue or fewer, total, across both beats. This is a recall of a myth already fully told once (in an earlier scene) — do not re-explain who Sky King was or re-tell any part of the story. If in doubt, cut, don't add.",
    "Cricket's key question must be PLAIN with NO loaded language: exactly 'Did he ever get to fly it again?' or something equally bare — nothing else in the question. Critically: the phrase 'the rest of his life' (or any equivalent) must NEVER appear in the question, only in the answer. The entire effect depends on the answer introducing a phrase the question never used.",
    "Stitch's answer is exactly this shape: 'He flew it. The rest of his life.' — or something extremely close to it. It must sound like a plain, warm, almost cheerful affirmation on first read, and only reveal a second, devastating meaning on reflection (that 'the rest of his life' was very short). Do not have either character explain, translate, or spell out the double meaning — no line may state that he died, no line may state the irony. The audience gets there on their own or not at all.",
    "Both men are grinning when the answer lands — not sad, not grim, a shared, knowing half-smile between two men who understand exactly what price is being described. Since neither man can see the other (radio only, sealed crates), Cricket hears the grin in Stitch's voice rather than seeing it, and the same grin crosses Cricket's own face a beat later, shown as a physical action, never named as an emotion.",
    "End on one small, silent, physical action from Cricket — not a line of dialogue, not a stated realization, not a described feeling. Something he does with his hands.",
    "Fountain screenplay format: (FILTERED) tag on both characters' dialogue (this project's standing radio-net convention), colon-terminated cues.",
    "Kill every AI-writing tell: em-dash overuse, rule-of-three, negative parallelism, inflated vocabulary, cute authorial conceits, ironic narrator asides, any line that states a theme or meaning aloud.",
  ],
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=5)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    Js.log("=== ENGINE WROTE: SKY KING SECOND TELLING ===\n")
    Js.log(Cinema_Backends.readText(out))
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED (gate):\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
