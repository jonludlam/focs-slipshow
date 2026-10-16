(* Harness for exercise specification files.

   Each exercise file (e.g. lecture3-4/ex3_2.ml) does
     #use "harness.ml";;
   then defines a module type [S], a reference solution [Wheat : S], a list of
   chaffs (wrong implementations of [S], each with a one-line description), a
   list of tests over [(module S)], and calls [Harness.run].

   The runner (run.sh) runs each file in its own toplevel process with a small
   stack limit (OCAMLRUNPARAM=l=...), so a non-tail-recursive function
   overflows on a long list while a tail-recursive one does not. That is the
   native stand-in for the [@tailcall] / warning 51 check planned for the
   browser (EXERCISES.md section 3).

   A file passes when the wheat passes every test and every chaff fails at
   least one test.  Everything here is plain OCaml 5.4 plus Unix (for a
   timeout), so that it can later be moved into the browser checker. *)

#directory "+unix";;
#load "unix.cma";;
#directory "+str";;
#load "str.cma";;

module Harness = struct
  (* ---------------------------------------------------------------- *)
  (* Metadata                                                           *)

  type question_type =
    | Write              (* write the function from the specification *)
    | Fix_the_bug        (* given a chaff, fix it *)
    | Fix_the_complexity (* given correct but too-slow code, fix it *)
    | Make_tail_recursive
    | Find_a_breaking_input
    | Examples_first     (* Examplar: write tests that catch the chaffs *)
    | Predict            (* predict a value, type or behaviour *)

  type tail_recursion =
    | Required           (* checked: must survive a long input on a small stack *)
    | Not_required
    | Not_applicable

  type placement =
    | Notes              (* auto-checked in the browser notes *)
    | Supervision
    | Both of string     (* split: the string says which part goes where *)

  type complexity = {
    time : string;
    space : string;      (* extra space, counting the stack *)
    family : string;     (* input family the measurement uses *)
  }

  type meta = {
    id : string;                    (* "3.2" *)
    title : string;
    question_types : question_type list;
    tail_recursion : tail_recursion;
    complexity : complexity option;
    placement : placement;
    open_questions : string list;   (* spec decisions for Jon; see README.md *)
  }

  (* ---------------------------------------------------------------- *)
  (* Tests and chaffs                                                   *)

  (* [Spec]: behaviour the notes' question already specifies.
     [Decision d]: behaviour that depends on an open spec decision [d];
       listed separately so Jon can see which chaffs only those tests catch.
     [Tail]: the tail-recursion check (long input, small stack).
     [Cost]: an allocation-growth check (see [alloc_words]). *)
  type kind = Spec | Decision of string | Tail | Cost

  type 'm test = { name : string; kind : kind; check : 'm -> bool }

  let test ?(kind = Spec) name check = { name; kind; check }

  type 'm chaff = { cname : string; desc : string; impl : 'm }

  let chaff cname desc impl = { cname; desc; impl }

  (* ---------------------------------------------------------------- *)
  (* Running a single check safely                                      *)

  exception Timeout

  let () = Sys.set_signal Sys.sigalrm (Sys.Signal_handle (fun _ -> raise Timeout))

  type outcome = Pass | Fail | Raised of string

  let run_check ?(seconds = 2) check impl =
    ignore (Unix.alarm seconds);
    let r =
      try if check impl then Pass else Fail with
      | Timeout -> Raised "timeout"
      | Stack_overflow -> Raised "Stack_overflow"
      | e -> Raised (Printexc.to_string e)
    in
    ignore (Unix.alarm 0);
    r

  (* ---------------------------------------------------------------- *)
  (* Helpers for writing tests                                          *)

  (* Does [f ()] raise some exception?  (Used where the spec says
     "must fail", without fixing which exception.) *)
  let raises f = match f () with _ -> false | exception Timeout -> raise Timeout
                                             | exception _ -> true

  (* Words allocated on the minor heap by [f x].  Lists are built cell by
     cell, so this counts cons cells (3 words each) and tuples: a cheap,
     deterministic cost measure for list-building functions.  The input [x]
     must be built before calling this. *)
  let alloc_words f x =
    let w0 = Gc.minor_words () in
    ignore (Sys.opaque_identity (f x));
    Gc.minor_words () -. w0

  (* Ratio of allocation when the input size doubles from [n] to [2n].
     About 1 for O(1) allocation (both tiny), 2 for O(n), 4 for O(n^2). *)
  let alloc_ratio ~input f n =
    let a = alloc_words f (input n) and b = alloc_words f (input (2 * n)) in
    (b +. 1.) /. (a +. 1.)

  (* Long list for the tail-recursion check.  With the runner's stack limit
     (l=200000 words), any non-tail recursion over this list overflows. *)
  let long_list = List.init 1_000_000 (fun i -> i mod 7 - 3)

  let sort_uniq l = List.sort_uniq compare l
  let same_set a b = sort_uniq a = sort_uniq b
  let no_dups l = List.length (sort_uniq l) = List.length l

  (* Does an OCaml source snippet type-check?  Runs a separate toplevel, so
     that "this should be a type error" can be tested.  Used by predict
     questions (e.g. 4.6). *)
  let typechecks src =
    let file = Filename.temp_file "focs_tc" ".ml" in
    let oc = open_out file in
    output_string oc src;
    close_out oc;
    let cmd = Printf.sprintf "ocaml -noprompt %s > /dev/null 2>&1" (Filename.quote file) in
    let ok = Sys.command cmd = 0 in
    Sys.remove file;
    ok

  (* The types the interactive toplevel prints for each phrase of [src]
     (phrases separated by ";;"), e.g. ["'a -> 'a"; "int list list"].
     Used to check type predictions against the real type checker. *)
  let toplevel_types src =
    let file = Filename.temp_file "focs_ty" ".ml" in
    let out = Filename.temp_file "focs_ty" ".out" in
    let oc = open_out file in
    output_string oc src;
    close_out oc;
    ignore (Sys.command (Printf.sprintf
              "ocaml -noprompt -noinit -color=never < %s > %s 2>&1"
              (Filename.quote file) (Filename.quote out)));
    let ic = open_in out in
    let lines = ref [] in
    (try while true do lines := input_line ic :: !lines done
     with End_of_file -> ());
    close_in ic;
    Sys.remove file; Sys.remove out;
    let re = Str.regexp "^\\(- \\|val [^ ]+ \\): \\(.*\\) = " in
    List.rev !lines
    |> List.filter_map (fun l ->
           if Str.string_match re l 0 then Some (Str.matched_group 2 l) else None)

  (* Normalise whitespace in a predicted type or value. *)
  let squash s =
    String.concat " " (String.split_on_char ' ' (String.trim s)
                       |> List.filter (( <> ) ""))

  (* Compiler warnings (numbers) produced by a snippet. *)
  let warnings src =
    let file = Filename.temp_file "focs_w" ".ml" in
    let out = Filename.temp_file "focs_w" ".out" in
    let oc = open_out file in
    output_string oc src;
    close_out oc;
    ignore (Sys.command (Printf.sprintf "ocaml -noprompt %s > %s 2>&1"
                           (Filename.quote file) (Filename.quote out)));
    let ic = open_in out in
    let n = in_channel_length ic in
    let s = really_input_string ic n in
    close_in ic;
    Sys.remove file; Sys.remove out;
    let re = Str.regexp "Warning \\([0-9]+\\)" in
    let rec go pos acc =
      match Str.search_forward re s pos with
      | p -> go (p + 1) (int_of_string (Str.matched_group 1 s) :: acc)
      | exception Not_found -> List.rev acc
    in
    go 0 []

  (* ---------------------------------------------------------------- *)
  (* The main entry point                                               *)

  let kind_label = function
    | Spec -> "" | Decision d -> " [decision: " ^ d ^ "]"
    | Tail -> " [tail]" | Cost -> " [cost]"

  let failures = ref 0

  let run (meta : meta) (wheat : 'm) (chaffs : 'm chaff list) (tests : 'm test list) =
    Printf.printf "== Exercise %s: %s\n" meta.id meta.title;
    (* The wheat must pass every test. *)
    List.iter
      (fun t ->
        match run_check t.check wheat with
        | Pass -> ()
        | Fail ->
            incr failures;
            Printf.printf "  WHEAT FAILS %s%s\n" t.name (kind_label t.kind)
        | Raised e ->
            incr failures;
            Printf.printf "  WHEAT RAISES %s on %s%s\n" e t.name (kind_label t.kind))
      tests;
    (* Every chaff must fail at least one test. *)
    List.iter
      (fun c ->
        let caught =
          List.filter_map
            (fun t ->
              match run_check t.check c.impl with
              | Pass -> None
              | Fail -> Some (t.name ^ kind_label t.kind)
              | Raised e -> Some (t.name ^ kind_label t.kind ^ " (" ^ e ^ ")"))
            tests
        in
        match caught with
        | [] ->
            incr failures;
            Printf.printf "  CHAFF NOT CAUGHT %s: %s\n" c.cname c.desc
        | _ ->
            let only_decision =
              List.for_all
                (fun t ->
                  match t.kind with
                  | Decision _ -> true
                  | _ -> run_check t.check c.impl = Pass)
                tests
            in
            Printf.printf "  chaff %-22s caught by %d: %s%s\n" c.cname
              (List.length caught)
              (String.concat "; " (List.filteri (fun i _ -> i < 3) caught)
               ^ if List.length caught > 3 then "; ..." else "")
              (if only_decision then "  <-- only by decision tests" else ""))
      chaffs;
    Printf.printf "  %d tests, %d chaffs: %s\n%!" (List.length tests)
      (List.length chaffs)
      (if !failures = 0 then "OK" else "PROBLEMS");
    if !failures <> 0 then exit 1
end
