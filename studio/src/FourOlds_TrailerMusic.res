/* THE FOUR OLDS trailer — the five music cues via the ElevenLabs Music API.
   No artist names in prompts (house law). Cached per cue.
   Run: node src/FourOlds_TrailerMusic.res.mjs */

type response
@val external fetch: (string, 'a) => promise<response> = "fetch"
@get external statusOf: response => int = "status"
@send external arrayBuffer: response => promise<'ab> = "arrayBuffer"
@send external textOf: response => promise<string> = "text"
@val @scope("Buffer") external bufferFrom: 'a => 'b = "from"
@module("fs") external writeFileSync: (string, 'a) => unit = "writeFileSync"
@module("fs") external readFileSync: (string, string) => string = "readFileSync"
@module("fs") external existsSync: string => bool = "existsSync"
@module("fs") external mkdirSync: (string, 'a) => unit = "mkdirSync"

let dir = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/trailer_music/"
let apiKey = Js.String2.trim(readFileSync("/Users/dusty/.elevenlabs_api_key", "utf8"))

let cues = [
  (
    "bed_americana",
    40000,
    "Sparse, patient Americana instrumental: a lone pedal steel guitar over faint acoustic strums, warm and open like a plains Sunday morning, unhurried, melancholy but dignified, no drums, no vocals, cinematic trailer opening bed.",
  ),
  (
    "bed_march",
    35000,
    "The same sparse Americana palette joined by a quiet military snare pattern building slowly: pedal steel, low acoustic guitar, restrained snare march gathering resolve, no vocals, cinematic trailer second-movement bed, rising but held back.",
  ),
  (
    "needle_stomp",
    50000,
    "A 1960s AM-radio country-rock stomper, instrumental: driving drums, twangy electric guitar riff, handclaps, upright piano hits, sunny and defiant and a little reckless, vintage warm tape saturation, trailer montage energy, ends on a big open chord.",
  ),
  (
    "tension_note",
    30000,
    "A single sustained low cinematic drone: one austere held string-and-synth note with a slow subtle swell and faint high shimmer, tense and vast like open space, no melody, no drums, no vocals, trailer third-act suspension bed.",
  ),
  (
    "title_hit",
    12000,
    "One massive cinematic title hit: a warm brass-and-drums impact that rings out and decays with a long tail, a second smaller echo hit, then silence, vintage analog warmth, no melody, no vocals.",
  ),
]

let gen = async (name: string, ms: int, prompt: string): bool => {
  let out = dir ++ name ++ ".mp3"
  if existsSync(out) {
    Js.log("SKIP " ++ name)
    true
  } else {
    let body = Js.Dict.empty()
    Js.Dict.set(body, "prompt", Js.Json.string(prompt))
    Js.Dict.set(body, "music_length_ms", Js.Json.number(Belt.Int.toFloat(ms)))
    let headers = Js.Dict.empty()
    Js.Dict.set(headers, "xi-api-key", apiKey)
    Js.Dict.set(headers, "Content-Type", "application/json")
    let opts = Js.Dict.empty()
    Js.Dict.set(opts, "method", Obj.magic("POST"))
    Js.Dict.set(opts, "headers", Obj.magic(headers))
    Js.Dict.set(opts, "body", Obj.magic(Js.Json.stringify(Js.Json.object_(body))))
    let resp = await fetch("https://api.elevenlabs.io/v1/music", opts)
    if statusOf(resp) == 200 {
      let ab = await arrayBuffer(resp)
      writeFileSync(out, bufferFrom(ab))
      Js.log("OK   " ++ name)
      true
    } else {
      let t = await textOf(resp)
      Js.log("FAIL " ++ name ++ " HTTP " ++ Belt.Int.toString(statusOf(resp)) ++ " " ++ Js.String2.slice(t, ~from=0, ~to_=200))
      false
    }
  }
}

let main = async () => {
  mkdirSync(dir, {"recursive": true})
  let n = Belt.Array.length(cues)
  let rec go = async i =>
    if i < n {
      let (name, ms, p) = Belt.Array.getExn(cues, i)
      let _ = await gen(name, ms, p)
      await go(i + 1)
    }
  await go(0)
  Js.log("MUSIC DONE")
}
main()->ignore
