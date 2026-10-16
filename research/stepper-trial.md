# Trying the Ochanomizu OCaml stepper on FoCS examples

A hands-on follow-up to `research/stepper.md`. I built Asai's stepper
("Stepping OCaml", Furukawa, Cong & Asai) from the 4.14.2 tarball, ran it on
examples from the notes, wrapped it as a library and built that library with
js_of_ocaml. Done on 2026-10-16. Nobody was contacted, and the stepper's
source isn't committed anywhere. It's only in the session scratchpad.

**Verdict: adapt it.** Its semantics are right for FoCS and it already runs
in a browser. What we'd add: a small library wrapper, a step filter and our
own pretty-printer. Before building on it we need answers from Asai on the
licence, on a 5.x port, and on two bugs.

---

## 1. Building it

- I used the tarball from 31 Aug 2025 (sha256 `03d1809f…3e80d`). It was
  already downloaded by the earlier desk research, because
  `pllab.is.ocha.ac.jp` reset the connection from this sandbox. I copied it
  into a fresh directory.
- I read the build files first. `dune` builds one executable from
  `compiler-libs.common` and `compiler-libs.bytecomp`. The only script,
  `make-stepper-list-def.sh`, is a single `cat <<END` that writes the
  4.04 `List` module out as an Emacs Lisp string. Nothing runs at build
  time apart from the compiler.
- `dune build ./main.exe` in the existing `4.14.2` switch worked first time,
  with no warnings shown. That installs nothing into the switch. The binary
  is 9.5 MB.
- How to run it: `stepper file.ml` prints every step ("All" mode).
  `STEPPER_MODE=next|skip|nextitem stepper file.ml` prints one step in the
  format the editor front ends use.

## 2. FoCS examples

In the default mode, each reduction prints two states:

- the **before** state, with the redex marked `[@x]`;
- the **after** state, with the reduct marked `[@t]`.

`(* Application n start/end *)` lines bracket every function call. Only the
current top-level item is printed, as `let r = …`, not the whole program.
OCaml typechecks the program before stepping, so ill-typed programs give the
normal OCaml error.

### nsum 3 (lecture 2), raw output, abridged

```
(* Application 0 start *)
(* Step 0 *)
let r = ((nsum 3)[@x ])
(* Step 1 *)
let r = ((if 3 = 0 then 0 else 3 + (nsum (3 - 1)))[@t ])
(* Step 1 *)
let r = if ((3 = 0)[@x ]) then 0 else 3 + (nsum (3 - 1))
(* Step 2 *)
let r = if ((false)[@t ]) then 0 else 3 + (nsum (3 - 1))
...
(* Step 12 *)
let r = 3 + (2 + (1 + ((nsum 0)[@x ])))
...
(* Step 17 *)
let r = ((3 + 3)[@x ])
(* Step 18 *)
let r = ((6)[@t ])
```

There are 18 steps. Below, the same run is printed through my library
wrapper (§3), with the redex in `{…}`. The full trace is on the left. On the
right is the trace filtered to "states whose redex is a function call":

```
   let r = {(nsum 3)}                                       | --calls:
=> let r = if {(3 = 0)} then 0 else 3 + (nsum (3 - 1))     |    let r = {(nsum 3)}
=> let r = {(if false then 0 else 3 + (nsum (3 - 1)))}     | => let r = 3 + {(nsum 2)}
=> let r = 3 + (nsum {(3 - 1)})                            | => let r = 3 + (2 + {(nsum 1)})
=> let r = 3 + {(nsum 2)}                                  | => let r = 3 + (2 + (1 + {(nsum 0)}))
=> ...                                                     | => let r = 6
=> let r = 3 + (2 + {(1 + 0)})
=> let r = 3 + {(2 + 1)}
=> let r = {(3 + 3)}
=> let r = 6
```

The filtered trace is the one in notes §2.2,
`nsum 3 ⇒ 3 + (nsum 2) ⇒ 3 + (2 + (nsum 1)) ⇒ …`. The only difference is
that the notes stop at `3 + (2 + (1 + 0))`.

### summing 3 0 (lecture 2)

There are also 18 steps. The call-filtered trace is
`summing 3 0 ⇒ summing 2 3 ⇒ summing 1 5 ⇒ summing 0 6 ⇒ 6`, with no
nesting, which is exactly the contrast the lecture wants. The full trace
shows **OCaml's right-to-left argument order**: `summing (3 - 1) {(3 + 0)}`
is reduced before `summing {(3 - 1)} 3`.

