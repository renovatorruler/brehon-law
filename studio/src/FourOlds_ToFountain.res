/* THE FOUR OLDS — convert one engine-emitted, VERIFIED scene into a Fountain
   fragment matching this project's existing draft/ convention (colon-terminated
   cues, per screenplay-tts-colon-cues). Reads via Write.read, which verifies
   first — an unlifted or tampered scene is refused, not silently converted.

   Parentheticals (wrylies), per the Sheridan law: a dialogue text may OPEN
   with a lowercase parenthetical — NAME: (to Wade) text — which is rendered
   on its own line under the cue. Consecutive dialogue entries from the SAME
   cue are merged into one speech, joined by each continuation's wryly (or a
   plain (then) if the engine omitted one) — a speech that turns mid-thought
   is one cue block, never two.

   Run: node src/FourOlds_ToFountain.res.mjs <scene.txt path> <out .fountain path> */
open Cinema_Backends

@val @scope("process") external argv: array<string> = "argv"

/* some Action lines carry an embedded "NAME (PARENTHETICAL): dialogue" or
   "NAME: dialogue" that should have been its own cue — happens when a seed
   describes an off-screen/on-screen presence (a video call, a radio) without
   being explicit enough that it still needs full dialogue treatment. Recover
   it here rather than re-spend a generation on a formatting-only fix. */
let embeddedCue = Js.Re.fromString("^([A-Z][A-Z0-9 #.']{1,30}(?:\\s*\\([A-Z. ]+\\))?): (.+)$")

/* a lowercase parenthetical opening the dialogue text = a wryly */
let wrylyRe = Js.Re.fromString("^\\(([a-z][^)]*)\\)\\s*([\\s\\S]*)$")

let splitWryly = (text: string): (option<string>, string) =>
  switch Js.Re.exec_(wrylyRe, text) {
  | Some(r) => {
      let c = Js.Re.captures(r)
      switch (c[1]->Js.Nullable.toOption, c[2]->Js.Nullable.toOption) {
      | (Some(w), Some(rest)) if Js.String2.trim(rest) != "" => (
          Some("(" ++ w ++ ")"),
          Js.String2.trim(rest),
        )
      | _ => (None, text)
      }
    }
  | None => (None, text)
  }

let render = (lns: array<Write.spoken>): array<string> => {
  let out: array<string> = []
  /* cue string + index of its block in `out`; an Action breaks the merge */
  let lastCue: ref<option<(string, int)>> = ref(None)
  lns->Belt.Array.forEach(sp =>
    switch sp {
    | Write.Dialogue({who, radio, whisper, text}) => {
        let cue = who ++ (radio ? " (RADIO)" : "") ++ (whisper ? " (WHISPER)" : "")
        let (wryly, rest) = splitWryly(text)
        switch lastCue.contents {
        | Some((c, i)) if c == cue => {
            /* continuation of the same speech: one cue block, wryly between */
            let paren = wryly->Belt.Option.getWithDefault("(then)")
            let merged = Belt.Array.getExn(out, i) ++ "\n" ++ paren ++ "\n" ++ rest
            out->Belt.Array.setExn(i, merged)
          }
        | _ => {
            let first = switch wryly {
            | Some(p) => p ++ "\n" ++ rest
            | None => rest
            }
            Js.Array2.push(out, cue ++ ":\n" ++ first)->ignore
            lastCue := Some((cue, Belt.Array.length(out) - 1))
          }
        }
      }
    | Write.Action(t) => {
        lastCue := None
        switch Js.Re.exec_(embeddedCue, t) {
        | Some(res) => {
            let caps = Js.Re.captures(res)
            switch (caps[1]->Js.Nullable.toOption, caps[2]->Js.Nullable.toOption) {
            | (Some(n), Some(d)) => {
                let (wryly, rest) = splitWryly(d)
                let body = switch wryly {
                | Some(p) => p ++ "\n" ++ rest
                | None => rest
                }
                Js.Array2.push(out, n ++ ":\n" ++ body)->ignore
              }
            | _ => Js.Array2.push(out, t)->ignore
            }
          }
        | None => Js.Array2.push(out, t)->ignore
        }
      }
    }
  )
  out
}

let main = () => {
  let inPath = Belt.Array.get(argv, 2)->Belt.Option.getWithDefault("")
  let outPath = Belt.Array.get(argv, 3)->Belt.Option.getWithDefault("")
  if inPath == "" || outPath == "" {
    Js.log("usage: node src/FourOlds_ToFountain.res.mjs <scene.txt> <out.fountain>")
  } else {
    switch Write.read(Path(inPath)) {
    | Error(m) => Js.log("REFUSED — not production-ready: " ++ m)
    | Ok(lns) => {
        let body = render(lns)->Belt.Array.joinWith("\n\n", x => x)
        writeText(Path(outPath), body ++ "\n")
        Js.log("wrote " ++ outPath ++ " (" ++ Belt.Int.toString(Belt.Array.length(lns)) ++ " lines)")
      }
    }
  }
}
main()
