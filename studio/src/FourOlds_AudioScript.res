/* THE FOUR OLDS audio play — render a verified audio scene as a radio-drama
   SCRIPT (the paper deliverable): numbered cues, ATMOS/FX/MUSIC lines in
   caps, voices with their placement (over the studio feed / on the arena
   PA), performance directions kept lowercase before the dialogue, and the
   house pause grammar documented in the tech note. Content comes from
   Write.read — an unverified or tampered scene is refused, never typeset.
   Run: node src/FourOlds_AudioScript.res.mjs <scene.txt> <out.pdf> [PART LABEL] */

@val @scope("process") external argv: array<string> = "argv"
@module("fs") external readFileSync: (string, string) => string = "readFileSync"

/* same classifiers as the audio renderer — the script must describe the
   exact production the mix performs */
let bedRe = %re(
  "/(hum|wind |room tone|walla|murmur|applause climbs|stand quiet|rain|griddle hisses|stove ticks|fan hums|fluorescent)/i"
)
let musicRe = %re("/(theme sting|theme music|music sting|score swells)/i")
let embeddedRe = %re("/^([A-Z][A-Z .'#-]+?)\s*\((PA|RADIO|TV|ON TV)\):\s*(.+)$/")
let wrylyRe = %re("/^\(([a-z][^)]*)\)\s*([\s\S]*)$/")
/* a leading wryly that names WHERE the voice sits (a source), not how the
   line is said */
let placementRe = %re("/^(over |on |into |through |from )/")

let esc = (s: string): string =>
  s
  ->Js.String2.replaceByRe(%re("/&/g"), "&amp;")
  ->Js.String2.replaceByRe(%re("/</g"), "&lt;")
  ->Js.String2.replaceByRe(%re("/>/g"), "&gt;")

type cue =
  | Atmos(string)
  | Fx(string)
  | Music(string)
  | Voice({who: string, placement: option<string>, direction: option<string>, text: string})

let classify = (lns: array<Write.spoken>): array<cue> => {
  let cues = []
  let bedCount = ref(0)
  let actionIdx = ref(0)
  /* placement is sticky per speaker: once a voice is placed (over the
     studio feed), it stays there until a wryly moves it */
  let lastPlacement: Js.Dict.t<string> = Js.Dict.empty()
  lns->Belt.Array.forEach(l =>
    switch l {
    | Write.Dialogue({who, radio, whisper, text}) => {
        /* split a leading wryly into placement vs performance direction */
        let (placement, direction, spoken) = switch Js.Re.exec_(wrylyRe, text) {
        | Some(m) => {
            let g = Js.Re.captures(m)
            let w =
              Js.Nullable.toOption(Belt.Array.getExn(g, 1))->Belt.Option.getWithDefault("")
            let rest =
              Js.Nullable.toOption(Belt.Array.getExn(g, 2))->Belt.Option.getWithDefault("")
            if Js.Re.test_(placementRe, w) {
              (Some(Js.String2.toUpperCase(w)), None, rest)
            } else {
              (None, Some(w), rest)
            }
          }
        | None => (None, None, text)
        }
        let placement = switch placement {
        | Some(p) => {
            Js.Dict.set(lastPlacement, who, p)
            Some(p)
          }
        | None =>
          radio
            ? Some(Js.Dict.get(lastPlacement, who)->Belt.Option.getWithDefault("ON RADIO"))
            : None
        }
        let direction = whisper
          ? Some(
              switch direction {
              | Some(d) => "whispered; " ++ d
              | None => "whispered"
              },
            )
          : direction
        Js.Array2.push(cues, Voice({who, placement, direction, text: spoken}))->ignore
      }
    | Write.Action(t) =>
      switch Js.Re.exec_(embeddedRe, t) {
      | Some(m) => {
          let g = Js.Re.captures(m)
          let who =
            Js.Nullable.toOption(Belt.Array.getExn(g, 1))
            ->Belt.Option.getWithDefault("")
            ->Js.String2.trim
          let src =
            Js.Nullable.toOption(Belt.Array.getExn(g, 2))->Belt.Option.getWithDefault("PA")
          let text =
            Js.Nullable.toOption(Belt.Array.getExn(g, 3))->Belt.Option.getWithDefault("")
          Js.Array2.push(
            cues,
            Voice({who, placement: Some("OVER THE " ++ src), direction: None, text}),
          )->ignore
        }
      | None => {
          let isBed =
            bedCount.contents < 2 && actionIdx.contents < 3 && Js.Re.test_(bedRe, t)
          actionIdx := actionIdx.contents + 1
          if isBed {
            bedCount := bedCount.contents + 1
            Js.Array2.push(cues, Atmos(t))->ignore
          } else if Js.Re.test_(musicRe, t) {
            Js.Array2.push(cues, Music(t))->ignore
          } else {
            Js.Array2.push(cues, Fx(t))->ignore
          }
        }
      }
    }
  )
  cues
}

