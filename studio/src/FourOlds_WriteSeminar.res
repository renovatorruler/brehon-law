/* THE FOUR OLDS v14 — THE SEMINAR, rebuilt per the user's design:
   a worker sincerely asks what Mao's four categories MEAN, and the
   facilitator's four warm, concrete, American examples are — unknown to
   everyone in the room — portraits of the four men the movie is named for.
   First deliverable of v14. Engine-written, 1883 action-line register. */

let outPath = "/Users/dusty/Dev/metaphrand/.claude/worktrees/rosca-pitch/stories/four-olds/draft/engine_seminar_v14.scene.txt"

let seed: Seed.sceneSeed = {
  id: "four-olds-v14-seminar",
  slug: "INT. FRONTIER AEROSPACE, TRAINING ROOM B - DAY",
  logline: "Mandatory Cultural Alignment, Module 7: a corporate facilitator presents Mao's Four Olds as an admirable early framework; an older worker sincerely asks what the four categories actually mean, and her four cheerful, concrete, American examples describe — precisely, unknowingly — the four old men this movie is named for. Nobody in the room reacts. The audience does the math alone.",
  cast: [
    {
      name: "FACILITATOR",
      who: "30s, corporate trainer, all teeth, clicker in hand. Genuinely nice — that is the horror. She does not sneer at the old things; she examines them, warmly, the way a nurse discusses a growth. She improvises well and reads silence as engagement.",
      register: "chirpy corporate-positive, exclamation-adjacent, 'great question' energy; short bursts; never sarcastic, never cruel on the surface.",
      earnsEloquence: false,
      lexicon: "HR-training English: frameworks, examine, journey, retire (as a verb for traditions). No academic jargon, no political vocabulary.",
    },
    {
      name: "BAY TWO MAN",
      who: "60s, machinist laid off from Bay Two, attending because the notice said mandatory for rehire eligibility. He is not baiting her — he genuinely wants to understand what he is being asked to give up. His sincerity is what makes the scene land.",
      register: "plain, slow, few words, no rhetoric. Asks like a man asking about a part number.",
      earnsEloquence: false,
      lexicon: "shop plain.",
    },
    {
      name: "JOSS",
      who: "26, dock worker, near the back with sunflower seeds. Dry, minimal, constitutionally unable to let a thing pass — but he knows the sign-in clipboard feeds his compliance score.",
      register: "deadpan, short, no hand raised.",
      earnsEloquence: false,
      lexicon: "plain gen-z minimal, no slang overload.",
    },
    {
      name: "PELL",
      who: "50s, federal compliance administrator, drops in mid-module to be seen blessing the good work. Knows nothing about the content and consumes it like vitamins.",
      register: "beaming officialese, benedictory.",
      earnsEloquence: false,
      lexicon: "compliance-brochure English.",
    },
  ],
  layer: {
    peshat: "a mandatory corporate heritage-training session; a worker asks a sincere question; an administrator drops in; homework is assigned",
    sod: "the regime can already name, precisely and warmly, the four American virtues this film's four heroes embody — the machine sees exactly what it is erasing; it just cannot see the men. The audience, who knows the four olds, watches the state describe them one by one to a silent room.",
  },
  beats: [
    {
      who: "FACILITATOR",
      want: "deliver Module 7 on schedule with good engagement",
      wall: "a sincere question she was not scripted for: what do the four categories actually mean",
      turn: "she improvises four concrete examples — and they are perfect, more honest than she knows; the room goes quiet in a way she reads as breakthrough engagement and the audience reads as four portraits landing",
      subtext: "the machine explains itself best when it is not trying",
    },
    {
      who: "BAY TWO MAN",
      want: "genuinely understand what counts as an old idea, an old custom, an old habit",
      wall: "the categories are abstractions on a slide",
      turn: "he gets his answer, item by item, and it is his entire life and every man's life he knows; he says nothing more for the rest of the scene",
      subtext: "comprehension arriving as quiet loss",
    },
    {
      who: "JOSS",
      want: "poke the thing once",
      wall: "the sign-in clipboard feeds his compliance score",
      turn: "he asks anyway — what happened to the people who liked the old stuff — and the answer is a smiling euphemism; he files it",
      subtext: "the kid's first clear look at the machine's teeth",
    },
    {
      who: "PELL",
      want: "be seen blessing the good work",
      wall: "he knows nothing about the material",
      turn: "he praises the Mao slide as 'centuries of ancient Chinese wisdom,' is corrected ('it's from 1966—'), and beams 'Wonderful.' — and stays",
      subtext: "the enforcer takes propaganda like vitamins; accuracy is not the point, alignment is",
    },
  ],
  rules: [
    "THE PAYLOAD — the four examples, delivered warmly by the FACILITATOR in answer to the BAY TWO MAN's sincere question. Each must be concrete, American, and an unknowing portrait: (1) OLD IDEAS = the handshake deal — the idea that your word, or a signature on a fifty-year-old standard, still binds you today; she calls it romantic but unauditable. (2) OLD CULTURE = the tall tales — test-pilot folk heroes, the fella who could fly anything, stories nobody ever fact-checked. (3) OLD CUSTOMS = ceremony — folding a flag a particular way, standing to sing before a ball game; she asks what work the ceremony is really doing. (4) OLD HABITS = the small private discipline — the same ritual, the same day, every week, for fifty years, kept not because it serves you but because you would feel guilty stopping. She may close warmly: nobody is saying these are bad — we are saying, examine them.",
    "NOBODY in the room connects the examples to any person. No knowing looks, no reaction shots that wink, no character recognizes anything. The mapping belongs to the audience alone. The room's response to the four examples is SILENCE, which the Facilitator misreads as engagement.",
    "REQUIRED canon beats, keep these exactly: the slide sequence — a stylized Mao portrait over the words 1966 — A BOLD QUESTION: WHAT DO WE OWE THE PAST?, then a slide in clean sans-serif on harmony blue reading OLD IDEAS. OLD CULTURE. OLD CUSTOMS. OLD HABITS.; MACK in the third row copying the four category names into a pocket notebook in block letters (no explanation why); JOSS's line, not raising his hand: 'What happened to the people who liked the old stuff?' answered after a silence with: 'There were — implementation errors. In that era. Which is why today's frameworks center dialogue.'; PELL's drop-in: 'Don't mind me. This is the good work, folks. Centuries of ancient Chinese wisdom in that slide.' / FACILITATOR: 'It's from 1966—' / PELL: 'Wonderful.'; the homework slide: YOUR REFLECTION HOMEWORK — IDENTIFY ONE OLD HABIT YOU'RE READY TO RETIRE!; the chained sign-in clipboard that feeds compliance scores; the corridor button — JOSS, low: 'My grandpa's old habit was getting shot at over Hanoi.' MACK: 'Write coffee. Everybody writes coffee.'",
    "ACTION LINES per studio/SCREENPLAY_STYLE.md, strictly: one paragraph = one shot, 1-3 sentences, never more than 4 lines; verbs lead, fragments legal as shot-cuts; end a flowing beat with ' ...' and an interrupted one with ' --'; CAPS for first appearances, sounds, and the one object the frame must find, one detonation per beat max; sound on its own line; mini-slugs (AT THE DOOR --, ON THE SCREEN --) instead of prose transitions; NO similes, NO metaphors, NO aphorisms in action lines — plain facts the lens can see; at most one plain-fact editorial line in the whole scene; white space is pace.",
    "CIVILIAN LANGUAGE throughout — no insider jargon of any trade. The facilitator's corporate dialect is allowed because it translates itself.",
    "No rule-of-three rhythm in any dialogue except the slide text itself. The facilitator lists four things because there are four things, plainly, not musically.",
    "Kill every AI tell: no negative parallelism, no corrective definition, no em-dash chains in dialogue, no withheld-then-appended fragments about a single image.",
    "Length: about two screenplay pages. The scene ends in the corridor on Mack's coffee line — no extra coda.",
    "Fountain screenplay format: slugline, action lines, colon-terminated CHARACTER NAME: cues (this project's convention).",
  ],
}

let main = async () => {
  try {
    let sc = await Write.writeScene(~seed, ~maxTries=5)
    let out = Cinema_Backends.Path(outPath)
    let _ = Write.emit(sc, ~txt=out)
    Js.log("=== ENGINE WROTE: THE SEMINAR (v14) ===\n")
    Js.log(Cinema_Backends.readText(out))
  } catch {
  | Write.WriteError(m) => Js.log("WRITE FAILED (gate):\n" ++ m)
  | Session.SessionError(m) => Js.log("SESSION: " ++ m)
  }
  Session.close()
}
main()->ignore
