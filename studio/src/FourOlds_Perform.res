/* Thin runner over Perform.run — one scene, one performance JSON.
   Run: CLAUDE_STUDIO_BUDGET=5 node src/FourOlds_Perform.res.mjs <scene.txt> <out.perf.json> */

@val @scope("process") external argv: array<string> = "argv"

let main = async () => {
  let src = Belt.Array.get(argv, 2)->Belt.Option.getWithDefault("")
  let out = Belt.Array.get(argv, 3)->Belt.Option.getWithDefault("")
  if src == "" || out == "" {
    Js.log("usage: node src/FourOlds_Perform.res.mjs <scene.txt> <out.perf.json>")
  } else {
    switch await Perform.run(~scenePath=src, ~outPath=out) {
    | Ok(n) => Js.log("PERFORMANCE " ++ out ++ " — " ++ Belt.Int.toString(n) ++ " lines, 0 gate rejects")
    | Error(m) => Js.log("PERFORMANCE " ++ out ++ " — " ++ m)
    }
  }
  Session.close()
}
main()->ignore
