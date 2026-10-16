# Progress log

Agent work while Jon is away. Tasks are in AGENT-TASKS.md.

## Decisions needed from Jon

- ~~C3 (exercises 3–4): D1–D8~~ **Decided 2026-10-16** and applied (see
  `exercises/lecture3-4/README.md`).
- ~~C1 (stepper)~~ **Decided:** try the stepper first, email Asai later. The
  trial is done (`research/stepper-trial.md`): adapt it. Emailing Asai is
  still open.
- **A4 (tick tests):** 15 questions about behaviour the ticks leave open, and
  about grading metadata. Short version:
  - negative facr/faci;
  - `last []`/`butlast []` (the spec's `List.rev (List.tl (List.rev xs))`
    raises, the model returns `[]`);
  - out-of-range nth;
  - gcd on non-positive arguments;
  - n = 0 in sumt/eapprox/exp (the models disagree: 0.0 vs 1.0);
  - choose with k > n or repeated elements;
  - remove of an absent key;
  - `power 0 0`;
  - whether merge must be lazy;
  - rescale's q for non-square images;
  - the Tick 5 line-drawing test cell isn't an autograder cell (and the
    line/drawLine solutions are "manually graded");
  - whether to apply the new tests to ticks already released.

  Full list in the A1–A4 report (handed back to the lead agent; summary
  under Log below).

- **B (focs-check), from `~/devel/x-ocaml-focscheck/FOCS-CHECK-NOTES.md`:**
  - Count's cost model: List functions cost a step per element, sorts a
    step per comparison; Array/Hashtbl/String are not counted (ban them).
  - Per-exercise workers (D6): a second x-ocaml script with its own
    `elt-name` already gives an exercise its own worker (tested); a
    `data-worker` attribute within one page is ~100-150 lines in
    `src/page.ml`. Should such cells see the page's hidden cells?
  - Take the module-alias worker fix (commits `Tests: a module alias stops
    the worker`, `Worker: a module alias no longer stops it`) onto
    `widgets-on-displays` on its own?
  - The browser's stack allows only ~6300 frames of `nsum`: students'
    non-tail recursion over 10^4 elements fails there.

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

### 2026-10-16: A1–A4 (tick tests and chaffs)

Done in `~/devel/focs` on branch `chaffs` (four commits, new files only, all
under `chaffs/`). Jon's uncommitted notebook changes haven't been touched.

- **A1:** all 10 uncommitted notebook diffs change **source**, not just
  outputs: the grade cells move from `assert` to `Focs.Test`.
  - Extra changes: Tick 1 gains an empty code cell; Tick 2's kernelspec goes
    from 4.10 to 4.14; Tick 5's toPPM test gains two cases; Tick 5*'s compute
    cell gains a real 2×2 reference test.
  - Everything was tested against the working-tree versions.
- **A2:** `chaffs/harness.py` runs every code cell in a fresh toplevel with a
  stand-in `focs` library (`chaffs/support/`, with a stub
  `Jupyter_notebook`). **All 10 model solutions pass.** A full run takes
  about 6 minutes.
- **A3:** 176 misconception chaffs, 4 structural chaffs and 33 alternative
  wheats across 34 questions (`chaffs/tickN/*.ml`, each with a one-line
  description).
- **A4:**
  - With the current grade cells, **48 of 176 chaffs survive**, including:
    - Tick 2 `nth _ n = n+1`, last = max, butlast = first three;
    - Tick 5's shared-rows aliasing bug, which the question itself warns
      about;
    - Tick 4's nfold, which is never tested at all.
  - The proposed grade cells (`chaffs/proposed/`,
    `chaffs/proposed-tests.patch`, which applies with `git apply`) leave
    **1 survivor**: Tick 4* `merge` that forces tails eagerly. Catching it
    needs a laziness test, which is a decision for Jon.
  - With the proposed cells, all 10 models and all 33 wheats still pass.
  - Per-question table: `chaffs/results.md`.

### 2026-10-16: stepper trial (S1)

- `research/stepper-trial.md`. Asai's stepper builds natively (4.14.2) and
  with js_of_ocaml 6.4.1 (a separate scratch switch). It runs under node:
  3.1 MB, or 617 KB gzipped with the stdlib .cmi files, at 10–20 ms per run.
- Keeping only the steps whose redex is a function call reproduces the
  notes' traces for nsum, summing, nrev, rev_app and change (with nested
  try).
- Problems: evaluation is right to left (so preorder visits C before B),
  there's a bug with `function` + `when` guards, and no support for loops,
  mutable fields or `lazy`. It's OCaml 4.14 only.
- Verdict: adapt it, with a library patch (about 28 lines), a step callback,
  a step filter and our own printer. Questions for Asai are listed in the
  file, for when Jon decides to email.

### B1-B6 (x-ocaml-focscheck, branch `focs-check`)

Full notes, measurements and open questions:
`~/devel/x-ocaml-focscheck/FOCS-CHECK-NOTES.md`. In short:

- B1: warning 51 fires in the browser on both workers, exactly as
  natively (`test/test_tailcall.html`). As an error it is reported, but the
  toplevel still defines the function (natively too).
- B2: deepest `nsum` ~6309 (plain) / 6000-7000 (effects); `nsum 100_000`
  overflows, `summing` survives 10^7 on both, so the lecture demo works.
  The effects worker does not grow the stack through closures or
  `List.fold_right`, and catching `Stack_overflow` there is unreliable.
- B3: `X_ocaml_lib.source "id"`, and `Focs_check.load ~as_:"Student"
  "rev-ex"`: isolated load with diagnostics at page lines
  (`test/test_check.html`). Found and fixed a worker crash on module
  aliases.
- B4: `focs-check/core` (Tailcheck, Count, Growth, Ban, Examplar), native
  unit tests all pass (nrev/rev, nsum/summing, power, insertion sort
  sorted/reversed, mergesort, fib, cubic); `Focs_check` in cells,
  `test/test_focs_check.html` on both workers. D8's `Forbid_library` added.
- B5: `examples/examplar.html` (last, butlast, nth with tick 2's chaffs),
  checked by `test/test_examplar.html`.
- B6: `<x-stepper>` (`examples/elements/stepper.js`) with predict and
  lecture modes and `step()`/`back()`/`reset()` for slips;
  `Focs_check.Steps`; `test/test_stepper.html`, `examples/predict.html`
  (rev with accumulator; pre/in/postorder).
- Full browser suite: every page passes except `test_ui.html`, which
  timed out before this work too.

