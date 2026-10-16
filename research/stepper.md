# Notes: an OCaml stepper for FoCS

Can we show students OCaml evaluating one reduction step at a time, in the
browser, next to the x-ocaml cells? These notes cover the existing OCaml
stepper from Ochanomizu (Asai's group): where its code is, its licence, the
OCaml version it needs, how it works, and whether it would compile with
js_of_ocaml. They also cover two steppers worth borrowing design ideas from,
Hazel's and DrRacket's.

The Ochanomizu source was downloaded and read on 2026-10-16, but not built.

---

## The Ochanomizu OCaml Stepper (Asai and others)

### Papers

- Furukawa, Cong & Asai, **"Stepping OCaml"**, TFPIE 2018; EPTCS 295
  (2019), pp. 17–34. [arXiv:1906.11422](https://arxiv.org/abs/1906.11422),
  [DOI 10.4204/EPTCS.295.2](https://doi.org/10.4204/EPTCS.295.2).
- Asai & Akiyama, **"Algebraic Stepper for Simple Modules"**, PEPM 2025,
  pp. 13–29.
  [Programme entry](https://popl25.sigplan.org/details/pepm-2025-papers/3/Algebraic-Stepper-for-Simple-Modules).
  It adds `module` structures with hierarchical names such as `M.N.x`, but
  no functors or signature sealing. Every top-level `let` (one without
  `in`) gets a "level", which keeps references correct after substitution.
  Substitution of variables is delayed, and the paper proves the stepper
  agrees with the standard small-step semantics. *Only the abstract and
  listing were read; the full text wasn't available openly.*
- An earlier paper: Cong & Asai, "Implementing a stepper using delimited
  continuations", SCSS 2016.

### Where the code is

- Project page: <http://pllab.is.ocha.ac.jp/~asai/Stepper/> (created
  March 2025).
- Source tarballs, which are the opam pin targets:
  - [4.14.2 (current)](http://pllab.is.ocha.ac.jp/~asai/Stepper/4.14.2/stepper.tar.gz).
    The copy read for these notes was dated 31 Aug 2025.
  - [4.12.0](http://pllab.is.ocha.ac.jp/~asai/Stepper/4.12.0/stepper.tar.gz),
    no longer maintained.
- **There's no public git repository for the stepper itself.** The tarball
  is the only source.
- Front end: the VS Code extension
  [kenichi-asai/ocha-platform](https://github.com/kenichi-asai/ocha-platform)
  (MIT). It has Start, Prev, Next, Skip, Forward ("next toplevel
  definition, such as the next test case") and End buttons. It needs
  [kenichi-asai/expand-open](https://github.com/kenichi-asai/expand-open)
  (MIT), which expands `open`ed module names. The tarball still includes an
  older Emacs front end, `stepper.el`.
- Also worth knowing about:
  - [kenichi-asai/toplevel-experiment](https://github.com/kenichi-asai/toplevel-experiment)
    (LGPL-2.1, updated Jun 2026), "experiment for creating toplevel using
    compiler-libs". *Not looked at.*
  - [kenichi-asai/ocaml-blockly](https://github.com/kenichi-asai/ocaml-blockly)
    (Apache-2.0), a visual editor. It's separate from the stepper.

### Licence

- `stepper.opam` says **MIT**. The tarball has no LICENSE file, and the
  stepper's own files have no headers.
- Four of the files are lightly patched copies of OCaml compiler sources,
  which keep their headers: **LGPL-2.1 with the OCaml linking exception**.
  They are `my_typemod.ml`, `my_pprintast.ml`, `my_compile*.ml` and
  `my_maindriver.ml`.
- The step-through `List` module is copied from the OCaml 4.04 stdlib
  (LGPL).
- That mix is fine to use, but *we should ask Asai before redistributing or
  forking it*: the licence is only stated in the opam file, and there's no
  public repo.

### OCaml version

- **Only OCaml 4.14.2.** The ocha-platform README says "The OCaml Stepper
  supports only OCaml version 4.14.2".
- It builds with dune and depends only on `compiler-libs.common` and
  `compiler-libs.bytecomp`.

### Architecture (from reading the source)

About 9,100 lines in total. `stepper.ml` is 3,725 lines, and most of the
rest is copied compiler code.

- **It is a modified `ocamlc` driver.**
  - `my_maindriver.ml` is 4.14.2's `driver/maindriver.ml`, changed to call
    `My_compile`.
  - `My_compile_common.implementation` parses the file with the normal
    parser (`Pparse`), and **typechecks it with the real OCaml typechecker**
    (`My_typemod.type_implementation`).
  - It then **throws the Typedtree away** and calls
    `Stepper.go parsed` on the **untyped Parsetree**.
  - So type errors come straight from OCaml, and the stepper only ever sees
    well-typed programs.
- **The typechecker patch is one line.**
  - `my_typemod.ml` is identical to 4.14.2's `typing/typemod.ml`, except
    that it comments out `check_nongen_signature`.
  - That allows weak type variables at the top level of a compilation
    unit, such as `let r = ref []`. Intermediate programs like that come up
    when a step's output is stepped again.
- **The evaluator works on the Parsetree.** It is a big-step interpreter
  over `Parsetree` that carries an explicit evaluation context, as in the
  paper:
  - One level of context is the frames inside the current `try`, and the
    other is the enclosing `try` handlers.
  - At every reduction, a `memo` function plugs the redex and its result
    back into the context, and prints the whole program before and after.
  - It evaluates right to left, like OCaml.
- **Each step is a separate process.**
  - The output is OCaml source text. The redex and its result are marked
    with attributes (`[@stepper.redex]` and similar), so the front end can
    highlight them.
  - The state needed to continue (step counter, contents of the `ref`
    cells, text printed so far) is also printed into the source, as
    attributes such as `[@@@stepper.counter n]`, `[@stepper.ref_env]` and
    `[@stepper.printed]`.
  - To take the next step, the front end saves the "after" program to a
    file and runs `env STEPPER_MODE=next stepper tmp.ml` again
    (`emacs-memo.txt`, `ocha-platform/src/step.ts`). So every step parses
    and typechecks the whole program again.
  - The modes are `next`, `skip` and `nextitem`, or `all`, which prints
    every step. They are read with `Sys.getenv`, and the program ends with
    `exit 0`.
  - There's a cap of 1,000,000 steps (`STEPPER_NUMBER_OF_STEPS`).
- **Skip** runs the current function application to its result without
  showing its steps.
- **Library functions are stepped from source.** `List` is a source copy
  that's put in front of the program, so `List.map f l` really unfolds
  step by step.
- **What it supports:**
  - Supported:
    - integers, floats, booleans, characters and strings;
    - lists, tuples, records and user-defined datatypes;
    - `if`, `let`, `let rec`, `match` (including `when` guards) and
      exceptions;
    - `print_*` and sequencing;
    - refs and arrays;
    - simple modules and `List`.
  - Not supported, from `failwith "not supported ..."` in the source:
    - `while` and `for` (partly);
    - `lazy`;
    - mutable record fields (`<-`);
    - functors, objects, GADTs and effects;
    - polymorphic variants, interval and array patterns, and `assert` in
      some positions.
  - The project page says it does not support "imperative features", while
    also listing references. *What "imperative" covers isn't clear.*
- **Classroom use:**
  - It has been used since 2016 in a second-year OCaml course of about 40
    students at Ochanomizu.
  - In 2018, 38 students were surveyed. The average usefulness score was
    2.3 out of 4. 16 students said it helped them find bugs when tests
    failed, 5 said it helped them see how recursion consumes lists, and 3
    used it to find non-termination.
  - Use peaked in weeks 1–5, the recursion and lists material, which is
    exactly FoCS lectures 2–4.

### Could it run in a browser worker with js_of_ocaml?

**Probably, with modest work, if we stay on 4.14.**

- **The libraries are all ones that already work in the browser.** It needs
  only compiler-libs.common and compiler-libs.bytecomp, which
  js_of_ocaml-toplevel and x-ocaml already run in a worker.
  - There's no `Unix` and no C stubs.
  - The only system calls are `Sys.getenv`, `exit`, writing to stdout, and
    reading the source file named on the command line. js_of_ocaml can
    provide all of them: a pseudo-filesystem via `Sys_js.create_file`, a
    stdout flusher via `Sys_js.set_channel_flusher`, and `exit` turned into
    an exception.
  - A cleaner port would replace `getenv` and `exit` in `stepper.ml` with
    an API like `step : mode -> string -> string`. That's a small, local
    change.
- **The typechecker needs the stdlib `.cmi` files** in the worker's
  pseudo-filesystem. x-ocaml already embeds these for its toplevel.
- **Speed:** retypechecking each step should be fine for the programs in
  FoCS lectures, which are tiny. *Not measured.*
- **The main obstacle is the version mismatch.** x-ocaml runs OCaml 5.x,
  and the stepper uses the 4.14 Parsetree and copies of 4.14 compiler code.
  There are three options:
  1. **A separate stepper worker built from a 4.14.2 switch**, keeping its
     own 4.14 typechecker and stdlib `.cmi` files. This is the least work.
     The cost is a second compiler in the page, roughly a few MB of
     JavaScript (*size not measured*), and that the 4.14 typechecker might
     accept or reject a program slightly differently from the 5.x cells.
     *Which js_of_ocaml versions still support 4.14 needs checking before
     relying on this.*
  2. **Port `stepper.ml` to the 5.4 Parsetree.** Function syntax was
     reworked in 5.2 (`Pexp_fun` was folded into `Pexp_function`), and
     there are other smaller changes since 4.14. `stepper.ml` matches on
     `Pexp_fun` and `Pexp_function` in about 34 places. You'd also re-copy
     5.4's `typemod.ml` with the same one-line patch, or use the toplevel's
     typechecker, which doesn't check for non-generalised types anyway.
     That's a real porting job, maybe days rather than hours, and the
     result would be ours to maintain.
  3. **Typecheck with x-ocaml's own 5.4 typechecker, then convert the
     Parsetree down to 4.14** using ppxlib's Astlib migrations, and run the
     unchanged 4.14 `stepper.ml` and `my_pprintast.ml` against the
     converted tree. *Untested idea.* Down-migration fails on 5.x-only
     syntax, which FoCS programs don't use.
- **Output:** each step is printed OCaml source with attributes marking
  the redex and its result. Turning that into highlighted HTML in a slip
  means parsing it again, or a small change to `my_pprintast.ml` to print
  markers.
- **Language coverage for FoCS:**
  - Fine for lectures 1–6 (recursion, lists, sorting, datatypes, trees,
    higher-order functions) and for exceptions.
  - Lazy lists work if they're written with explicit `unit ->` thunks, as
    FoCS does, rather than `lazy`.
  - Refs and arrays work, but `for` and `while` loops and mutable records
    don't, and neither do functors. That rules out the later imperative and
    module lectures.

---

## Design references

### Hazel stepper (Fei, Keenan & Omar, 2026)

- "Practical Algebraic Stepping with Scoped Filters",
  [arXiv:2605.31517](https://arxiv.org/abs/2605.31517) (May 2026, preprint).
- **The UI:**
  - Every available redex is highlighted, and the user **clicks the one to
    reduce**. The expression is rewritten in place.
  - A history panel expands to show the full trace, one line per step.
- **A step** is one small substitution-based reduction. Hazel's evaluator
  is environment-based, so the authors had to reconcile it with the
  substitution style students see in lectures. Programs with holes and
  type errors can be stepped too.
- **Skipping and abstraction come from filters written into the program**,
  which match the shape of a redex using Hazel patterns plus `$e` and `$v`
  wildcards:
  - `debug hide(p)` and `debug stop(p)` hide or show one matching step;
  - `debug eval(p)` and `debug step(p)` hide or show all the steps inside a
    matching subexpression;
  - when filters are nested, the innermost one decides.
  - Example: `debug eval($e)` with `debug stop(fac($v))` turns a factorial
    trace into just its recursive calls.
- The semantics are proved correct and mechanised in Agda. There's also a
  standalone reference stepper in OCaml, about 560 lines, for the simply
  typed lambda calculus with fixpoints and filters.
- **Used in** a university programming languages course. Of 25 survey
  respondents, 20 used the stepper. Students took to it readily, but
  advanced filters needed more teaching. **Instructors used filters to
  prepare focused traces for lectures**, which is the use FoCS slips would
  want.
- Hazel itself is OCaml compiled with js_of_ocaml and runs in the browser.
  But it steps the Hazel language, not OCaml.
- A related repo, [tonyfettes/stepper](https://github.com/tonyfettes/stepper)
  ("Hazel Mini Stepper", MIT, OCaml 5.1.1 plus a Vite web front end).
  *Not examined.*

### DrRacket stepper (Clements, Flatt & Felleisen, ESOP 2001)

- "Modeling an Algebraic Stepper", ESOP 2001
  ([DOI 10.1007/3-540-45309-1_21](https://doi.org/10.1007/3-540-45309-1_21));
  [DrRacket stepper docs](https://docs.racket-lang.org/stepper/).
- **The UI** shows two panes, before and after. The redex is highlighted
  green on the left and its result purple on the right, and the whole
  program is shown at every step. You move backwards and forwards through
  the steps, and can jump to selected points.
- **A step** is one reduction in the teaching languages' small-step
  semantics, which are built on substitution. Definitions at the top level
  stay as definitions, and values print in the student-language syntax.
- **How it works:** it annotates the program with continuation marks to
  rebuild the evaluation context, breaks at every reduction, and
  reconstructs the program from the marks. It's proved consistent with the
  reduction semantics. Asai's stepper does the same thing with explicit
  context arguments.
- **Abstraction:** it works only in the How to Design Programs teaching
  languages. Library code is opaque, and later versions add jumping to
  steps that satisfy a condition. *Its finer-grained skip options weren't
  checked.*

---

## Recommendation for FoCS

1. **Start with option 1 as a proof of concept:** a separate js_of_ocaml
   worker built from the unchanged 4.14.2 stepper tarball.
   - Wrap `Stepper.go` behind a pure `string -> mode -> string` interface,
     and set the pseudo-filesystem up as x-ocaml does.
   - Check it on `nrev`/`rev`, `nsum`/`summing`, `take`/`drop` and
     insertion sort.
   - That would show in a day or two whether output quality and speed are
     good enough. The existing 4.14.2 switch can build it without changing
     the opam setup, but *check with Jon before building anything*.
2. **Email Asai first.** We'd be asking for a public repo or explicit
   permission to fork, and whether a 5.x port exists or is planned. The
   group actively maintains the stepper and uses it in a course like FoCS.
3. **For slips, prefer prepared traces to free-form stepping.**
   - Hazel's lesson is that instructors want to choose which steps appear.
   - With Asai's stepper, the nearest equivalents are Skip and "next
     item". A slip could run the stepper ahead of time, or in the worker,
     and keep only the steps that match a simple filter, such as calls to a
     named function.
   - This fits B6, the predict-the-step animation, which needs a sequence
     of states with wrong options shown alongside.
4. **Only consider porting to the 5.4 Parsetree (option 2 or 3)** if the
   proof of concept is worth keeping and running two compilers is a
   problem.
