# Tasks an agent can do independently

Work that can go ahead while Jon is away. Each task says where the work goes,
how to tell it's done, and what needs Jon's review. The background is in
`PLAN.md`, `EXERCISES.md` and `AI-NOTES.md`.

## Rules for working unattended

- **Never push, open PRs, publish or deploy anything.** All work stays as
  local commits.
- **Work on a new branch or worktree in each repo**, never on someone else's
  checked-out branch:
  - `~/devel/focs`: branch `chaffs`. The working tree has **uncommitted
    changes in all 10 notebooks that belong to Jon. Don't commit, revert or
    overwrite them.** Add new files only. Changes to tests are *proposals*:
    a patch file plus a report, not edits to the notebooks.
  - `~/devel/focs-support`: branch `chaffs`.
  - `~/devel/x-ocaml-stack`: new worktree `~/devel/x-ocaml-focscheck` on
    branch `focs-check`, taken from `widgets-on-displays`. That repo has
    several other worktrees and uses jj, so stay out of the others.
  - `~/devel/focs-slipshow`: commit only files you created. Leave Jon's
    uncommitted slip changes alone.
- **Don't change the opam switch** (no `opam install`). If a dependency is
  missing, such as `jupyter.notebook` for `focs-support`, stub it or work
  around it.
- **No student data goes anywhere.** Don't open `grades.csv` beyond its
  header, and don't send any course material to external services.
- Commit regularly, with clear messages and the attribution line.
- Record progress, results and open questions in `PROGRESS.md` in this repo.
- If a task needs a decision only Jon can make, write the question in
  `PROGRESS.md` and move on.

---

## A. Tick tests and chaffs (`~/devel/focs`, `~/devel/focs-support`)

A1. **Sort out the uncommitted notebook diffs.** Report only. For each
    notebook, say whether the change is just outputs and execution counts, or
    changes the source of cells. Don't change anything.

A2. **Grade-cell harness.** A script, kept under `~/devel/focs/chaffs/`, that:
  - pulls the solution cells and the locked grade cells out of
    `source/*/*.ipynb`;
  - runs them in the OCaml toplevel, with a stand-in for `Focs.Test` and
    `Focs.Tree` taken from `focs-support/lib/*.ml` minus the Jupyter
    dependency;
  - checks that each model solution passes.

  *Done when* all model solutions pass, or the ones that don't are explained.

A3. **Chaffs for every tick question** (ticks 1–5 and the starred ticks).
    Write 3–6 wrong implementations per question, each based on a plausible
    misconception rather than a random mutation. Each needs a one-line
    description.

A4. **Report the chaffs that pass all the tests**, and propose stronger grade
    cells as a patch. The patch may only test behaviour the question already
    specifies. *Done when*, with the patch applied, every model solution
    passes and every chaff fails. Questions that leave behaviour open (e.g.
    negative arguments to `facr`, `last []`) go in a list of decisions for
    Jon.

## B. x-ocaml-stack (`~/devel/x-ocaml-focscheck`)

B1. **Does warning 51 fire in the browser?** Add a test page in the style of
    `test/`. It runs a cell containing `(nsum [@tailcall])` and checks that
    the warning appears, in both the plain and the effects worker.

B2. **Stack behaviour in the browser.** On a test page, how deep can
    non-tail recursion (`nsum n`) go before overflowing, and does tail
    recursion (`summing n 0`) survive 10⁶, in each worker? Record the numbers
    in `PROGRESS.md`. They decide whether the lecture's stack-overflow
    demonstration works in the browser.

B3. **Reading a cell's source, and isolated evaluation.** Prototype an
    OCaml API that a test or hidden cell can use to:
  - read an exercise cell's source by its `data-id`;
  - parse, rewrite, type-check and evaluate that source in an isolated
    module, getting back warnings, errors and the result.

  Add browser tests for it.

B4. **A `focs-check` library** (OCaml, unit-tested natively first, then in
    the browser):
  - `Tailcheck`: inject `[@tailcall]` on calls within a `let rec` group and
    report warning 51.
  - `Count`: an instrumenting rewriter (function entries and `::`) plus
    counting versions of `List` and `(@)` to replace the standard ones.
  - `Growth`: fit the counts against the models {1, log n, n, n log n, n²,
    n³, 2ⁿ}, and produce a feedback table.
  - `Ban`: Typedtree checks that forbid or require identifiers and syntax,
    resolved by path so that aliasing doesn't get around them.

  *Done when* the unit tests correctly classify `nrev`/`rev`, `nsum`/
  `summing`, `power`, insertion sort on sorted and reversed input, and
  mergesort.

B5. **An Examplar demo page.** Hidden wheat and chaffs, an exercise cell for
    the student's examples, and a test cell showing "caught N of M". Use
    `nth`, `last` and `butlast`, sharing the chaffs from A3.

B6. **A predict-the-step animation prototype.** A custom element driven by
    events from a cell, animating `rev` with an accumulator. At each step the
    reader picks the next state from options before it's shown, and wrong
    options come from known misconceptions. A second version does tree
    traversal (pre-, in- and post-order).

## C. Research and notes (`~/devel/focs-slipshow`)

C1. **Is "Stepping OCaml" usable?** Find the code for Furukawa, Cong & Asai's
    stepper (and Asai & Akiyama, PEPM 2025): its licence, the OCaml version
    it needs, and whether it could be compiled with js_of_ocaml. Report
    only.

C2. **Fill the gaps in `AI-NOTES.md`:** Cambridge's guidance on GenAI in
    supervisions, the full "Beyond the Hype" report, the results in the CS50
    papers, and Lau & Guo 2023. Keep links to the originals.

C3. **Exercise specifications for lectures 3–4.** For each coding exercise in
    the notes (3.1–3.5, 4.1–4.3), write a data file with:
  - the correct solution;
  - 3–6 chaffs;
  - tests;
  - the expected complexity class and input family, where it matters;
  - whether it must be tail recursive;
  - the question type (write it, fix it, find the breaking input, examples
    first);
  - and whether it belongs in the notes or in supervisions.

  Flag the exercises whose specification is left open.

## Order of work

A1 → A2 → A3 → A4 and B1 → B2 → B3 → B4 can run in parallel. B5 needs A3's
chaffs. C1–C3 can run at any time.
