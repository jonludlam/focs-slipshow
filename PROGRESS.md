# Progress log

Agent work while Jon is away. Tasks are in AGENT-TASKS.md.

## Decisions needed from Jon

- **C1 (stepper):** whether to try running Asai's OCaml 4.14 stepper in a
  separate 4.14 js_of_ocaml worker as a proof of concept, and whether to email
  Asai about a public repo, the licence (MIT in opam, but some files are
  patched LGPL compiler sources) and any 5.x plans. See `research/stepper.md`.
- ~~C3 (exercises 3–4): D1–D8~~ **Decided 2026-10-16** and applied (see
  `exercises/lecture3-4/README.md`).
- ~~C1 (stepper)~~ **Decided:** try the stepper first, email Asai later. A
  trial is under way (`research/stepper-trial.md` when done).

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

### 2026-10-16: decisions D1–D8 applied

- The tests for D1, D3 and D5 are now `Spec` tests. Browser wording for 3.3,
  3.5, 4.2 and 4.6 is recorded in each file's header.
- D8: `Harness.uses_library` plus `run ~no_library` add a library ban checked
  on the source. 3.1 has two new chaffs (`List.fold_left`, and
  `Stdlib.List.fold_left`) that only the ban catches. `run.sh` is ALL OK.
- D6 needs x-ocaml to run an exercise in its own worker (passed on to the
  focs-check work).
