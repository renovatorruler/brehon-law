# UX DOCTRINE — the story engine applied to product design
_2026-07-05 · first applied to the ROSCA app mockup (stories/rosca/mockup/)_

**The law: a screen is a scene.** The user is the protagonist on every screen,
arriving with a want; something stands in the way; a good screen TURNS — the user
leaves changed (paid, protected, committed), never merely informed. The story
passes are design gates. NOT a LARP: we never paint drama onto the UI — the drama
is already in the material (savings, a thief, a rusting guardian); the passes stop
the UI from hiding it.

**Granularity:** a FLOW is a scene (it must answer the three questions and turn).
A single screen is a BEAT — utility beats (a PIN pad) take no forced turns; that
is exactly where the LARP would creep in.

## The pass battery, ported

| Story pass | UX meaning |
|---|---|
| **Drama (Mamet 3 questions)** | Per flow: who wants what / what's the wall / why now / what turns / cost of failure. A flow that can't answer is a corridor — cut or fuse. |
| **Exposition is the enemy** | No briefing cards, no "How it works" bullet dumps. Every rule teaches itself AT THE MOMENT IT ACTS ON YOU (the veto explains itself when a veto lands). Learn by consequence, never by manual. |
| **Characters, not NPCs** | Every other party has self-interest, a time zone, a cost. Asking Emeka to co-sign shows his 2:47 AM first. Guardian actions spend something real. |
| **Heart layer** | The relationship ledger is first-class UI material: "214 Fridays beside you" — deposits banked in the open, and a recovery vote visibly spends them. |
| **Show-not-tell** | No adjectives about state ("Protected ✓"); show the event history instead (Friday's drill, who, how long it took). |
| **Clear-pane** | Intrigue lives in STATE, never in chrome. No teasing notifications, no mystery-meat, no confetti doing the feeling for the user. |
| **Frictionless antagonist** | Don't hide the walls — make them felt and beatable. The 72h delay visibly standing between a thief and the tin is the villain hitting a real wall. |
| **Doorways** | First tin deposit = Doorway 1 (commitment). Lost-phone restore = the midpoint mirror. The Friday drill = transformation TESTED, running as protocol. |
| **PaRDeS / Sod** | Each flow names its layers in its card. THE SOD IS NEVER STATED. This app's Sod: *you are never alone with money again.* If that sentence (or kin) appears in product copy, the gate fails the build. |
| **Held cards** | RULING (user, 2026-07-05): never withhold STATE (their money, their risk — that's a dark pattern). Withhold DEPTH: the app opens as a simple ajo ledger; the tin, the ring, inheritance surface only when the user's own life summons them (first surplus, first Friday, first scare). The reveal schedule is the user's own story. |
| **Humanizer / naturalness / plainness** | Microcopy register: plain, spoken, zero cheer ("Oops! 🎉" is the em-dash of UX). Banned-phrase lint in the gate. |
| **Entropy engine** | The mode-regression check: does this screen look like every fintech app? Protect the off-mode organs (ceremony, Friday ledger, duress pocket) from being sanded into Revolut. |
| **Blind attribution** | Strip the logo: if a SIGNATURE screen could be any neobank's, it fails. |
| **Cultural gate** | Same GATE.md pattern, new domain: who runs ajo circles (often women), church-hall vs market-day rhythm, naira habits beside MUSD. Read before designing a ceremony screen. |

## The copy law (RULING, user, 2026-07-05)
**UI copy is not prose. Every line must be something a real app would ship.**
The story lives in STRUCTURE — what appears, in what order, when — never in the
words. Two banned tells:
- **The narrated diorama** — a screen that narrates a scene instead of being an
  interface ("Mama Ngozi loads your pocket").
- **Invented texture** — the Corolla sin at UI level: named world-building
  characters, fake geography, flavor amounts ("kiosk 4, Ojota motor park").
Rules: labels are data ("214 Fridays", "son · Houston"); support text ≤ one
short line, usually zero; prefer a state-driven prompt card over a wizard page;
any other-party act (an agent loading cash) belongs to the SIM layer, not to a
product screen.

## The onboarding law (RULING, user, 2026-07-05)
**The app must open at the story's beginning — never in medias res.** A first-time
viewer (including the product's own designer) dropped into the mature state
(month six, full tin, deep history) is confused, not impressed. Onboarding IS
Act 1, and it must carry the story structure as real product steps — the user
lives a hero's journey by *doing proper onboarding*, never by being told they're
on one (no LARP):

1. **The call** — the first screen is a trusted PERSON, not software (Amaka's
   invitation; the circle is moving to the app).
2. **The world made visible** — the member list + the imported history ("six
   years of Fridays came with you"; five rounds from Amaka's notebook). The
   heart-ledger arrives pre-banked.
3. **Crossing the threshold** — cash becomes pocket at the agent's counter; the
   PIN is set because paying is about to need it (teach-at-consequence).
4. **Doorway 1** — the first irreversible act: pay the round, witnessed.
5. **The world opens SMALL** — two tabs (Home, Circle). Nothing else exists yet.
6. **Depth summoned** — first surplus → the tin → opening the tin reveals the
   keepers (the circle + the diaspora son). Only then do Vault + Recovery tabs
   exist.
7. **The ordeal, rehearsed** — the first Friday: watch someone ELSE's drill
   before your own turn.

The mature demo state is reachable ONLY via the SIM layer ("Skip to month six").
Every onboarding scene is a carded flow like any other (ob-invite, ob-circle,
ob-cashin, ob-contribute, guardian-pick).

## Enforcement (RULING: scaffold, don't trust memory)
Every flow ships with a **scene card** — a typed record in `studio/src/UxCards.res`
(want / wall / turn / cost / clock / sodCheck / exposition / heldCard — all fields
required, so an incomplete card does not compile). The mockup marks each flow with
`data-flow="<id>"`. **`studio/src/UxGate.res` BLOCKS**: a marked flow without a
card fails; a card without a marker warns (dead card); Sod-phrases and cheer-copy
in product UI fail. Run:

```
cd studio && npx rescript build
node src/UxGate.res.mjs <path-to-mockup.html>
```

The simulation layer (amber) is exempt from copy lints — it is deliberately not
the product.
