/* THE PERFORMANCE LAW (director's ruling, 2026-07-12): no dialogue reaches
   ElevenLabs TTS without expression tags from a gate-passed performance
   JSON. This interface makes the law structural: `performed` is opaque —
   the ONLY constructor is `load`, which re-verifies the performance
   against the verified scene, and the ONLY dialogue-TTS entry point in
   the codebase takes a `performed`. Raw text has no route to the API. */

type performed

/* who a performed line belongs to, for casting */
let roleOf: performed => string

/* line index in the scene, for asset naming / radio flags */
let indexOf: performed => int

/* Load a performance for a scene. Refuses when: the JSON is missing, the
   scene fails Write.read verification, a line's words differ from canon
   once tags are stripped, or any scene dialogue line is uncovered. */
let load: (~perfPath: string, ~scenePath: string) => result<array<performed>, string>

/* The one dialogue-TTS call. Caches by output path; a sidecar records the
   exact spoken text, so a re-directed line regenerates instead of reusing
   a stale take. Returns false on API failure. */
let tts: (performed, ~voiceId: string, ~outMp3: string) => promise<bool>