### nrev [1;2;3] and rev_app [1;2;3] [] (lecture 3)

These match the eqnarray traces in `slips/lecture3/lecture3.md` almost line
for line. `@` is a single primitive step, as on the slide.

```
nrev (7 steps, raw)                        rev_app (8 steps, call-filtered)
   let r = {(nrev [1; 2; 3])}                 let r = {(rev_app [1; 2; 3] [])}
=> let r = {(nrev [2; 3])} @ [1]           => let r = {(rev_app [2; 3] [1])}
=> let r = ({(nrev [3])} @ [2]) @ [1]      => let r = {(rev_app [3] [2; 1])}
=> let r = (({(nrev [])} @ [3]) @ [2]) @ [1]  => let r = {(rev_app [] [3; 2; 1])}
=> let r = ({([] @ [3])} @ [2]) @ [1]      => let r = [3; 2; 1]
=> let r = {([3] @ [2])} @ [1]
=> let r = {([3; 2] @ [1])}
=> let r = [3; 2; 1]
```

- `nrev` is defined with `function`, so each call takes one step.
- `rev_app` uses `match xs, ys with`, so each call takes two steps: first
  `rev_app [1;2;3] []` becomes `match ([1;2;3], []) with …`, which prints the
  whole match, and then the match picks the second case.
- The slides use symbols, `nrev [a; b; c]`. The stepper needs closed,
  well-typed programs, so use `type sym = A | B | C` instead. That works
  nicely: `append ([A; B; C], [D]) ⇒ A :: append ([B; C], [D]) ⇒ …`.

### preorder on a three-node tree (lecture 7)

```
   let r = {(preorder (Br ("A", (Br ("B", Lf, Lf)), (Br ("C", Lf, Lf)))))}
=> let r = ["A"] @ ((preorder (Br ("B", Lf, Lf))) @ {(preorder (Br ("C", Lf, Lf)))})
=> ... (C's subtree is fully evaluated first) ...
=> let r = ["A"] @ ({(preorder (Br ("B", Lf, Lf)))} @ ["C"])
=> ...
=> let r = ["A"; "B"; "C"]                                     (13 steps)
```

This is correct OCaml, but **it is bad for teaching visiting order.**
Because evaluation is right to left, `preorder t2` runs before
`preorder t1`, so the trace visits C before B. A traversal animation would
need left-to-right evaluation, or a data-structure animation instead of a
stepper.

### change [5;2] 6 with exceptions (lecture 6)

This is the best result. The call-filtered trace (10 of 51 steps) is the
hand trace in notes §6.8, nesting `try` handlers and all:

```
   let r = {(change [5; 2] 6)}
=> let r = try 5 :: {(change [5; 2] 1)} with | Change -> change [2] 6
=> let r = try 5 :: (try 5 :: {(change [5; 2] (-4))} with | Change -> change [2] 1)
           with | Change -> change [2] 6
=> let r = try 5 :: {(change [2] 1)} with | Change -> change [2] 6
=> let r = try 5 :: (try 2 :: {(change [2] (-1))} with | Change -> change [] 1)
           with | Change -> change [2] 6
=> let r = try 5 :: {(change [] 1)} with | Change -> change [2] 6
=> let r = {(change [2] 6)}
=> let r = try 2 :: {(change [2] 4)} with | Change -> change [] 6
=> ... => let r = [2; 2; 2]
```

The full trace shows the exception unwinding one frame at a time, which is
what we'd want to animate:

```
try 5 :: (try {5 :: raise Change} with Change -> change [2] 1) with ...
try 5 :: {(try raise Change with Change -> change [2] 1)} with ...
try 5 :: <change [2] 1> with Change -> change [2] 6
```

The notes trace has a typo that the stepper output exposes: its fourth line,
`5::(change [2] 1) with Change -> change [2] 6`, is missing its `try`.

### get 2 (from 6) with lazy lists (lecture 9)

There are 15 steps. It works with `unit ->` thunks, and closures print with
their free variables already substituted, which is good for teaching:

