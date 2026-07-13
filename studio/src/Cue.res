/* Shared cue parser for the DME audio mix (see AUDIO_MIX.md). Walks a verified
   audio scene and classifies each line into a mix cue with its bus, space, and
   (for dialogue) perspective. Both the renderer (to resolve/level each sound)
   and the mixer (to route/duck/reverb) read this. */

type persp = Close | Off | Radio | Pa | Tv | Neutral

type cue =
  | Dlg({idx: int, who: string, persp: persp, text: string, space: string})
  | Bed({idx: int, space: string, desc: string})
  | Spot({idx: int, space: string, desc: string})
  | Transition({idx: int, space: string, desc: string})
  | Music({idx: int, desc: string})

/* "ATMOS studio | low bustle" -> ("studio", "low bustle") */
let splitTag = (rest: string): (string, string) => {
  let bar = Js.String2.indexOf(rest, "|")
  if bar >= 0 {
    (
      Js.String2.trim(Js.String2.slice(rest, ~from=0, ~to_=bar)),
      Js.String2.trim(Js.String2.sliceToEnd(rest, ~from=bar + 1)),
    )
  } else {
    ("", Js.String2.trim(rest))
  }
}

/* a leading wryly on a dialogue line carries the perspective */
let perspRe = %re("/^\(([a-z ]+)\)\s*([\s\S]*)$/")
let perspOf = (radio: bool, text: string): (persp, string) =>
  switch Js.Re.exec_(perspRe, text) {
  | Some(m) => {
      let w =
        Js.Nullable.toOption(Belt.Array.getExn(Js.Re.captures(m), 1))->Belt.Option.getWithDefault("")
      let rest =
        Js.Nullable.toOption(Belt.Array.getExn(Js.Re.captures(m), 2))->Belt.Option.getWithDefault(
          text,
        )
      let lw = Js.String2.toLowerCase(w)
      if Js.String2.includes(lw, "close") {
        (Close, rest)
      } else if Js.String2.includes(lw, "off") {
        (Off, rest)
      } else if Js.String2.includes(lw, "radio") {
        (Radio, rest)
      } else if Js.String2.includes(lw, "pa") || Js.String2.includes(lw, "speaker") {
        (Pa, rest)
      } else if Js.String2.includes(lw, "tv") || Js.String2.includes(lw, "television") {
        (Tv, rest)
      } else {
        (radio ? Radio : Neutral, text) /* keep the wryly if it isn't a perspective */
      }
    }
  | None => (radio ? Radio : Neutral, text)
  }

let parse = (lns: array<Write.spoken>): array<cue> => {
  let cues = []
  let space = ref("studio")
  lns->Belt.Array.forEachWithIndex((i, l) =>
    switch l {
    | Write.Dialogue({who, radio, text}) => {
        let (p, _) = perspOf(radio, text)
        Js.Array2.push(cues, Dlg({idx: i, who, persp: p, text, space: space.contents}))->ignore
      }
    | Write.Action(t) =>
      if Js.String2.startsWith(t, "ATMOS ") {
        let (sp, desc) = splitTag(Js.String2.sliceToEnd(t, ~from=6))
        if sp != "" {
          space := sp
        }
        Js.Array2.push(cues, Bed({idx: i, space: space.contents, desc}))->ignore
      } else if Js.String2.startsWith(t, "CUT ") {
        let (sp, desc) = splitTag(Js.String2.sliceToEnd(t, ~from=4))
        Js.Array2.push(cues, Transition({idx: i, space: space.contents, desc}))->ignore
        if sp != "" {
          space := sp /* the new space takes effect after the cut */
        }
      } else if Js.String2.startsWith(t, "FX ") {
        let (_, desc) = splitTag(Js.String2.sliceToEnd(t, ~from=3))
        Js.Array2.push(cues, Spot({idx: i, space: space.contents, desc}))->ignore
      } else if Js.String2.startsWith(t, "MUSIC ") {
        let (_, desc) = splitTag(Js.String2.sliceToEnd(t, ~from=6))
        Js.Array2.push(cues, Music({idx: i, desc}))->ignore
      } else {
        /* a plain ACTION line is a spot effect in the current space */
        Js.Array2.push(cues, Spot({idx: i, space: space.contents, desc: t}))->ignore
      }
    }
  )
  cues
}

/* the sound description the renderer should resolve for a cue */
let descOf = c =>
  switch c {
  | Bed({desc}) | Spot({desc}) | Transition({desc}) | Music({desc}) => desc
  | Dlg({text}) => text
  }

let idxOf = c =>
  switch c {
  | Bed({idx}) | Spot({idx}) | Transition({idx}) | Music({idx}) | Dlg({idx}) => idx
  }
