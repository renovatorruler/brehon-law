/* ============================================================================
   Fountain — parse .fountain source into typed elements, render to a styled
   HTML document, and hand that to Pdf.fromHtml. Story-agnostic: this module
   knows the Fountain dialect this project writes in, not any one screenplay.

   Element kinds are a closed variant (not a string tag) so a renderer must
   handle every case; the compiler catches a forgotten kind.
   ============================================================================ */

type element =
  | TitlePage(array<(string, string)>)
  | Slugline(string)
  | Action(string)
  | Cue(string)
  | Parenthetical(string)
  | Dialogue(string)
  | Transition(string)
  | Centered(string)
  | PageBreak

/* ---- regexes -------------------------------------------------------------- */
let titleKeyRe = Js.Re.fromString("^(Title|Credit|Author|Source|Draft date|Contact|Notes):\\s*(.*)$")
let slugRe = Js.Re.fromStringWithFlags("^(INT\\.|EXT\\.|EST\\.|INT/EXT\\.|I/E\\.)", ~flags="i")
let transRe = Js.Re.fromString(
  "^(CUT TO|SMASH CUT TO|MATCH CUT TO|FADE (IN|OUT|TO)|DISSOLVE TO|WHITE OUT|BLACK)[ A-Z]*:?$",
)
let centeredRe = Js.Re.fromString("^>\\s*(.*?)\\s*<$")
let pageBreakRe = Js.Re.fromString("^===+$")
let cueRe = Js.Re.fromString("^([A-Z][A-Z0-9 #.'-]{0,30}?)(\\s*\\((?:[A-Z.' ]+)\\))?:$")
let parenRe = Js.Re.fromString("^\\(.*\\)$")

let test = (re, s) => Js.Re.test_(re, s)
let trim = Js.String2.trim