```
   let r = get 2 {(from 6)}
=> let r = {(get 2 (Cons (6, (fun () -> from (6 + 1)))))}
=> let r = 6 :: (get (2 - 1) {((fun () -> from (6 + 1)) ())})      <- forcing the thunk
=> let r = 6 :: (get (2 - 1) {(from 7)})
=> let r = 6 :: {(get 1 (Cons (7, (fun () -> from (7 + 1)))))}
=> ...
=> let r = 6 :: 7 :: []
```

### Other things I tried

| Program | Result |
|---|---|
| `let y = 3+1 in sq y`, `compose f g 5` (higher-order) | Fine. Beta-reduces `(fun x -> x*2) 5 ⇒ 5 * 2` |
| `"ab" ^ string_of_int (1+2)`, floats, `print_endline` | Fine. Printed text is carried along as `(hi\n)[@stepper.printed]` |
| `insort [3;1;2]` | Fine, 15 steps. Call-filtered, it reads like a textbook trace |
| `List.map f [1;2]` | **Fails** ("not supported in apply") unless the 4.04 `List` source is prepended to the program, which the editor front ends do. With it prepended, it steps through 4.04's `map`, `let r = f a in r :: map f l` |
| Uncaught exception | Steps to `raise (Failure "boom")` and stops cleanly. `failwith` is shown as `raise (Failure …)` from the start |
| **`function` with a `when` guard** (`take`) | **Bug.** The argument disappears from the displayed state (`let r = function … when {2 > 0} -> …`), and the calls are replayed out of order at the end. Writing it as `match p with … when` is better, but it still shows a half-substituted state (`when 2 > 0 -> x :: take (n - 1, xs)`) |
| `while`, `for`, `r.f <- v`, `lazy`/`Lazy.force` | `Fatal error: Failure "not supported …"`, sometimes after printing a few steps |
| Arrays and refs | Work, but they're shown as `#1` locations with a separate `( #1: 2, #2: 1)[@stepper.ref_env]` table |
| `nsum 2000` | 10,003 steps in **40 s**. Each step reprints the whole term, so the cost is quadratic. Irrelevant for lecture-sized examples |
| Infinite loop | Stops at `STEPPER_NUMBER_OF_STEPS`, default 1,000,000. We'd set this low |

### Granularity: is it right for teaching?

- **Each step is one small-step reduction:** a call unfolds to its body, a
  condition becomes `false`, `if false` picks a branch, `3 - 1` becomes
  `2`. That's *finer* than every trace in the notes. Shown raw, nsum's 18
  steps are too many for a slide, but they're fine for a student stepping
  through at their own pace.
- **Filtering gives the notes' traces.** Keeping only the states whose
  redex is a call reproduces the nsum, summing, nrev, rev_app and change
  traces in the notes almost exactly. A predict-the-next-step exercise
  should ask about steps at the filtered level, and offer "show the small
  steps" as an expansion.
- **The stepper itself has only three controls.** *Next* takes one step.
  *Skip* evaluates the current call to its value: `3 + {nsum 2}` becomes
  `3 + <3>`, reported as "Step 17 from Step 4". *Forward* jumps to the
  next top-level item. There's no "only stop at calls to `nsum`" and no
  Hazel-style filters, but the call markers make filters easy to write
  ourselves (§3).
- **It does show the redex,** exactly, and its reduct, with OCaml
  attributes.
- **Differences from how the notes present things:**
  - Arguments are evaluated right to left.
  - A function whose body is a `match` takes two steps per call; one written
    with `function` takes one.
  - `if` takes three steps.
  - The printer adds too many parentheses: `3 + (nsum (3 - 1))`,
    `Br ("A", (Br ("B", Lf, Lf)), …)`, `with | Change ->`, `(-4)`. It breaks
    lines at 80 columns, and everything is wrapped in `let r = …`.
  - Nothing is wrong, but slides want the notes' notation, so we'd use our
    own printer.

## 3. Using it as a library

**Architecture.** `stepper.ml` (3,725 lines) is a big-step evaluator over the
untyped Parsetree. It carries an explicit evaluation context (`cExp_list`).
At every reduction it calls `memo redex reduct context`, which plugs each
of them into the context and **prints** the result.

Three things stop it being a library as it stands:

1. **Output goes to stdout,** through `print_string` and two
   `Format.formatter_of_out_channel stdout`.
2. **It calls `exit 0`** at the end, and after the single step in `next`
   mode.
