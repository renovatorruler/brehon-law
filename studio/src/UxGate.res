/* UX GATE - the story-engine gate for product screens (UX_DOCTRINE.md).
   BLOCKS a mockup when: a data-flow marker has no typed scene card (UxCards),
   the Sod is stated in copy, cheer-copy appears, or a briefing-card header
   sneaks back in. Warns on cards with no marker (dead cards) and on thin card
   fields. Run: node src/UxGate.res.mjs <mockup.html> */
@module("fs") external readFileSync: (string, string) => string = "readFileSync"
@val @scope("process") external argv: array<string> = "argv"
@val @scope("process") external exit: int => unit = "exit"

let failed = ref(false)
let fail = msg => {
  failed := true
  Js.log("  FAIL  " ++ msg)
}
let warn = msg => Js.log("  warn  " ++ msg)
let ok = msg => Js.log("  ok    " ++ msg)

/* collect capture-group-1 for a global regex */
let collect = (re, s) => {
  let acc = ref([])
  let go = ref(true)
  while go.contents {
    switch Js.Re.exec_(re, s) {
    | Some(r) =>
      switch Js.Re.captures(r)->Belt.Array.get(1)->Belt.Option.flatMap(Js.Nullable.toOption) {
      | Some(v) => acc := Belt.Array.concat(acc.contents, [v])
      | None => ()
      }
    | None => go := false
    }
  }
  acc.contents
}
let uniq = a => Belt.Set.String.fromArray(a)->Belt.Set.String.toArray

/* THE SOD IS NEVER STATED (this app: "you are never alone with money again"). */
let sodBans = ["never alone", "you are not alone", "you're not alone", "we're with you", "always here for you", "we've got you"]
/* cheer-copy = the em-dash of UX */
let cheerBans = ["oops", "congratulations", "awesome!", "amazing!", "hooray", "yay!", "let's go!", "you did it"]
/* exposition smell: briefing-card headers */
let briefBans = ["how it protects you", "how it works", "why this is safe", "learn more", "(your wife", "(your son", "your wife)", "your son)"]

let main = () => {
  switch Belt.Array.get(argv, 2) {
  | None => {
      Js.log("usage: node src/UxGate.res.mjs <mockup.html>")
      exit(2)
    }
  | Some(path) => {
      let html = readFileSync(path, "utf8")
      let lower = Js.String2.toLowerCase(html)
      Js.log("UX GATE on " ++ path)

      /* 1 - coverage: every marked flow has a scene card */
      let markers = uniq(collect(%re("/data-flow=\"([a-z0-9-]+)\"/g"), html))
      let cardFlows = UxCards.cards->Belt.Array.map(c => c.flow)
      Js.log("- coverage: " ++ Belt.Int.toString(Belt.Array.length(markers)) ++ " marked flows, " ++ Belt.Int.toString(Belt.Array.length(cardFlows)) ++ " cards")
      markers->Belt.Array.forEach(m =>
        if Belt.Array.some(cardFlows, c => c == m) {
          ok("flow '" ++ m ++ "' has a scene card")
        } else {
          fail("flow '" ++ m ++ "' HAS NO SCENE CARD - write UxCards entry (want/wall/turn/cost/clock/sod/exposition/held)")
        }
      )
      cardFlows->Belt.Array.forEach(c =>
        if !Belt.Array.some(markers, m => m == c) {
          warn("card '" ++ c ++ "' has no data-flow marker in the mockup (dead card?)")
        }
      )

      /* 2 - the Sod stays under the surface */
      Js.log("- sod check (never stated)")
      sodBans->Belt.Array.forEach(b =>
        if Js.String2.includes(lower, b) {
          fail("SOD STATED: found \"" ++ b ++ "\" - the Sod must be implied, never written")
        }
      )

      /* 3 - copy register */
      Js.log("- copy lints")
      cheerBans->Belt.Array.forEach(b =>
        if Js.String2.includes(lower, b) {
          fail("cheer-copy: found \"" ++ b ++ "\" - plain register only")
        }
      )
      briefBans->Belt.Array.forEach(b =>
        if Js.String2.includes(lower, b) {
          fail("briefing card: found \"" ++ b ++ "\" - exposition is the enemy; teach at the moment of consequence")
        }
      )

      /* 4 - card depth: a one-liner is not a thought */
      Js.log("- card depth")
      UxCards.cards->Belt.Array.forEach(c => {
        let thin = f => Js.String2.length(f) < 20
        if thin(c.want) || thin(c.wall) || thin(c.turn) || thin(c.cost) || thin(c.clock) || thin(c.sodCheck) || thin(c.exposition) || thin(c.heldCard) {
          warn("card '" ++ c.flow ++ "' has a thin field (<20 chars) - is it actually thought through?")
        }
      })

      if failed.contents {
        Js.log("UX GATE: FAIL")
        exit(1)
      } else {
        Js.log("UX GATE: PASS (" ++ Belt.Int.toString(Belt.Array.length(markers)) ++ " flows carded, sod held, copy clean)")
      }
    }
  }
}
main()
