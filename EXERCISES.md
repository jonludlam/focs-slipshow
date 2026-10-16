# Checked exercises in the browser: design notes

Goal: turn the exercises in the notes into exercises that run and are checked
in the browser, entirely locally (js_of_ocaml in x-ocaml-stack's worker, no
server). The checks should cover correctness and, where it matters,
**complexity** and **tail recursion**. Add bug-fixing questions, and
animations where the reader has to predict the next step.

This is design thinking plus some feasibility results. It is not a committed
plan yet.

---

## 1. Which exercises go where

The notes have about 55 exercises. Sorted roughly:

| Kind | Rough count | Examples | Where |
|---|---|---|---|
| Write a function, checkable by tests | ~30 | 1.2, 2.1, 3.1–3.3, 3.5, 4.1, 4.2, 5.2, 5.4, 6.2, 6.4, 6.5, 7.2, 7.5, 7.8, 8.2–8.4, 9.1, 9.4–9.6, 10.3, 11.2, 11.4, 11.5 | **Notes**, auto-checked |
| …and complexity or tail recursion also matters | ~10 of those | 2.1 (iterative power), 3.1 (iterative sum), 3.2 (how efficiently?), 5.2/5.4, 7.8 (linear), 11.2 (`while`, no recursion) | **Notes**, with the extra checks |
| Predict or identify an answer | ~8 | 1.3, 3.4, 4.3 (how do the two `zip`s differ?), 4.6 (parametricity), 6.3 (what does `ftree` do?), 8.1, 11.1, 11.3 | **Notes**, as prediction or counterexample questions |
| Explain, prove, design, compare trade-offs | ~17 | 1.1, 1.4, 2.3, 2.4, 4.4, 4.5, 6.1, 7.3, 7.4, 7.6, 7.7, 9.2, 10.1, 10.2, 10.4 | **Supervisions** |

Mixed cases are often best split. For example, in 5.1 (selection sort's
complexity), the notes have students *measure* it, and the supervision asks
them to *justify* it. In 7.1 (draw the BST), an interactive tree builder could
check the drawing, and the supervision asks why the two insertion orders give
different trees.

What being local-only means:

- There's no record of student progress for staff. That's fine for formative
  exercises, and ticks stay the assessed route.
- Any evaluation of these tools needs data. That would come from lectures
  (polls, quizzes) or an opt-in export, not from telemetry.

Nothing here resists AI. An LLM can solve every exercise in this file. These
are for learning, not assessment (see `AI-NOTES.md`).

---

## 2. How the code is checked

### Don't use a global PPX

x-ocaml-stack's worker applies **every registered `Ast_mapper` to every
phrase in every cell** (`worker/eval.cppo.ml`, `preprocess_phrase`). An
instrumenting PPX would therefore rewrite demo code, helper code and the
student's own interactive experiments as well. That's the wrong granularity.

### Do: rewrite a copy at assessment time

The student's cell runs as normal. When the test cell runs, the checker:

1. gets the **source** of the exercise cell;
2. parses it with compiler-libs, which are already in the worker;
3. applies whatever rewrite the question needs: instrumentation, injected
   `[@tailcall]` attributes, or nothing;
4. **type-checks and evaluates the copy in a fresh, isolated module**, and
   collects warnings and diagnostics;
5. runs tests, counts or checks against it, and reports.

