# The ROSCA wallet — edge-case deep dive (2026-07-06)

## The law
**Nothing waits forever. Every dangling state either completes at the next
Friday meeting, or safely undoes itself by deadline.**
- SOCIAL pending states (recovery shares, drills, disputes) complete AT THE
  MEETING — attendance is already forced by the pot.
- MONEY pending states (escrowed contributions, timed withdrawals) REVERT
  automatically when their condition isn't met by deadline.
- SILENCE states (owner inactive) escalate on a user-configured timer, gated by
  human confirmation (3 keepers), cancelled by any sign of life.

## The two structures (why keys ≠ keepers)
| | Keys (vault) | Keepers (wallet recovery) |
|---|---|---|
| Protects against | a thief TODAY | losing the phone entirely |
| Power | move vault money (2 of 3) | restore the wallet (3 of N) — NO spending power |
| Members | phone · card · one remote person | the circle (default) or 5 chosen |
| Ceremony | card tap · remote accept | shares dealt at the Friday meeting |
Separation is load-bearing: keepers who could spend = 3 friends can rob you.

## Problem families → resolutions
1. **Half-accepted keeper set rots** → shares are dealt at the meeting, together;
   default recovery = "my circle" (one tap, nobody to chase). Custom-5 also
   completes at Friday. Interim: deposits allowed (2 keys), one amber line
   "recovery activates Friday", steal/restore gated until dealt.
2. **Paid early, meeting never happens** → SUPERSEDED (decision 2026-07-06):
   pre-paying is CUT. Contributions exist only at the Friday table, witnessed.
   No escrow, no refund machinery — no meeting, no money moved, nothing to undo.
   (The lock-for-Friday commitment device remains a documented alternative if
   field data later shows demand: stories/rosca history, v12.)
3. **Pot pays with missing contributions** → payout guard: 12/12 only (built).
4. **Inheritance misfires** → it never auto-sends: silence(configurable 30/90/180)
   → transfer STARTS → 3 keepers confirm → heir receives; any owner activity or
   keeper objection cancels. Default 90 = longer than a hospital stay, shorter
   than destitution.
5. **Withdrawal limbo** → timed withdrawal auto-expires if unreleased 7 days
   after unlock (returns to vault). [future]
6. **Coercion** → vault visible, provably unopenable alone; every withdrawal
   visible to keepers (see duress ruling — no hiding, no decoys).
7. **Keeper dies/leaves circle** → next Friday's share refresh detects the dead
   share at zero cost; re-deal in the room. (The drill IS this detector.)
8. **Receiver's turn arrives while they're the one missing** → meeting rule, not
   app rule: the room reschedules; escrow holds; refund clock still runs.

## What the app changed today
- Vault setup = KEYS ONLY. Recovery moved to Me (wallet-level).
- Recovery default "Use my circle" (one tap); custom-5 optional; both DEAL AT
  FRIDAY (new meeting step); circle-mode ceremonies are batch actions.
- Escrow line on the pot sheet + REFUND world event (meeting never happens →
  money returns, round resets).
- Heir setup asks the period (30/90/180) + copy: starts-not-sends, 3 keepers
  confirm, activity cancels.
