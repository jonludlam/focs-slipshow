# Demos

How to start them, and what to look at.

**Published** (2 Nov 2026) at <https://jon.ludl.am/experiments/focs/>: the
checked exercises, examples first, predict-the-step and the stepper, made
by `demos/publish.sh` and copied up with
`rsync -a --chmod=D755,F644 OUT/ jon@jon.ludl.am:/var/www/jon.ludl.am/experiments/focs/`.
The T9 pages are deliberately not published.

## 1. Checked exercises, Examplar and predict-the-step (x-ocaml)

    cd ~/devel/x-ocaml-focscheck && dune build && node test/serve.js 8811

(Port 8800 is the default, but another server was already using it.)

- <http://localhost:8811/examples/focs-demos.html>. Four exercises from the
  notes, each starting from an answer that fails its test. Edit the
  exercise, then unfold "Tests" to see what the checks found.
  1. **Make it tail recursive** (3.1): the compiler reports which recursive
     calls aren't tail calls.
  2. **Fix the complexity** (`rev`): a counting copy of the code, with a
     table of how the work grows ("when the input doubled, it did about 4.0
     times the work: O(n^2)").
  3. **No library functions** (D8): `List.fold_left` is caught, and so are
     `module L = List`, `open List` and `Stdlib.List`.
  4. **Find an input that breaks it** (4.3, the two `zip`s).
- <http://localhost:8811/examples/focs-demos-solved.html>: the same page
  with the answers filled in, so every test passes.
- <http://localhost:8811/examples/examplar.html>: examples first, for
  `last`, `butlast` and `nth`, checked against Tick 2's wrong solutions.
- <http://localhost:8811/examples/predict.html>: predict the next state.
  `rev` with an accumulator (box-and-pointer, with sharing), and pre-, in-
  and post-order traversal.
- Predictive text (T9), a draft Tick 3** in five checked parts. It holds
  the answers, so it lives in the private ocamllabs/focs-assignments repo,
  branch `t9` (worktree `~/devel/focs-t9`): run
  `python3 -I t9/make-page.py ~/devel/x-ocaml-focscheck/examples`, then
  open <http://localhost:8811/examples/t9.html> (and `t9-solved.html`).
  Don't commit the generated pages to x-ocaml, which is public.
- <http://localhost:8811/test_own_worker.html>: `change` with a zero coin, in
  its own worker, stopped without affecting the page.
- <http://localhost:8811/>: an index of every test page and example.

## 2. The stepper, in the browser

    cd ~/devel/focs-slipshow/demos && python3 -m http.server 8812 --bind 127.0.0.1

- <http://127.0.0.1:8812/stepper/>. Asai's stepper, compiled with
  js_of_ocaml, with examples from the notes (`nsum`, `summing`, `nrev`,
  `rev_app`, change with exceptions, `get 2 (from 6)`, and `preorder` to
  show right-to-left evaluation). Turn on "predict" to type the next line
  before it's shown, and "function calls only" off to see every small step.
- `stepper_web.js` isn't in git (licence unclear). To rebuild it, see
  `research/stepper-trial.md`. The driver is at
  `scratchpad/stepper/work/lib/webdrv/`.

## 3. Tick tests and chaffs (terminal)

    cd ~/devel/focs && python3 -I chaffs/harness.py --only tick2
    python3 -I chaffs/harness.py --show tick2 --chaff 3_nth/plus_one

For each wrong solution, this shows whether it survives the current grade
cells and the proposed ones. Expect 9 of 16 surviving now and 0 with the
proposed cells. The full run, over all ticks, takes about 6.5 minutes.

## 4. Exercise specifications for lectures 3–4 (terminal)

    ~/devel/focs-slipshow/exercises/run.sh

Every correct solution passes and every wrong one is caught, including the
library ban (3.1) and the cost checks (3.2, 3.3, 3.5). The T9
specification (24 tests, 14 wrong versions) is in focs-assignments' `t9`
branch; see its README.