Learn-OCaml works the same way (`Toploop_ext.use_mod_string` on the student's
code; its PPX runs only when exercises are built). Its grading library is a
useful reference for AST checks
([`test_lib.mli`](https://github.com/ocaml-sf/learn-ocaml/blob/master/src/grader/test_lib.mli)),
but it has nothing for complexity or tail calls.

**What x-ocaml-stack would need:**

- a way for a test or hidden cell to read an exercise cell's source by its
  `data-id`;
- a worker function that evaluates a string in an isolated environment with
  chosen warning flags and returns the diagnostics;
- a cap on the work done, so instrumented runs can't hang. The worker can
  already be stopped.

### Check against the typed tree, not the parse tree

Learn-OCaml's checks only look at the untyped syntax, so `let r = List.rev`
or `module L = List` gets around a ban on `List.rev`. If we type-check the
copy and inspect the **Typedtree**, every use resolves to a path such as
`Stdlib.List.rev` and the aliasing trick stops working. That gives us
checks like:

- no `@` allowed;
- must use `while` and no `rec` (11.2);
- `map2` without `map`, using only one recursive function (8.3);
- must be recursive.

---

## 3. Tail recursion

**Method:** rewrite the copy so that **every call to a function in the
enclosing `let rec` group** gets `[@tailcall]`, then compile with warning 51
(`wrong-tailcall-expectation`) as an error. This uses the compiler's own
definition of a tail call. It handles `try … with` (not a tail position),
sequencing, the branches of `match` and `if`, and mutual recursion.

**Checked locally (OCaml 5.4.1 bytecode toplevel):**

```
let rec nsum n = if n = 0 then 0 else n + (nsum [@tailcall]) (n - 1)        (* warning 51 *)
let rec summing n t = if n = 0 then t else (summing [@tailcall]) (n - 1) (n + t) (* fine *)
let rec f n = try … (f [@tailcall]) (n - 1) with Not_found -> 0               (* warning 51 *)
```

Warning 51 is emitted by `Simplif.emit_tail_infos` in the lambda pass, which
bytecode and native share and which the bytecode toplevel calls
([simplif.ml](https://github.com/ocaml/ocaml/blob/5.3/lambda/simplif.ml),
[manual](https://ocaml.org/manual/5.3/attributes.html)). So it should fire in
the js_of_ocaml toplevel too. **This still needs checking in the browser.**

Limits:

- Recursion through higher-order functions (e.g. passing `f` to `List.iter`)
  isn't checked. That's acceptable for FoCS.
- Tail-modulo-cons functions use constant stack without their calls being
  syntactic tail calls. FoCS doesn't teach TMC.
- "Iterative" in FoCS means tail recursive, so `power` (which nests on odd
  exponents) is correctly flagged.

**Don't rely on stack overflow as a test in the browser.** js_of_ocaml turns
self tail calls into loops and uses trampolines for mutual recursion, but
other tail calls aren't optimised
([jsoo tail calls](https://github.com/ocsigen/js_of_ocaml/blob/master/manual/tailcall.mld)).
With effects/CPS, which x-ocaml uses in `x-ocaml.worker+effects.js`, the
behaviour changes again. The lecture demonstration where `nsum 100000`
overflows and `summing` doesn't may behave differently in the browser.
**Needs checking.**

---

## 4. Complexity

**Method: count deterministic operations, not time.** Rewrite the copy so it
counts a cost model (every function-body entry and every `::` built), run it
on inputs of several sizes, and classify the growth. This is trend-prof's
idea of fitting execution counts against input size
([Goldsmith, Aiken, Wilkerson, FSE 2007](https://web.stanford.edu/class/archive/cs/cs295/cs295.1086/papers/trend-prof.pdf)).
Counts are exact, so there's none of the noise that makes timing-based
tools (e.g. Python's [`big_O`](https://github.com/pberkes/big_O)) unreliable.

**Feasibility prototype** (compiler-libs and `Ast_mapper`, native OCaml for
now:
`/private/tmp/claude-501/-Users-jon-devel-focs-slipshow/ba0357bc-a07d-4011-b5c5-80e275911b31/scratchpad/proto/instr.ml`):

```
nrev  counts: 64:4160 128:16512 256:65792 512:262656 1024:1049600
      doubling ratios: 3.97 3.98 3.99 4.00     -> quadratic
rev   counts: 64:130 128:258 256:514 512:1026 1024:2050
      doubling ratios: 1.98 1.99 2.00 2.00     -> linear
```

Design issues:

- **Library calls are invisible.** Without help, `List.rev` and `@` cost
  nothing. In the isolated environment, shadow `List`, `(@)`, `List.length`
  and others with counting versions, and ban escape routes (Array, Hashtbl,
  String tricks) with Typedtree checks.
- **Cost depends on the input.** Insertion sort is linear on sorted input,
  and quicksort is quadratic on it. Each question specifies the input family
  it measures, usually the worst case, and the feedback says which family was
  used.
- **Telling n from n log n:** the doubling ratio is 2.0 vs about 2.1–2.2, and
  with exact counts over a wide enough range of sizes that's separable.
  Fitting the models {1, log n, n, n log n, n², n³, 2ⁿ} with a tolerance is
  sturdier than reading ratios. Exponential growth needs small sizes stepped
  by n+1.
- **Feedback should teach, not just give a verdict.** Show the table and a
  small plot: "when the input doubled, your function did about 4× the work".
  That ties directly to lecture 2, and to the finding that students have
  firm, wrong beliefs about performance (Krishnamurthi et al., Koli 2022).
  Students could then be asked to predict their function's growth *before*
  it's measured.
- **Stack space (an idea to prototype):** use the tail-call analysis to find
  the non-tail recursive call sites, and wrap only those with a depth
  counter. They aren't tail calls, so wrapping them doesn't change their
  behaviour. That gives the maximum recursion depth: O(n) stack for `nsum`,
  O(1) for `summing`.
- **Static analysis isn't practical.** RAML (Hoffmann, Das, Weng, POPL 2017;
  [site](https://www.raml.co/)) infers polynomial bounds, but it targets
  OCaml 4.06, needs Core and a C++ LP solver, has had no release since 2020,
  and doesn't support nested patterns, records or modules. Not worth porting.
- **There's little prior art.** A 2024 systematic review of automated grading
  tools (Messer et al., TOCE,
  [doi:10.1145/3636515](https://doi.org/10.1145/3636515)) doesn't even have
  efficiency as a category. In practice people use timeouts. A
  counting-based checker for complexity class in a CS1 course looks new, and
  could well be publishable.

---

## 5. Question types the checker supports

Each check enables several kinds of question:

| Question type | How it's checked | Notes |
|---|---|---|
| Write the function | tests and properties | the baseline |
| Write it in O(n) / tail-recursively / with `while` | tests + counting / `[@tailcall]` / Typedtree | 2.1, 3.1, 3.2, 7.8, 11.2 |
| **Fix the bug** | tests | Bugs taken from real misconceptions, reusing the Examplar chaffs, so one library of wrong implementations serves both |
| **Fix the complexity** | tests + counting | Correct but O(n²) code (`nrev`, append-heavy traversals) to make linear |
| **Make it tail recursive** | tests + `[@tailcall]` | `nsum` → `summing`, `length` → accumulator version |
| **Find an input that breaks it** | the buggy code and the correct one disagree on it | Cheap, good for testing skills, and Examplar turned inside out. Suits 4.3 (two `zip`s) and 4.4 (`change`'s assumptions) |
| **Write examples first** | Examplar: valid against the correct code, catching the wrong ones | See the earlier Examplar discussion |
| Predict the output or type | compare with the real value or type | 3.4, 4.6, 6.3, 11.3 |

---

## 6. Animations that make the reader predict

### Evidence

- Students who only watched a demonstration did no better than those who
  never saw it. Those who **predicted first** did significantly better
  ([Crouch et al., Am. J. Phys. 2004](https://doi.org/10.1119/1.1707018)).
- How learners engage with a visualisation matters more than what it shows
  ([Hundhausen, Douglas, Stasko 2002](https://doi.org/10.1006/jvlc.2002.0237);
  [Naps et al., ITiCSE WG 2002](https://doi.org/10.1145/960568.782998)).
- In **visual program simulation** (Sorva's UUhistle) students carry out each
  execution step themselves, and the steps are graded
  ([Sorva, Karavirta, Malmi, TOCE 2013](https://doi.org/10.1145/2490822)).
- [PLTutor](https://doi.org/10.1145/3105726.3106178) (Nelson, Xie, Ko, ICER
  2017) is a small study with positive results.
- There's no controlled study of "predict the next step" in a functional
  stepper. That's a gap, and something we could study.

### Ways for the reader to predict, from cheapest to richest

1. **Choose the next state** from options. The distractors come from
   misconceptions, e.g. `rev` building the accumulator in the wrong order.
2. **Click** the answer: which node is visited next, or which element is
   consed onto the accumulator.
3. **Build** the next state by dragging elements into the accumulator or
   queue. This is Sorva's visual program simulation.
4. **Type the next reduction step**, in the notes' notation
   (`nsum 3 ⇒ 3 + nsum 2`). Parse what the student typed and compare it with
   the stepper's next expression *as syntax trees*, so spacing and brackets
   don't matter.

Design rules:

- Don't ask at every step, or it gets tedious. Ask about the first few steps,
  then speed up, then ask only for the final result. Asking less as students
  get better is standard practice in tutoring systems.
- A wrong prediction shows the real step, plus a message aimed at that
  specific misconception, in the spirit of SMoL's refutation texts.

### How states would be generated

- **Data-structure animations** (rev, append sharing, traversals, BFS/DFS
  with a queue, BST path copying): run the real code with instrumentation
  that emits events, using the same rewriting machinery as complexity
  counting.
- **Expression reduction** (nsum vs summing, exceptions unwinding, lazy
  forcing) needs a **stepper**. Existing OCaml work: Furukawa, Cong, Asai,
  "Stepping OCaml" (TFPIE 2018, [arXiv:1906.11422](https://arxiv.org/abs/1906.11422))
  and Asai & Akiyama's algebraic stepper (PEPM 2025). Whether their code is
  available and can be compiled with jsoo is an **open question**. Writing
  our own stepper for the FoCS subset is a substantial project.

---

## 7. Shared parts

These pieces come up again and again, so they should be one library
(`focs-check`) in the worker:

- reading a cell's source, and isolated evaluation that returns diagnostics;
- Typedtree queries (ban or require identifiers and syntax, "must be
  recursive");
- the rewriters: counting instrumentation, `[@tailcall]` injection, depth
  wrapping, and trace events;
- the complexity fitter and the feedback it shows;
- wheats, chaffs and the Examplar harness, plus the counterexample checker;
- one library of wrong implementations, used by Examplar, by the fix-the-bug
  questions and by the tick tests (W1 in `PLAN.md`).

---

## 8. Risks

- jsoo's stack and CPS behaviour differs from native OCaml (§3). Check it
  before relying on any stack-based demonstration.
- Telling n from n log n needs a careful choice of sizes and tolerances.
- Authoring cost: each exercise needs a correct solution, wrong ones, input
  generators and the expected complexity class. Estimated at 30–60 minutes
  per exercise once the library exists, so about 30 exercises is a real but
  manageable amount of work.
- Bundle size and speed: compiler-libs are already in the worker, and
  re-typechecking small cells is cheap. Needs measuring all the same.
- AI: everything here is formative (see `AI-NOTES.md`).

## 9. First prototypes, smallest first

1. **x-ocaml-stack:** read a cell's source plus isolated evaluation with
   diagnostics. Everything else depends on this.
2. **The tail-call check in the browser:** confirm warning 51 fires in the
   jsoo toplevel, then check exercises 2.1 and 3.1.
3. **The complexity counter in the browser:** `nrev` vs `rev`, with the
   counts table and plot as feedback.
4. **One predict-the-step animation:** `rev` with an accumulator, using
   "choose the next state" and "build the next state".
5. **Fix-the-bug and find-the-breaking-input questions**, built from the
   Tick 2 chaffs.
6. Check whether the "Stepping OCaml" code can be compiled with jsoo, before
   deciding whether to build a stepper ourselves.
