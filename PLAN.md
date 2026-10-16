# FoCS: examples, specifications and misconceptions

A plan for bringing ideas from Shriram Krishnamurthi's recent work into FoCS.
It covers the ticks (`~/devel/focs`, `~/devel/focs-support`), the lecture
slips (this repo), x-ocaml (`~/devel/x-ocaml-stack`) and the notes.

## Timing

- **Now (Michaelmas 2026):** only the tick *test cases* change (W1). No
  changes to wording, specifications or structure.
- **Next year (2027–28):** everything else. The prototypes are built this
  year so there's time to try them and change direction.

## Sources

- Fisler, Krishnamurthi, Littman, *Teaching Novice Computing and Programming
  in the Agentic AI Era*, CACM 2026. Treat agents as "flaky compilers", put
  specification and testing first, and have students read code before they
  write it.
- Examplar: students write examples first, checked against a correct
  implementation (the wheat) and wrong ones (chaffs). Covered by ICER 2019,
  Koli 2020, *Making Hay from Wheats* (Koli 2022) and *Conceptual Mutation
  Testing* (Programming 2024).
- *Who Tests the Testers?*: weaknesses in automated grading.
- SMoL Tutor (OOPSLA 2024): misconceptions about binding, mutation and
  aliasing.
- *Problematic and Persistent Post-Secondary Program Performance
  Preconceptions* (Koli 2022).
- Higher-order function composition: SIGCSE 2022 and ICFP 2022 (structural
  vs pipeline).

## What we found

- The tick grade cells are weak. `nth _ n = n + 1`, `last` written as the
  list's maximum, and `butlast` written as "the first three" all pass Tick 2
  (`scratchpad/chaffs.ml`).
- Students never write tests. The grade cells are visible and none are
  hidden.
- The spec is left open in several places: negative arguments to
  `facr`/`faci`, `last []`, out-of-range `nth`, invalid input to `gcd`, and
  1-based subscripts in `getSubsOfEvens`. The notes have the same problem:
  exercise 3.3 counts from 1 without saying so, and 3.2, 3.5, 4.1, 4.2 and
  4.4 are also open.
- `~/devel/focs` has uncommitted output changes in all 10 source notebooks.

---

## Workstreams

### W0. Housekeeping (now, before W1)

- [ ] Check the uncommitted notebook diffs in `~/devel/focs`. Strip the
      outputs, and commit any real content change as its own commit.
- [ ] Confirm the repo matches what's deployed on the hub, and note each
      tick's release and due date.
- [ ] Find out how `focs-support` gets onto the hub, and who deploys it.

### W1. Check the graders with chaffs (now)

The goal is grade cells that reject plausible wrong answers without changing
what the questions ask.

- [ ] **Prototype P1, the harness.** A script that:
  1. pulls the solution cells and grade cells out of `source/*.ipynb`,
  2. runs the grade cells in the OCaml toplevel with the `focs` library,
     first against the model solution and then against each chaff,
  3. reports any chaff that passes every test, and fails loudly if the
     model solution fails.
- [ ] Write 3–6 chaffs per question, each a *plausible misunderstanding*
      rather than random mutation: confusing 0- and 1-based indexing, an
      off-by-one in the base case, max/min instead of last, reversed output,
      dropped duplicates, ignoring an argument, a wrong accumulator start
      value.
- [ ] Strengthen the grade cells until no chaff passes. **Rule for now:** add
      tests only for behaviour the question already specifies. Questions
      that leave behaviour open go on the W1 list for next year, not into
      this year's tests.
- [ ] Decide what happens with ticks already released this year: apply the
      new tests anyway, or only to ticks not yet due. *(Jon decides.)*
- [ ] Done when every model solution passes, every chaff fails, and the
      harness is committed and can be rerun before each release.

### W2. Examplar in the ticks (prototype this year, use next year)

- [ ] **Prototype P2: `Focs.Examplar`** in `focs-support`. It takes a wheat,
      a list of named chaffs and the student's examples, and returns a
      validity verdict and a thoroughness score. Expected exceptions need
      handling, e.g. with `('a, exn) result`.
