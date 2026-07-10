/* THE FOUR OLDS — corrective re-lift for the Sky King second-telling scene.
   The first lift pass dropped two speaker attributions and diluted the
   load-bearing line with hedge words. Re-lifting with explicit notes rather
   than hand-patching the prose.
   Run: CLAUDE_STUDIO_BUDGET=6 node src/FourOlds_LiftSkyKing2b.res.mjs */
let path = Cinema_Backends.Path(
  "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/draft/engine_sky_king_2.scene.txt",
)

let notes = "Two problems from the last pass to fix, precisely:
(1) Two lines lost their speaker attribution entirely and are now bare
action-formatted text with no CHARACTER (FILTERED): prefix — 'Can I ask you
something about Sky King.' needs 'CRICKET (FILTERED):' restored, and 'Oh,
yeah. He flew it. Rest of his life, pretty much.' needs 'STITCH (FILTERED):'
restored. Every line of dialogue must carry its speaker.
(2) The answer line was diluted with hedge words ('Oh, yeah.' prefix, 'pretty
much' suffix) that soften the exact effect the scene depends on. Restore it
to close to the bare, plain form: 'He flew it. The rest of his life.' — no
hedging, no softening qualifier. This line is the entire point of the scene
and must land clean and flat, not casual."

let main = async () => {
  try {
    let sc = await Write.liftDialogue(~path, ~notes, ~maxTries=4)
    let _ = Write.emit(sc, ~txt=path)
    Js.log("=== RE-LIFTED ===\n")
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