3. **The mode is read from `Sys.getenv` when the module initialises.** The
   state is in globals: `counter`, `ref_env`, `printed_string` and others.

All of that is easy to get round **without touching the evaluator.** I made a
local patched copy using a short script, `patch.py`:

- I prepended shadowing definitions to `stepper.ml`: `print_string` and
  friends write to a `Buffer`, and `exit` raises `Stepper_exit`. The two
  stdout formatters are replaced by a buffer formatter with **Format
  semantic-tag marks** switched on.
- In `my_pprintast.ml`, an expression whose only attribute is `[@x]` or
  `[@t]` is printed inside a semantic tag (`String_tag "x"`) instead of as
  an attribute. The marks come out as the control characters `\001…\002`
  and `\003…\004`, which **don't count towards Format's line width**. So
  the line breaks are the same as in the clean text, and the span offsets
  are exact.

That's 6 lines changed in `my_pprintast.ml` and 22 lines prepended to
`stepper.ml`. On top of it is a facade of about 100 lines, `focs_stepper.ml`:

```ocaml
type span = { start : int; stop : int }        (* byte offsets *)
type step = { before : string; redex : span;
              after : string; reduct : span;
              call : bool }                    (* follows an "Application n start" *)

val steps : string -> (step list, string) result
(* parse with Parse.implementation, typecheck with My_typemod (patched,
   permits weak type variables), reset the stepper's globals, Stepper.go
   in All mode, catch Stepper_exit, split the buffer at "(* Step n *)"
   headers, pair each [@x] state with the next [@t] state, strip the marks
   to get the spans.  Errors come back as OCaml's own error report. *)
```

The `--calls` traces above come from a 30-line CLI on top of this. FoCS
examples take **1 to 3 ms natively**.

**For a real version, hook `memo` instead of parsing text.** Add a callback,
`on_step : redex:expression -> reduct:expression -> context -> unit`, so the
caller gets **ASTs** rather than strings. That gives us:

- filters on the redex's shape ("calls to `nsum`", "`@` steps", "raise and
  handler"), as in Hazel;
- our own minimal-parentheses printer in the notes' notation;
- comparing a student's typed answer with the right one as syntax trees
  (EXERCISES §6, option 4).

It's about 20 more lines in `stepper.ml`, because `memo_expr`, `next_expr`
and `plug` already have everything needed.

The stepper's own incremental protocol (`next`/`skip`) parses and
typechecks the whole program again at every step, and carries the state as
attributes in the printed source. We don't need it, because one "All" run
produces the whole trace.

## 4. js_of_ocaml build

- **The switch:** a new local one, `scratchpad/stepper/sw`, with
  `ocaml-base-compiler.4.14.2` and js_of_ocaml **6.4.1**, which supports
  4.14.
  - I pinned sedlex 3.7. The sandbox couldn't download sedlex 3.8.1 from
    GitHub, but 3.7 was in the opam download cache.
  - No other network was needed, and no existing switch was touched.
- **The driver:** `steps_js.ml` steps four FoCS programs and one ill-typed
  one, then prints the call-level traces and timings.
  - It sets `Clflags.no_std_include` and puts `/static/cmis` on the include
    path, so the typechecker reads only `.cmi` files embedded with
    `--file` (stdlib, `stdlib__*` and `camlinternal*`, 700 KB). That's
    what a browser worker would need.
  - **It worked first time under node.** The output is the same as the
    native build's, including OCaml's type error message.
- **Blockers: none found.**
  - There's no Unix and there are no C stubs. compiler-libs.common runs fine
    under jsoo.
  - The `getenv`/`exit`/stdout parts are dealt with by the patches in §3.
  - We don't need compiler-libs.bytecomp in JavaScript: it's linked into
    the bytecode, but nothing from it is used, since we don't compile
    anything.

| Measure | Value |
|---|---|
| `steps.js` (`--opt 3`), stdlib cmis embedded | **3.1 MB** (617 KB gzipped) |
| Same, without the cmis | 1.46 MB (358 KB gzipped) |
| node, whole run including start-up | 0.33 s wall time |
| First `steps` call (nsum, 18 steps) | 20 ms |
| `change [5;2] 6` (51 steps), warm | 10 ms each |

