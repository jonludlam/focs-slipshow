# Exercise specifications: lectures 3–4

Task C3 in `AGENT-TASKS.md`. Each exercise in the notes for lectures 3 and 4
has a file `exN_M.ml` here. Each file contains:

- **metadata** (`meta`): the question types, whether tail recursion is
  required, the complexity class and the input family to measure it on, where
  the exercise belongs (notes or supervision), and any open questions about the
  specification;
- **the wheat**: a reference solution;
- **3–6 chaffs**: wrong implementations, each based on a misconception and
  described in one line;
- **tests**, each tagged as `Spec` (behaviour the question already specifies),
  `Decision` (behaviour that depends on an open choice below), `Tail` or `Cost`.

To check them all, run `exercises/run.sh` (about 10 s). It checks that every
wheat passes all its tests and that every chaff fails at least one, and it
marks any chaff that only the `Decision` tests catch. At the moment it ends
with `ALL OK`. The shared code is in `exercises/harness.ml`, which needs
only OCaml 5.4 with `unix` and `str`.

## How the special checks work natively

The browser versions will use `focs-check` (task B4). Until then, the runner
uses these stand-ins:

- **Tail recursion:** `run.sh` limits the stack (`OCAMLRUNPARAM=l=200000`
  words) and the `Tail` test runs the function on a list of 10⁶ elements.
  Non-tail recursion raises `Stack_overflow`. In the browser this becomes the
  `[@tailcall]` / warning 51 check.
- **Cost:** `alloc_words` / `alloc_ratio` count minor-heap words allocated,
  using `Gc.minor_words`, at sizes n and 2n. For functions that build lists
  this is a deterministic count of cons cells. It catches `List.rev`-then-`hd`
  (3.2), building with `acc @ [x]` (3.3) and copying the tails (3.5). It
  **can't see comparisons**, so 4.1's O(mn) is recorded in the metadata but not
  tested; that needs B4's `Count`.
- **Predictions about types and warnings** (3.4, 4.3, 4.6) are checked
  against the real compiler, by running a separate `ocaml` process, rather
  than against strings written into an answer key.
- **Non-termination:** 4.4(b) uses a fuel counter, not a timeout, so the same
  check will work in a worker. The harness also has a 2-second alarm as a
  backstop against chaffs that loop.

## Summary

| Ex. | Topic | Question types | Tail rec. | Complexity checked | Placement |
|---|---|---|---|---|---|
| 3.1 | `sum`, then iterative `isum` | write, make-tail-recursive, fix-the-bug | `isum`: required | stack only (time is O(n) for both) | notes; "comment on efficiency" in supervision |
| 3.2 | `last` | write, fix-the-bug, fix-the-complexity, examples-first | yes (it comes naturally) | O(1) allocation | notes; "why not O(1) time?" in supervision |
| 3.3 | even-numbered elements | write, fix-the-bug, examples-first, fix-the-complexity | no | O(n) allocation | notes |
| 3.4 | types of `id` and `loop` | predict | n/a | n/a | predictions in notes, explanation in supervision |
| 3.5 | `tails` | write, fix-the-bug, examples-first, fix-the-complexity | no | O(n) allocation (sharing) | notes; "why O(n)?" in supervision |
| 4.1 | set union | write, fix-the-bug, examples-first | no | O(mn), **not tested natively** | notes; cost discussion in supervision |
| 4.2 | split by sign | write, fix-the-bug, examples-first | no | not needed | notes |
| 4.3 | the two `zip`s | find-a-breaking-input, predict | n/a | n/a | notes; "which is better?" in supervision |
| 4.4 | assumptions of `change` | find-a-breaking-input (×2) | n/a | n/a | inputs in notes, assumptions in supervision |
| 4.5 | counting the ways of making change | — (a proof) | — | — | **supervision only**, no file |
| 4.6 | parametricity: `f`, `g` | predict | n/a | n/a | predictions in notes, reasons in supervision |

There is no file for 4.5. It asks for a proof (O(n) ways with two coin values,
and how this generalises). A *measure-it* version would be possible, counting
`List.length (all_ways [2;1] n)` for growing n and having students predict the
growth first. That would make a good supervision warm-up, but it needs the
B4 growth fitter to give feedback.

## Observations from writing the chaffs

- **3.3:** the "even values" chaff (`List.filter (fun x -> x mod 2 = 0)`)
  passes the obvious test `[1;2;3;4] → [2;4]`. The tests use values whose
  parity disagrees with their position. This makes a good examples-first
  question, because students' own examples will often have exactly this
  weakness.
- **3.2, 3.3, 3.5:** each has a chaff whose output is correct and which only
  the cost check catches. These are the fix-the-complexity questions:
  `List.hd (List.rev xs)`, `acc @ [x]`, and `l @ []` (which copies each tail).
  3.5 is a good way to teach sharing: the printed result has n(n+1)/2
  elements, yet a correct `tails` allocates only n+1 cons cells.
- **4.1:** `just-append` behaves the same as several "checks the wrong list"
  variants on set inputs, so only distinct behaviours were kept.
- **4.2:** the iterative two-accumulator solution (built like the lecture's
  `revUnzip`) is wrong *only* if order matters. See D5.
- **3.4 and 4.6** don't ask for code. The "chaffs" there are wrong answers,
  each from a named misconception, so they can serve as multiple-choice
  distractors with targeted feedback.

## Decisions (made by Jon, 2026-10-16)

The former `Decision` tests are now ordinary `Spec` tests.

| | Question | Decision |
|---|---|---|
| D1 | 3.2: what does `last []` do? | It must raise **some** exception; which one is not specified. |
| D2 | 3.3: "even-numbered" counts from 1 | Keep the wording and make it an explicit **examples-first** question: "First write examples that pin down what *even-numbered* means." |
| D3 | 3.5: is `[]` a tail? | **State it** in the question: "including the list itself and the empty list". |
| D4 | 4.1: order, duplicate inputs, `member` | Compare as sets. Duplicate inputs are out of scope. No ban on `List.mem`. |
| D5 | 4.2: keep input order? | **Yes**, and the question says so. **Non-negative** goes in bold. |
| D6 | 4.4(b): input that runs forever | Keep it in the notes, but run it **in its own worker**, so a non-terminating experiment can be stopped without losing the page. Needs an x-ocaml feature. |
| D7 | 4.6: the caveat | State explicitly: "assume both calls return normally (no exception, no infinite loop)". |
| D8 | 3.1: is `List.fold_left` allowed? | **No library functions.** Checked on the source by `Harness.uses_library`, which shadows `List`, `Array`, `Seq`, `Option`, `Fun`, `String`, `Hashtbl` and `Stdlib` itself (so `Stdlib.List.fold_left` is caught too). Operators opened by default (`+`, `=`, `@`, `failwith`) stay available. In the browser this becomes a Typedtree path check. 3.1 now has `fold-left` and `stdlib-qualified` chaffs that only the ban catches. |

To ban library functions in another exercise, pass
`~no_library:wheat_src` to `Harness.run` and give the relevant chaffs a
`~src`.
