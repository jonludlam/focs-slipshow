# Progress log

Agent work while Jon is away. Tasks are in AGENT-TASKS.md.

## Decisions needed from Jon

- **C1 (stepper):** whether to try running Asai's OCaml 4.14 stepper in a
  separate 4.14 js_of_ocaml worker as a proof of concept, and whether to email
  Asai about a public repo, the licence (MIT in opam, but some files are
  patched LGPL compiler sources) and any 5.x plans. See `research/stepper.md`.
- **C3 (exercises 3–4):** eight specification decisions, D1–D8 in
  `exercises/lecture3-4/README.md`. The main ones: what `last []` does (3.2),
  whether order matters in 4.2, and how to word 3.3's "even-numbered".

## Log

### 2026-10-16: C1–C3

- **C1 done:** `research/stepper.md`. Asai's stepper exists only as a tarball,
  needs OCaml 4.14.2 and compiler-libs (no Unix or C stubs), and steps the
  Parsetree after a real typecheck. A jsoo build looks feasible, but in a
  4.14 worker, separate from x-ocaml's 5.x. Hazel and DrRacket are covered as
  design references.
- **C2 done:** filled the gaps in `AI-NOTES.md`: the supervisor AI guidance
  (Feb 2024, read via the Wayback Machine because the live link is dead), the
  department's AI policy (Oct 2024, which covers ticks), "Beyond the Hype",
  both CS50 papers and Lau & Guo. Still open: whether the supervisor guidance
  has been updated (the SharePoint copy needs Raven).
- **C3 done:** `exercises/lecture3-4/ex{3_1..3_5,4_1..4_4,4_6}.ml` plus
  `exercises/harness.ml` and `exercises/run.sh`. All ten files pass: every
  wheat passes and every chaff is caught. Tail recursion is checked natively
  with a small stack limit, and cost by counting allocations
  (`Gc.minor_words`). 4.1's O(mn) comparisons can't be seen that way and wait
  for B4's `Count`. 4.5 is a proof and stays in supervisions.
- Housekeeping: for a short time this checkout was switched to a branch
  `agent-notes`, so a commit made meanwhile (`0dc99d4`, ANIMATIONS.md) landed
  there. `main` has been fast-forwarded to include everything and the branch
  deleted. History is linear and nothing was lost.