Embedding the cmis as JavaScript strings more than doubles their size. We
could fetch them at run time, or embed only `stdlib.cmi` and the few
modules FoCS uses.

## 5. Should we use it, adapt it or write our own?

**Adapt it.**

**For it:**

- The semantics are a good fit for FoCS lectures 2 to 9: substitution,
  closures shown with their values substituted, exceptions unwinding a frame
  at a time through nested handlers, and thunks.
- Real OCaml typechecks the program, and the redex is marked exactly.
- It goes into a jsoo worker with tiny, local changes at about 1.5 MB.
  That's cheaper than writing a stepper.
- Filtering to call steps already reproduces the notes' traces.

**Work we'd own:**

- The library patches and a `memo` hook (small).
- A step filter: start with "calls only" and "calls to f", then maybe
  Hazel-style patterns.
- A printer in the notes' notation.
- A wrapper for the prepended `List`, or just use FoCS's own definitions,
  which is what the course does anyway.

**Against it, or at least unresolved:**

- **Licence.** It's MIT only according to the opam file. There's no public
  repo, some files are LGPL compiler copies, and the `List` module is LGPL.
- **4.14 only.** The x-ocaml cells run 5.x, so this needs a second
  compiler in the page.
- **Right-to-left evaluation,** which spoils traversal-order traces. It's
  hard-coded through `List.rev elist` in `eval_args`, `eval_tuple`,
  `eval_record` and the context frames.
- **The `function` + `when` bug.**
- **No `while`/`for`, mutable fields or `lazy`,** which rules out the
  imperative lectures 10 and 11. Their animations should be data-structure
  ones anyway (ANIMATIONS.md).

Writing our own stepper only makes sense if Asai can't give a clear licence,
or if we need left-to-right evaluation and he doesn't want it. Even then,
his design is the one to copy: a typechecked Parsetree, an evaluator that
carries its context, and `memo` at each redex.

## 6. Questions for Asai, when Jon decides to email

1. **Licence and source.**
   - Is the whole stepper (`stepper.ml` and the patched compiler files)
     available under MIT, plus the LGPL files' own terms?
   - May we vendor a lightly patched copy in a course repository, for
     example a js_of_ocaml worker in the FoCS slides?
   - Is there, or could there be, a public git repository?
2. **OCaml 5.x.** Is a port to the 5.2+ Parsetree, where `Pexp_function`
   was reworked, planned or under way? Is the PEPM 2025 module stepper in
   the same tarball, or a separate code base?
3. **Library API.** Would he take patches that let it be used in-process,
   without forking?
   - Output goes to a formatter or callback instead of stdout.
   - `exit` becomes an exception.
   - The mode is a parameter, not an environment variable.
   - A hook in `memo` passes out the redex, reduct and context as ASTs.
4. **Left-to-right evaluation.** Has he considered an option for it, for
   teaching? FoCS traces such as preorder read left to right.
5. **A bug report.** A `function` with a `when` guard
   (`let rec take = function … | (n, x::xs) when n > 0 -> …`) drops the
   argument from the displayed state and replays the calls out of order at
   the end. With `match … when`, the guard is shown half-substituted.
6. **Step filtering.** Has his group tried showing only some steps, like
   Hazel's filters or "stop only at calls to f"? Has anyone used the stepper
   for *prediction* exercises, where students guess the next step? Any
   classroom data since the 2018 survey would be welcome.
7. **A browser version.** Has anyone built one, perhaps alongside
   ocaml-blockly? We found it builds with js_of_ocaml 6.4.1 at about 3 MB.
8. **Coverage plans** for `while`/`for`, mutable record fields and `lazy`.

---

### Where the trial files are (scratchpad, not committed)

- `…/scratchpad/stepper/src/stepper/` has the extracted tarball, unchanged.
- `…/scratchpad/stepper/work/native/` has the native build.
- `…/scratchpad/stepper/work/ex/` has the example programs and their raw
  `*.out` traces.
- `…/scratchpad/stepper/work/lib/` has the patched copy, `focs_stepper.ml`,
  the `steps` CLI and `jsdrv/steps_js.ml`. `work/scripts/patch.py`
  applies the patches.
- `…/scratchpad/stepper/work/js/steps.js` is the js_of_ocaml build.
- `…/scratchpad/stepper/sw/` is the local opam switch (4.14.2 with jsoo
  6.4.1).
