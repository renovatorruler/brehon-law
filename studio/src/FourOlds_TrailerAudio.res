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
let out = audio ++ "releases/FOUR-OLDS_TRAILER-AUDIO_v2.mp3"

let sh = (cmd: string): unit => {
  let opts = Js.Dict.empty()
  Js.Dict.set(opts, "stdio", Obj.magic("pipe"))
  let _ = execSync(cmd, opts)
}

/* (start, path, vol, trimStart, trimLen, fadeIn, fadeOut) — 0.0 trim/fade = none */
let arena = audio ++ "render_a01/010.wav"
let dinerBed = audio ++ "render_a01/042.wav"
let barnBed = audio ++ "render_sc03/000.wav"
let barnWind = "/Users/dusty/SFX/PSE/WINDInt_Interior Winds Wind In Barn Lighter_PSE_CW_I8rFX.wav"
let shopTone = "/Users/dusty/SFX/PSE/AMBRoom_Warehouse Factory Corridor Room Tone 04 ST3_PSE_GEN2_zExJW.wav"

let entries = [
  /* ==== M1 THE WORLD (0-29): the circus, then the diner switches it off ==== */
  (0.0, music ++ "bed_americana.mp3", 0.5, 0.0, 29.5, 1.5, 2.5),
  (0.8, arena, 0.28, 0.0, 9.5, 1.0, 1.0),
  (2.5, pulls ++ "marwani_sorry.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (9.6, music ++ "riser.mp3", 0.35, 0.0, 2.6, 0.0, 0.0),
  (10.8, dinerBed, 0.32, 0.0, 10.5, 0.8, 1.0),
  (11.4, pulls ++ "radio_ban.wav", 0.9, 0.0, 0.0, 0.0, 0.0),
  (18.6, pulls ++ "buck_huh.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (20.6, pulls ++ "anchor_accord.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (29.2, music ++ "subboom.mp3", 0.6, 0.0, 2.6, 0.0, 0.0),
  /* ==== M2 THE MEN (30-46): the ritual, the failed stand ==== */
  (29.8, music ++ "bed_march.mp3", 0.45, 0.0, 17.5, 0.8, 1.5),
  (30.2, barnBed, 0.32, 0.0, 9.5, 0.8, 0.8),
  (31.2, pulls ++ "gunny_rollcall.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (39.4, barnWind, 0.35, 0.0, 8.0, 0.6, 1.0),
  (40.4, pulls ++ "cricket_moveme.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (44.8, music ++ "riser.mp3", 0.45, 0.0, 2.6, 0.0, 0.0),
  /* ==== M3 THE CAPER (47-80): the needle, the silence gag, the launch ==== */
  (47.4, music ++ "needle_stomp.mp3", 0.7, 0.0, 9.2, 0.0, 0.25),
  (47.5, sodium, 0.7, 0.0, 2.0, 0.0, 0.4),
  (47.6, shopTone, 0.25, 0.0, 22.0, 0.5, 1.0),
  (50.2, pulls ++ "dutch_generous.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (53.6, pulls ++ "tito_fit.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (57.4, pulls ++ "cricket_timeme.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (62.0, music ++ "needle_stomp.mp3", 0.7, 10.0, 9.0, 0.15, 1.2),
  (63.2, music ++ "dockwalla.mp3", 0.3, 0.0, 7.5, 0.8, 1.0),
  (64.8, pulls ++ "dockworker_allclear.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (68.2, music ++ "riser.mp3", 0.5, 0.0, 2.6, 0.0, 0.0),
  (69.6, music ++ "launch_rumble.mp3", 0.95, 0.0, 9.0, 0.3, 2.0),
  (76.2, pulls ++ "lawyer_only.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  /* ==== M4 STANDOFF (81-101): the wall, the fury ==== */
  (81.0, music ++ "tension_note.mp3", 0.6, 0.0, 21.0, 1.5, 2.0),
  (81.6, music ++ "suitloop.mp3", 0.4, 0.0, 6.0, 0.5, 0.8),
  (83.2, pulls ++ "gunny_wall.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (87.6, music ++ "shutterburst.mp3", 0.5, 0.0, 2.0, 0.0, 0.3),
  (88.6, pulls ++ "hale_gfy.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (100.2, music ++ "subboom.mp3", 0.6, 0.0, 2.8, 0.0, 0.0),
  /* ==== M5 TITLE + BUTTON (103-122) ==== */
  (103.0, music ++ "stencil_hit.mp3", 0.85, 0.0, 1.4, 0.0, 0.0),
  (103.8, music ++ "stencil_hit.mp3", 0.85, 0.0, 1.4, 0.0, 0.0),
  (104.6, music ++ "stencil_hit.mp3", 0.85, 0.0, 1.4, 0.0, 0.0),
  (105.4, music ++ "stencil_hit.mp3", 0.85, 0.0, 1.4, 0.0, 0.0),
  (106.4, music ++ "title_hit.mp3", 0.9, 0.0, 10.0, 0.0, 0.0),
  (110.2, music ++ "suitloop.mp3", 0.35, 0.0, 6.0, 0.5, 1.0),
  (111.2, pulls ++ "brandt_where.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (113.8, pulls ++ "stitch_67.wav", 1.0, 0.0, 0.0, 0.0, 0.0),
  (119.2, music ++ "subboom.mp3", 0.45, 0.0, 2.8, 0.0, 0.0),
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
      filters->Belt.Array.joinWith(";", x => x) ++ "\" -map \"[out]\" -t 123 -b:a 192k \"" ++ out ++ "\"",
    )
    Js.log("TRAILER AUDIO -> " ++ out)
  }
}
main()
