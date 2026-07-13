/* THE FOUR OLDS — scene 1 (cold open) authored in the DME CUE FORMAT for the
   Mix3 stem mixer. Two desk anchors flip across a triumphant day of coverage;
   each feed is a continuous ATMOS bed, cuts are CUT static transitions, and the
   whole thing collapses to a tinny diner radio. No named characters, no
   narrating of visuals — exposition is the anchors talking to each other.
   Run: CLAUDE_STUDIO_TURN_TIMEOUT_MS=360000 CLAUDE_STUDIO_BUDGET=12 node src/FourOlds_Audio_Sc01.res.mjs */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/audio/a01_cold_open.scene.txt"

let anchor: Seed.voiceCard = {
  name: "ANCHOR",
  who: "the woman at the desk, lead anchor; JUBILANT tonight, riding the high, feeding questions to her co-anchor and to the feeds",
  register: "warm broadcast lead, delighted; asks the questions that tee up the story",
  earnsEloquence: false,
  lexicon: "cable-news plain.",
}
let coanchor: Seed.voiceCard = {
  name: "COANCHOR",
  who: "the man at the desk, co-anchor; JUBILANT, the one who describes the incoming pictures and knows the details",
  register: "broadcast baritone gone giddy; answers her, narrates the feeds AS conversation, never as a chyron",
  earnsEloquence: false,
  lexicon: "cable-news plain.",
}
let announcer: Seed.voiceCard = {
  name: "ANNOUNCER",
  who: "the arena PA voice presenting the President",
  register: "big-room PA, formal, echoing",
  earnsEloquence: false,
  lexicon: "ceremony announcements.",
}
let senator: Seed.voiceCard = {
  name: "SENATOR",
  who: "a senator at the hearing making the reasonable-sounding case for taking Frontier public",
  register: "dry, calm, reasonable in its own frame",
  earnsEloquence: false,
  lexicon: "hearing-room plain; the socialist argument stated plainly.",
}
let radio: Seed.voiceCard = {
  name: "RADIO",
  who: "a small radio on a diner counter reading a regulatory notice at almost no volume",
  register: "flat government-notice read",
  earnsEloquence: false,
  lexicon: "regulatory boilerplate.",
}