let render = (~slug: string, ~part: string, ~cues: array<cue>): string => {
  let rows =
    cues
    ->Belt.Array.mapWithIndex((i, c) => {
      let n = Belt.Int.toString(i + 1)
      switch c {
      | Atmos(t) =>
        `<div class="cue"><div class="n">${n}</div><div class="tag">ATMOS:</div><div class="body sfx">${esc(
            Js.String2.toUpperCase(t),
          )} <span class="dir">— ESTABLISH, THEN UNDER.</span></div></div>`
      | Fx(t) =>
        `<div class="cue"><div class="n">${n}</div><div class="tag">FX:</div><div class="body sfx">${esc(
            Js.String2.toUpperCase(t),
          )}</div></div>`
      | Music(t) =>
        `<div class="cue"><div class="n">${n}</div><div class="tag">MUSIC:</div><div class="body sfx">${esc(
            Js.String2.toUpperCase(t),
          )}</div></div>`
      | Voice({who, placement, direction, text}) => {
          /* placement leads the dialogue block in caps — the name column
             stays narrow and never wraps into the body */
          let place = switch placement {
          | Some(p) => `<span class="place">(${esc(p)})</span> `
          | None => ""
          }
          let dir = switch direction {
          | Some(d) => `<span class="perf">(${esc(d)})</span> `
          | None => ""
          }
          `<div class="cue"><div class="n">${n}</div><div class="tag who">${esc(
              who,
            )}:</div><div class="body">${place}${dir}${esc(text)}</div></div>`
        }
      }
    })
    ->Belt.Array.joinWith("\n", x => x)
  `<!doctype html><html><head><meta charset="utf-8"><style>
@page { size: 8.5in 11in; margin: 1in 1in 1in 1in; }
body { font-family: "Courier New", Courier, monospace; font-size: 12pt; line-height: 1.25; color: #111; }
.masthead { text-align: center; margin-bottom: 1.2em; }
.masthead .t { font-weight: bold; letter-spacing: .25em; }
.masthead .sub { margin-top: .3em; }
.slug { font-weight: bold; margin: 1.4em 0 .4em 0; text-decoration: underline; }
.tech { font-size: 10pt; margin: 0 0 1.6em 0; border: 1px solid #999; padding: .6em .8em; }
.cue { display: flex; margin: 0 0 .85em 0; page-break-inside: avoid; }
.n { width: 2.2em; flex: none; text-align: right; padding-right: 1em; color: #666; }
.tag { width: 9.5em; flex: none; font-weight: bold; }
.tag.who { font-weight: bold; }
.place { font-weight: normal; }
.body { flex: 1; }
.body.sfx { }
.dir { }
.perf { }
</style></head><body>
<div class="masthead"><div class="t">THE FOUR OLDS</div><div class="sub">a full-cast audio drama — ${esc(
    part,
  )}</div></div>
<div class="slug">${esc(slug)}</div>
<div class="tech">PAUSE GRAMMAR (house): dialogue answers dialogue on a short breath (0.15s);
any cue touching an FX or ATMOS boundary takes air (0.5s); scene joins sit in
1.5s of silence. ATMOS beds ride under the whole scene at −15/−17 dB. A cue
whose words name silence is played as written — hold the dead air.</div>
${rows}
</body></html>`
}

let main = async () => {
  let src = Belt.Array.get(argv, 2)->Belt.Option.getWithDefault("")
  let out = Belt.Array.get(argv, 3)->Belt.Option.getWithDefault("")
  let part = Belt.Array.get(argv, 4)->Belt.Option.getWithDefault("PART ONE")
  if src == "" || out == "" {
    Js.log("usage: node src/FourOlds_AudioScript.res.mjs <scene.txt> <out.pdf> [PART LABEL]")
  } else {
    switch Write.read(Cinema_Backends.Path(src)) {
    | Error(m) => Js.log("REFUSED — " ++ m)
    | Ok(lns) => {
        /* slug from the scene header line */
        let hdr =
          readFileSync(src, "utf8")->Js.String2.split("\n")->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let slug = switch Js.String2.split(hdr, " — ")->Belt.Array.get(1) {
        | Some(s) => s
        | None => "SCENE"
        }
        let cues = classify(lns)
        let html = render(~slug, ~part, ~cues)
        await Pdf.fromHtml(~html, ~outPath=out)
        Js.log(
          "wrote " ++ out ++ " (" ++ Belt.Int.toString(Belt.Array.length(cues)) ++ " cues)",
        )
      }
    }
  }
}
main()->ignore
