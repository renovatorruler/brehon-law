/* THE FOUR OLDS trailer — dialogue pulls. Each trailer line is extracted from
   its scene's gate-passed performance (Perf.load) and rendered via Perf.tts —
   the performance law holds; no raw text touches the API. Cached per pull.
   Run: node src/FourOlds_TrailerPulls.res.mjs */

@module("fs") external mkdirSync: (string, 'a) => unit = "mkdirSync"
@module("child_process") external execSync: (string, 'a) => 'b = "execSync"
@module("fs") external existsSync: string => bool = "existsSync"

let audio = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/"
let pulls = audio ++ "trailer_pulls/"



let sh = (cmd: string): unit => {
  let opts = Js.Dict.empty()
  Js.Dict.set(opts, "stdio", Obj.magic("pipe"))
  let _ = execSync(cmd, opts)
}

/* (sceneBase, substring-of-line, outName, radioFutz) */
let wanted = [
  ("a01_cold_open", "to every nation we have wronged", "marwani_sorry", true),
  ("a01_cold_open", "prohibited nationwide", "radio_ban", true),
  ("a01_cold_open", "Huh", "buck_huh", false),
  ("a03_barn_net", "eight hundred and six", "gunny_rollcall", false),
  ("a03_barn_net", "the box already had finished", "stitch_case", false),
  ("a03_barn_net", "Three hundred and eighty", "dutch_380", false),
  ("a04_accord", "boiled white", "anchor_accord", true),
  ("a06_seizure", "You'll have to move me", "cricket_moveme", false),
  ("a13_shop", "generous for cloth", "dutch_generous", false),
  ("a13_shop", "about fit in there", "tito_fit", false),
  ("a20_decision", "time me getting in", "cricket_timeme", false),
  ("a30_loadout", "clear", "dockworker_allclear", false),
  ("a38_standoff", "only Americans on the Moon", "lawyer_only", false),
  ("a40_hale", "Fuck", "hale_gfy", false),
  ("a41_vess_pell", "Count the signatures", "vess_count", false),
  ("a39_wall", "Come through us", "gunny_wall", true),
  ("a45_trailer_button", "Where did you come from", "brandt_where", true),
  ("a45_trailer_button", "sixty-seven", "stitch_67", true),
  ("a45_trailer_button", "Seventy-two", "dutch_72", true),
  ("a45_trailer_button", "Rounding", "stitch_rounding", true),
]

let main = async () => {
  mkdirSync(pulls, {"recursive": true})
  let n = Belt.Array.length(wanted)
  let ok = ref(0)
  let rec go = async i =>
    if i < n {
      let (base, sub, name, futz) = Belt.Array.getExn(wanted, i)
      let scenePath = audio ++ base ++ ".scene.txt"
      let perfPath = audio ++ "perf/" ++ base ++ ".perf.json"
      switch Perf.load(~perfPath, ~scenePath) {
      | Error(m) => Js.log("REFUSED " ++ name ++ " — " ++ Js.String2.slice(m, ~from=0, ~to_=80))
      | Ok(lines) =>
        switch lines->Belt.Array.getBy(pd => {
          ignore(pd)
          false
        }) {
        | _ => {
            /* find by substring via the sidecar trick: try tts on each line
               whose role+text matches — Perf hides text, so match by trying
               indices... instead Perf exposes roleOf/indexOf only; we match
               via the scene file itself */
            let raw = Cinema_Backends.readText(Cinema_Backends.Path(scenePath))
            let sceneLines = Js.String2.split(raw, "\n")
            /* find the dialogue line containing the substring, count its
               dialogue-line INDEX among parsed lines */
            switch Write.read(Cinema_Backends.Path(scenePath)) {
            | Error(_) => Js.log("read fail " ++ name)
            | Ok(parsed) => {
                ignore(sceneLines)
                let found = ref(None)
                parsed->Belt.Array.forEachWithIndex((idx, l) =>
                  switch l {
                  | Write.Dialogue({text}) =>
                    if found.contents == None && Js.String2.includes(text, sub) {
                      found := Some(idx)
                    }
                  | Write.Action(t) =>
                    if (
                      found.contents == None &&
                      Js.String2.includes(t, sub) &&
                      Perform.embeddedOf(t) != None
                    ) {
                      found := Some(idx)
                    }
                  }
                )
                switch found.contents {
                | None => Js.log("NOT FOUND " ++ name ++ " ('" ++ sub ++ "' in " ++ base ++ ")")
                | Some(idx) =>
                  switch lines->Belt.Array.getBy(pd => Perf.indexOf(pd) == idx) {
                  | None => Js.log("NO PERF LINE " ++ name)
                  | Some(pd) =>
                    switch FourOlds_TrailerCast.voice(Perf.roleOf(pd)) {
                    | None => Js.log("UNCAST " ++ Perf.roleOf(pd) ++ " for " ++ name)
                    | Some(v) => {
                        let mp3 = pulls ++ name ++ ".mp3"
                        let done_ = await Perf.tts(pd, ~voiceId=v, ~outMp3=mp3)
                        if done_ {
                          let wav = pulls ++ name ++ ".wav"
                          let filter = futz
                            ? " -af \"highpass=f=360,lowpass=f=3400,acompressor=threshold=-18dB:ratio=4,volume=1.1\""
                            : ""
                          sh(
                            "/opt/homebrew/bin/ffmpeg -y -loglevel error -i " ++
                            mp3 ++ filter ++ " -ar 44100 -ac 2 " ++ wav,
                          )
                          ok := ok.contents + 1
                          Js.log("OK   " ++ name)
                        } else {
                          Js.log("TTS FAIL " ++ name)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      await go(i + 1)
    }
  await go(0)
  Js.log("PULLS DONE — " ++ Belt.Int.toString(ok.contents) ++ "/" ++ Belt.Int.toString(n))
}
main()->ignore
