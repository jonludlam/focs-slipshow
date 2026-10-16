(* Exercise 4.3 (notes 4.8.3)
   "How does this version of zip differ from the one above?
      let rec zip xs ys =
        match xs, ys with
        | (x::xs, y::ys) -> (x, y) :: zip xs ys
        | ([], [])   -> []"

   Not a write-the-code exercise.  Made checkable as:
   - Find_a_breaking_input: give two lists on which the two zips behave
     differently.  Any pair of different lengths works; equal lengths don't.
     The check runs both functions, so it doesn't depend on a hand-written
     answer key.
   - Predict: which compiler warning does the new version produce (8,
     non-exhaustive match), and what happens at run time on a breaking input
     (Match_failure).  Both are checked against the real compiler/runtime.
   The "which is better?" discussion (silently truncating vs failing loudly
   on unequal lengths; cf. List.combine raising Invalid_argument) belongs in
   supervision. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "4.3";
  title = "the two versions of zip (find a breaking input, predict)";
  question_types = [Find_a_breaking_input; Predict];
  tail_recursion = Not_applicable;
  complexity = None;
  placement = Both "breaking input and predictions in the notes; 'which \
                    behaviour is better, and why does the compiler warn?' \
                    in supervision";
  open_questions = [];
}

let rec zip1 xs ys =
  match xs, ys with
  | (x :: xs, y :: ys) -> (x, y) :: zip1 xs ys
  | _ -> []

let zip2_src = {|
let rec zip2 xs ys =
  match xs, ys with
  | (x::xs, y::ys) -> (x, y) :: zip2 xs ys
  | ([], [])   -> []
|}

[@@@warning "-8"]
let rec zip2 xs ys =
  match xs, ys with
  | (x :: xs, y :: ys) -> (x, y) :: zip2 xs ys
  | ([], []) -> []
[@@@warning "+8"]

module type S = sig
  val breaking_input : int list * int list
  val warning_number : int       (* the compiler warning for zip2 *)
  val runtime_exception : string (* raised by zip2 on a breaking input *)
end

module Wheat : S = struct
  let breaking_input = ([1; 2], [3])
  let warning_number = 8
  let runtime_exception = "Match_failure"
end

let chaffs : (module S) chaff list = [
  chaff "both-empty"
    "Picks the empty case, where the two versions agree."
    (module struct include Wheat let breaking_input = ([], []) end : S);
  chaff "equal-lengths"
    "Gives two lists of the same length, where they agree."
    (module struct include Wheat let breaking_input = ([1; 2], [3; 4]) end : S);
  chaff "unused-case"
    "Thinks the compiler will report an unused match case (warning 11)."
    (module struct include Wheat let warning_number = 11 end : S);
  chaff "invalid-argument"
    "Expects the library behaviour of List.combine: Invalid_argument."
    (module struct include Wheat let runtime_exception = "Invalid_argument" end : S);
  chaff "returns-empty"
    "Thinks unmatched cases just return [] (like the wildcard version)."
    (module struct include Wheat let runtime_exception = "none" end : S);
]

let behaviour f xs ys =
  match f xs ys with
  | r -> Ok r
  | exception e -> Error (Printexc.exn_slot_name e)

let tests : (module S) test list = [
  test "the two zips disagree on the input" (fun (module M : S) ->
      let xs, ys = M.breaking_input in
      behaviour zip1 xs ys <> behaviour zip2 xs ys);
  test "compiler warning" (fun (module M : S) ->
      List.mem M.warning_number (warnings zip2_src));
  test "run-time exception" (fun (module M : S) ->
      let xs, ys = Wheat.breaking_input in
      behaviour zip2 xs ys = Error (squash M.runtime_exception));
]

let () = Harness.run meta (module Wheat : S) chaffs tests