/* ---- parse ------------------------------------------------------------------ */
let parse = (raw: string): array<element> => {
  let lines = Js.String2.split(raw, "\n")
  let n = Belt.Array.length(lines)
  let out = []
  let i = ref(0)

  /* title page: consecutive Key: value lines (+ indented continuations) at the top */
  let title = []
  let keepGoing = ref(true)
  while keepGoing.contents && i.contents < n {
    let line = lines[i.contents]
    switch Js.Re.exec_(titleKeyRe, trim(line)) {
    | Some(m) =>
      let caps = Js.Re.captures(m)
      let key = caps[1]->Js.Nullable.toOption->Belt.Option.getWithDefault("")
      let value = caps[2]->Js.Nullable.toOption->Belt.Option.getWithDefault("")
      Js.Array2.push(title, (key, value))->ignore
      i := i.contents + 1
    | None =>
      if trim(line) == "" && Belt.Array.length(title) > 0 {
        i := i.contents + 1
        keepGoing := false
      } else {
        keepGoing := false
      }
    }
  }
  if Belt.Array.length(title) > 0 {
    Js.Array2.push(out, TitlePage(title))->ignore
  }

  let inDialogue = ref(false)
  let buf = []
  let bufKind = ref(#none)

  let flush = () => {
    if Belt.Array.length(buf) > 0 {
      let text = Js.Array2.joinWith(buf, " ")
      switch bufKind.contents {
      | #action => Js.Array2.push(out, Action(text))->ignore
      | #dialogue => Js.Array2.push(out, Dialogue(text))->ignore
      | #none => ()
      }
      Js.Array2.removeCountInPlace(buf, ~pos=0, ~count=Belt.Array.length(buf))->ignore
    }
  }

  while i.contents < n {
    let raw = lines[i.contents]
    let s = trim(raw)
    if s == "" {
      flush()
      inDialogue := false
    } else if test(pageBreakRe, s) {
      flush()
      Js.Array2.push(out, PageBreak)->ignore
      inDialogue := false
    } else if test(centeredRe, s) {
      flush()
      let m = Js.Re.exec_(centeredRe, s)
      let text =
        m
        ->Belt.Option.map(Js.Re.captures)
        ->Belt.Option.flatMap(c => c[1]->Js.Nullable.toOption)
        ->Belt.Option.getWithDefault(s)
      Js.Array2.push(out, Centered(text))->ignore
      inDialogue := false
    } else if test(slugRe, s) {
      flush()
      Js.Array2.push(out, Slugline(s))->ignore
      inDialogue := false
    } else if test(transRe, s) {
      flush()
      Js.Array2.push(out, Transition(s))->ignore
      inDialogue := false
    } else if test(cueRe, s) {
      flush()
      let name = Js.String2.slice(s, ~from=0, ~to_=Js.String2.length(s) - 1)
      Js.Array2.push(out, Cue(name))->ignore
      inDialogue := true
    } else if inDialogue.contents && test(parenRe, s) {
      flush()
      Js.Array2.push(out, Parenthetical(s))->ignore
    } else {
      let kind = inDialogue.contents ? #dialogue : #action
      if Belt.Array.length(buf) > 0 && bufKind.contents != kind {
        flush()
      }
      bufKind := kind
      Js.Array2.push(buf, s)->ignore
    }
    i := i.contents + 1
  }
  flush()
  out
}

/* ---- render to HTML -------------------------------------------------------- */
let esc = s =>
  s
  ->Js.String2.replaceByRe(Js.Re.fromStringWithFlags("&", ~flags="g"), "&amp;")
  ->Js.String2.replaceByRe(Js.Re.fromStringWithFlags("<", ~flags="g"), "&lt;")
  ->Js.String2.replaceByRe(Js.Re.fromStringWithFlags(">", ~flags="g"), "&gt;")

let css = `
@page { size: 8.5in 11in; margin: 1in 1in 1in 1.5in; }
body { font-family: "Courier New", Courier, monospace; font-size: 12pt; line-height: 1.0; color: #000; }
.titlepage { height: 9in; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; page-break-after: always; }
.titlepage .title { font-size: 14pt; font-weight: bold; text-transform: uppercase; margin-bottom: 0.3in; }
.titlepage .field { margin: 0.05in 0; }
.slug { font-weight: bold; text-transform: uppercase; margin: 1.6em 0 1em 0; }
.action { margin: 0 0 1em 0; white-space: normal; }
.cue { margin: 1em 0 0 3.0in; }
.paren { margin: 0 0 0 2.5in; max-width: 2in; }
.dialogue { margin: 0 0 1em 2.0in; max-width: 3.3in; }
.trans { text-align: right; text-transform: uppercase; margin: 1em 0 1em 0; }
.centered { text-align: center; margin: 1em 0; }
.pagebreak { page-break-after: always; }
`

let renderEl = el =>
  switch el {
  | TitlePage(fields) => {
      let get = k =>
        fields->Belt.Array.getBy(((key, _)) => key == k)->Belt.Option.map(((_, v)) => v)->Belt.Option.getWithDefault("")
      let title = get("Title")
      let rest =
        fields
        ->Belt.Array.keep(((k, _)) => k != "Title")
        ->Belt.Array.map(((k, v)) => `<div class="field">${esc(k)}: ${esc(v)}</div>`)
        ->Js.Array2.joinWith("")
      `<div class="titlepage"><div class="title">${esc(title)}</div>${rest}</div>`
    }
  | Slugline(t) => `<div class="slug">${esc(t)}</div>`
  | Action(t) => `<div class="action">${esc(t)}</div>`
  | Cue(t) => `<div class="cue">${esc(t)}:</div>`
  | Parenthetical(t) => `<div class="paren">${esc(t)}</div>`
  | Dialogue(t) => `<div class="dialogue">${esc(t)}</div>`
  | Transition(t) => `<div class="trans">${esc(t)}</div>`
  | Centered(t) => `<div class="centered">${esc(t)}</div>`
  | PageBreak => `<div class="pagebreak"></div>`
  }

let toHtml = (elements: array<element>): string => {
  let body = elements->Belt.Array.map(renderEl)->Js.Array2.joinWith("\n")
  `<!doctype html><html><head><meta charset="utf-8"><style>${css}</style></head><body>${body}</body></html>`
}

/* ---- the door: read a .fountain file, render, write a PDF ------------------ */
let toPdf = async (~srcPath: string, ~outPath: string) => {
  let raw = Cinema_Backends.readText(Cinema_Backends.Path(srcPath))
  let elements = parse(raw)
  let html = toHtml(elements)
  await Pdf.fromHtml(~html, ~outPath)
}