let seed: Seed.sceneSeed = {
  id: "audio-01-cold-open-v8",
  slug: "SCENE 1. THE COLD OPEN - BROADCAST MONTAGE",
  logline: "Two desk anchors carry a triumphant night of coverage for the new regime, flipping to feed after feed, until it all shrinks to a tinny radio on a diner counter that somebody switches off.",
  cast: [anchor, coanchor, announcer, V14Cast.marwani, V14Cast.hale, senator, radio],
  layer: {
    peshat: "a two-anchor broadcast montage of the regime's victory day, ending in an ordinary diner",
    sod: "the whole grand circus, met by one room that turns off the television",
  },
  beats: [
    {
      who: "ANCHOR",
      want: "to carry the night feed by feed with her co-anchor",
      wall: "so much is happening at once",
      turn: "she and the CO-ANCHOR trade the coverage like the giddy desk team they are — she asks, he describes the incoming feeds AS conversation, never reading a chyron; the exposition IS their banter",
      subtext: "the machine narrating its own triumph, delighted",
    },
    {
      who: "MARWANI",
      want: "to consecrate the era from the podium",
      wall: "nothing — unopposed",
      turn: "OPENS BY THANKING THE NATION ('Thank you. Thank you, all of you'), then 'I do not stand here to celebrate a victory. I stand here to begin a repair.' / 'to every nation we have wronged, we are sorry.'",
      subtext: "the smile as the weapon",
    },
    {
      who: "COANCHOR",
      want: "to walk the audience through the incoming pictures",
      wall: "he can only describe what he is being shown",
      turn: "the cash bay comes as a two-anchor exchange — SHE: 'what are we looking at here?' HE: 'the cargo bay of the first flight out, pallets of banded hundreds floor to ceiling' SHE: 'how much are we talking?' HE: 'first cash delivery under the Iran Compensation Framework — first of twelve' — no selfie, no phone alert, no chyron",
      subtext: "obscene numbers, cheerful",
    },
    {
      who: "SENATOR",
      want: "the moral case for taking Frontier public",
      wall: "Hale reads a compliance script",
      turn: "HALE: 'Frontier is proud to serve the goals of this administration.' then the SENATOR's calm SOCIALIST RATIONALE — no one man should own the only road off the planet, public money built it, the age of the billionaire owning the future is over — call it nationalization; Hale banked and silent",
      subtext: "the reasonable face of the taking",
    },
    {
      who: "RADIO",
      want: "to finish a notice nobody hears",
      wall: "it plays to a diner that has stopped caring",
      turn: "the broadcast shrinks to a tinny counter radio reading the fireworks ban; a mug down, a stool, a hand clicks the set dark, quiet, then the theme",
      subtext: "the one casualty this room notices is the Fourth",
    },
  ],
  rules: Belt.Array.concat(
    [
      "AUTHOR IN THE DME CUE FORMAT (this is mandatory — the mixer reads it). Sounds are written as ACTION lines with a prefix:\n\
- A continuous background bed:  ACTION: ATMOS <space> | <description>\n\
- A hard cut to a new feed:     ACTION: CUT <space> | <static or whoosh description>\n\
- A one-off spot effect:        ACTION: FX | <description>\n\
- Music (only the end sting):   ACTION: MUSIC | <description>\n\
<space> is one of: studio, arena, cargobay, hearing, diner. A bed plays until the next ATMOS/CUT. Dialogue carries its PERSPECTIVE as a leading wryly: the desk anchors speak (close); the arena announcer and the President speak (pa); the diner radio speaks (radio). Example of the grammar:\n\
ACTION: ATMOS studio | election-night control-room, low bustle and monitors\n\
ANCHOR: (close) We can call it. The whole map has turned.\n\
COANCHOR: (close) I have never seen a board move like that.\n\
ACTION: CUT arena | a wash of broadcast static\n\
ACTION: ATMOS arena | a vast hall, a huge settled crowd\n\
ANNOUNCER: (pa) Please rise for the President of the United States.",
      "OPEN ON BREAKING NEWS. The very first cue is the network's breaking-news identity: ACTION: FX | a breaking-news sting and bed, then ATMOS studio. Establish the anchor DESK immediately.",
      "TWO ANCHORS, EXPOSITION AS CONVERSATION. A woman (ANCHOR) and a man (COANCHOR) co-anchor. They tell the story by talking TO EACH OTHER — she asks, he answers. NEVER narrate a visual: no 'there's an alert on my phone', no reading chyrons or tickers aloud, no describing a selfie. The cash bay is the model exchange (she: what are we looking at / he: pallets of hundreds, first Iran disbursement / she: how much / he: first of twelve).",
      "NO NAMED CHARACTERS. The listener has met no one. Voices are broadcast ROLES (anchor, co-anchor, arena announcer, the President, a senator, a radio) or anonymous (the diner). No Buck, no Earlene, no named aide. Marwani and Hale are named only as the anchors identify them on air.",
      "THE MONTAGE, feed by feed, each its own ATMOS bed with a CUT static between: studio desk -> CUT -> arena (Marwani's speech, thanking the nation first) -> CUT back to studio (the anchors on the Nobel Peace Prize, citing the announced agenda) -> CUT -> cargobay (the Iran cash exchange) -> CUT -> hearing (Hale + the Senator's socialist rationale) -> the FINALE.",
      "THE FIDELITY-DROP FINALE. After the hearing, the broadcast THINS and goes tinny: ACTION: CUT diner | the broadcast shrinks to a little counter radio, then ATMOS diner | a griddle, a quiet morning counter. The RADIO (radio) reads the fireworks-ban notice low; FX a mug set on a saucer, FX a stool creak, FX the set clicks off mid-word; a beat of quiet; then ACTION: MUSIC | the show's theme rises. Anonymous throughout.",
      "KEEP CANON: Marwani 'we are sorry'/'repair'; Nobel 'announced agenda'; Iran Compensation Framework, first of twelve; the Senator's nationalization case; the nationwide fireworks ban. The anchors are JUBILANT.",
      "SHORT — two and a half to three minutes. The anchors are the spine; feeds are quick; the diner finale gets the air.",
    ],
    AudioRules.common,
  ),
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=4)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    let sc2 = await Write.liftDialogue(~path=out, ~maxTries=3)
    let _ = Write.emit(sc2, ~txt=out)
    switch Write.verify(out) {
    | Ok() => Js.log("OK audio-01-v8")
    | Error(m) => Js.log("BAD audio-01-v8 — " ++ m)
    }
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED:\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
