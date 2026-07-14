/* THE FOUR OLDS — trailer audio v1 (2:28). Explicit hand-placed timeline:
   five music movements, 20 performed dialogue pulls, sound design seams.
   One ffmpeg graph -> -16 LUFS master.
   Run: node src/FourOlds_TrailerAudio.res.mjs */

@module("child_process") external execSync: (string, 'a) => 'b = "execSync"
@module("fs") external existsSync: string => bool = "existsSync"

let audio = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/"
let pulls = audio ++ "trailer_pulls/"
let music = audio ++ "trailer_music/"
let squelch = "/Users/dusty/SFX/PSE/COMRadio_Noise Radio Static and Squelch_PSE_GEN_YTdGp.wav"
let sodium = audio ++ "render_a13/000.wav"
let out = audio ++ "releases/FOUR-OLDS_TRAILER-AUDIO_v1.mp3"

let sh = (cmd: string): unit => {
  let opts = Js.Dict.empty()
  Js.Dict.set(opts, "stdio", Obj.magic("pipe"))
  let _ = execSync(cmd, opts)
}

/* (start, path, vol, trimStart, trimLen, fadeIn, fadeOut) — 0.0 trim/fade = none */
let entries = [
  /* ---- music movements ---- */
  (0.0, music ++ "bed_americana.mp3", 0.55, 0.0, 34.0, 1.5, 2.0),
  (33.0, music ++ "bed_march.mp3", 0.5, 0.0, 30.5, 1.0, 2.0),
  (63.5, music ++ "needle_stomp.mp3", 0.75, 0.0, 12.0, 0.0, 0.3),
  (79.0, music ++ "needle_stomp.mp3", 0.75, 12.0, 24.0, 0.2, 3.0),
  (101.0, music ++ "tension_note.mp3", 0.6, 0.0, 27.0, 1.5, 2.0),
  (132.5, music ++ "title_hit.mp3", 0.9, 0.0, 11.0, 0.0, 0.0),
  /* ---- sound design ---- */
  (1.8, squelch, 0.45, 0.0, 1.2, 0.0, 0.3),
  (34.2, squelch, 0.45, 0.0, 1.2, 0.0, 0.3),
  (62.8, squelch, 0.5, 0.0, 1.0, 0.0, 0.2),
  (100.3, squelch, 0.45, 0.0, 1.2, 0.0, 0.3),
  (66.5, sodium, 0.8, 0.0, 2.0, 0.0, 0.4),
  (88.0, music ++ "launch_rumble.mp3", 0.9, 0.0, 9.0, 0.5, 1.5),
  (129.2, music ++ "stencil_hit.mp3", 0.9, 0.0, 1.6, 0.0, 0.0),
  (130.0, music ++ "stencil_hit.mp3", 0.9, 0.0, 1.6, 0.0, 0.0),
  (130.8, music ++ "stencil_hit.mp3", 0.9, 0.0, 1.6, 0.0, 0.0),
  (131.6, music ++ "stencil_hit.mp3", 0.9, 0.0, 1.6, 0.0, 0.0),
  /* ---- dialogue pulls ---- */
  (3.5, pulls ++ "marwani_sorry.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (11.5, pulls ++ "radio_ban.wav", 0.9, 0.0, 0.0, 0.0, 0.0),
  (19.5, pulls ++ "buck_huh.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (23.0, pulls ++ "anchor_accord.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (36.0, pulls ++ "gunny_rollcall.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (44.0, pulls ++ "stitch_case.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (51.5, pulls ++ "dutch_380.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (57.5, pulls ++ "cricket_moveme.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (67.5, pulls ++ "dutch_generous.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (71.0, pulls ++ "tito_fit.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (76.3, pulls ++ "cricket_timeme.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (84.5, pulls ++ "dockworker_allclear.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (97.5, pulls ++ "lawyer_only.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (103.5, pulls ++ "gunny_wall.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (107.5, pulls ++ "vess_count.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (117.5, pulls ++ "hale_gfy.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (134.5, pulls ++ "brandt_where.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (137.2, pulls ++ "stitch_67.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (141.6, pulls ++ "dutch_72.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (143.2, pulls ++ "stitch_rounding.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
]

let f2 = v => Js.Float.toFixedWithPrecision(v, ~digits=2)

let main = () => {
  let missing = entries->Belt.Array.keep(((_, p, _, _, _, _, _)) => !existsSync(p))
  if Belt.Array.length(missing) > 0 {
    missing->Belt.Array.forEach(((_, p, _, _, _, _, _)) => Js.log("MISSING " ++ p))
  } else {
    let ins = ref("")
    let filters = []
    let labels = []
    entries->Belt.Array.forEachWithIndex((k, (start, p, vol, tS, tL, fI, fO)) => {
      ins := ins.contents ++ " -i \"" ++ p ++ "\""
      let ms = Belt.Int.toString(Belt.Float.toInt(start *. 1000.0))
      let chain = ref("[" ++ Belt.Int.toString(k) ++ ":a]")
      let steps = []
      if tL > 0.0 {
        Js.Array2.push(steps, "atrim=" ++ f2(tS) ++ ":" ++ f2(tS +. tL) ++ ",asetpts=PTS-STARTPTS")->ignore
      }
      if fI > 0.0 {
        Js.Array2.push(steps, "afade=t=in:d=" ++ f2(fI))->ignore
      }
      if fO > 0.0 && tL > 0.0 {
        Js.Array2.push(steps, "afade=t=out:st=" ++ f2(tL -. fO) ++ ":d=" ++ f2(fO))->ignore
      }
      Js.Array2.push(steps, "volume=" ++ f2(vol))->ignore
      Js.Array2.push(steps, "adelay=" ++ ms ++ "|" ++ ms)->ignore
      let lbl = "e" ++ Belt.Int.toString(k)
      Js.Array2.push(filters, chain.contents ++ steps->Belt.Array.joinWith(",", x => x) ++ "[" ++ lbl ++ "]")->ignore
      Js.Array2.push(labels, "[" ++ lbl ++ "]")->ignore
    })
    let n = Belt.Array.length(entries)
    Js.Array2.push(
      filters,
      labels->Belt.Array.joinWith("", x => x) ++
      "amix=inputs=" ++ Belt.Int.toString(n) ++ ":duration=longest:normalize=0,loudnorm=I=-16:LRA=11:TP=-1.5,alimiter=limit=0.97[out]",
    )->ignore
    sh(
      "/opt/homebrew/bin/ffmpeg -y -loglevel error" ++
      ins.contents ++
      " -filter_complex \"" ++
      filters->Belt.Array.joinWith(";", x => x) ++ "\" -map \"[out]\" -t 149 -b:a 192k \"" ++ out ++ "\"",
    )
    Js.log("TRAILER AUDIO -> " ++ out)
  }
}
main()
