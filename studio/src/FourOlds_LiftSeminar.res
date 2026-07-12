/* THE FOUR OLDS v14 — dialogue-lift pass on the seminar scene.
   Run: CLAUDE_STUDIO_BUDGET=8 node src/FourOlds_LiftSeminar.res.mjs */
let path = Cinema_Backends.Path(
  "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/draft/engine_seminar_v14.scene.txt",
)

let notes = "PROTECT the four example speeches — their content and warmth are the scene's payload and are approved; only tighten fumbles that read as written-in filler rather than real speech. The Facilitator's mid-sentence self-corrections ('And it's lovely, I'm not, it's lovely') are GOOD — keep that texture. Do not add any reaction that connects the examples to any person. Do not let any line acquire rule-of-three rhythm. Keep JOSS's line and MACK's coffee line verbatim. BAY TWO MAN stays halting and plain."

let main = async () => {
  try {
    let sc = await Write.liftDialogue(~path, ~notes, ~maxTries=4)
    let _ = Write.emit(sc, ~txt=path)
    Js.log("=== LIFTED ===\n")
    Js.log(Cinema_Backends.readText(path))
    Js.log("\n=== VERIFY ===")
    switch Write.verify(path) {
    | Ok() => Js.log("VERIFY OK (production-ready)")
    | Error(m) => Js.log("VERIFY FAILED - " ++ m)
    }
  } catch {
  | Write.WriteError(m) => Js.log("LIFT FAILED: " ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