- [ ] Check that nbgrader's `BEGIN HIDDEN TESTS` blocks work with the OCaml
      kernel. Nothing uses them yet. If they don't work, the fallback is
      wheats and chaffs in a compiled module on the hub.
- [ ] **Prototype P3: a pilot notebook.** A copy of Tick 2 with an
      "examples first" question before `nth`/`last`/`butlast`. The
      implementation is then graded against both the staff tests and the
      student's own examples.
- [ ] Decide how it's graded: formative only, points for valid examples, or
      points for chaffs caught.
- [ ] Resolve the open specifications listed above, so each one becomes
      something an examples question asks students to decide.

### W3. Examplar in lectures, with x-ocaml (prototype this year)

- [ ] **Prototype P4.** A slip for the lists lectures (3/4) built from the
      hidden cell, exercise cell and test cell sequence in x-ocaml-stack. The
      report is shown with `X_ocaml_lib.html`. The `rev`/palindrome trap
      plays the role of Examplar's median/mean example. Exercise 3.3, the
      even-numbered elements, works as a live demonstration.
- [ ] Keep the wheats and chaffs in a single place, used by both W2 and W3.
- [ ] Check it in a browser: the wheat can't be reached from student cells,
      a chaff that never terminates doesn't hang the page, and examples are
      kept when the page is reloaded.
- [ ] Possible x-ocaml-stack features: a test result that can show a partial
      score, and an attribute that hides a cell until the cell before it
      passes (the "Begin Implementation" step).

### W4. Other prototypes for misconceptions (prototype this year)

- [ ] **P5. A SMoL-style quiz for lecture 11** (references and arrays). The
      student predicts the output, built with x-ocaml-stack's `Ui`, and a
      wrong answer gets a correction aimed at that specific misconception.
      Possible items: `swap r r` (aliasing), `int ref list` vs
      `int list ref`, closures that capture a reference. Use "binding"
      rather than "call by" throughout.
- [ ] **P6. A performance poll for lecture 2.** Students rank small programs
      by cost before O-notation is taught, and the results are used during
      the lecture.
- [ ] **P7. Higher-order function composition exercises for lecture 8.**
      Separate pipeline compositions (`filter` then `map`) from structural
      ones (transpose, matrix multiply), and check which ones students find
      hard.

### W5. Specification first, in the spirit of the CACM paper (one prototype; mostly next year)

- [ ] **P8.** One prototype question in the "moderate" style: students write
      the purpose statement, the examples and a property for a function, and
      an LLM (or a hidden implementation) produces code they then have to
      accept or reject using their examples. Porpoise works like this. This
      is to see whether it's worth doing, not a commitment.
- [ ] Draft an explicit AI policy for the ticks and supervisions, and say it
      more than once.

### W6. Collect misconceptions (next year, but design now)

- [ ] **P9.** A script that pulls the examples failing the wheat out of
      nbgrader submissions, plus a simple meaning-based clustering, tried on
      synthetic data this year.
- [ ] Ethics and consent: get approval *before* collecting anything, if
      there's any chance of publishing.
- [ ] Each year, turn the clusters into new chaffs.

### W7. The notes, v1.9 for next year

- [ ] Add "write examples first" to the coding exercises, and fix the
      underspecified ones (3.2, 3.3, 3.5, 4.1, 4.2).
- [ ] Update the introduction, which still describes Jupyter's "Cell / Run
      All", to match whatever students actually use.
- [ ] Add x-ocaml cells to the Forester web notes, if Forester can host the
      script.

### W8. Write-up for Anil

- [ ] A short shareable page: the relevant research, the W1 results (the
      chaffs that passed), the prototypes and the proposal for next year.
      Write it once W1 and P4 exist, so it has something concrete to point
      to.

---

## Order of work

1. W0, then W1 (now).
2. P2 → P3 and P4 together, since they share the wheats and chaffs.
3. P5–P7, then P8 and P9.
4. W8, then W7 during the Easter/summer rewrite of the notes.

## Open questions

- Should W1's stronger tests apply to ticks already released this year?
- Do nbgrader hidden tests work with the OCaml kernel?
- Should the examples questions count for credit or be formative?
- Where should the shared wheats and chaffs live: `focs-support`, or a new
  repo?
