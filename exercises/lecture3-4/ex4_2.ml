(* Exercise 4.2 (notes 4.8.2)
   "Code a function that takes a list of integers and returns two lists,
   the first consisting of all non-negative numbers found in the input and
   the second consisting of all the negative numbers."

   The notes do say where 0 goes ("non-negative", so the first list), but
   students misread it often enough that it needs a test of its own.  The
   notes don't say whether the order of the input must be kept: order is now
   required (D5 below).

   This follows the lecture's unzip / conspair / revUnzip pattern (building a
   pair of results), so the natural solutions are a recursive one with
   let (ps, ns) = ... in, and an iterative one with two accumulators, which
   reverses the order unless it reverses at the end.

   Decided (D5): each output list must keep the input order, and the
   question says so.  Browser wording adds: "Each list should keep the
   numbers in the order they appear in the input", and puts
   **non-negative** in bold. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "4.2";
  title = "split a list into non-negative and negative numbers";
  question_types = [Write; Fix_the_bug; Examples_first];
  tail_recursion = Not_required;
  complexity = Some {
    time = "O(n)";
    space = "O(n) for the results";
    family = "not tested: every natural solution is linear";
  };
  placement = Notes;
  open_questions = [];
}

module type S = sig
  val split : int list -> int list * int list
end

module Wheat : S = struct
  let rec split = function
    | [] -> ([], [])
    | x :: xs ->
        let ps, ns = split xs in
        if x >= 0 then (x :: ps, ns) else (ps, x :: ns)
end

let chaffs : (module S) chaff list = [
  chaff "zero-negative"
    "Uses x > 0, so 0 goes into the second (negative) list."
    (module struct
      let rec split = function
        | [] -> ([], [])
        | x :: xs ->
            let ps, ns = split xs in
            if x > 0 then (x :: ps, ns) else (ps, x :: ns)
    end : S);
  chaff "swapped"
    "Returns the negatives first."
    (module struct
      let rec split = function
        | [] -> ([], [])
        | x :: xs ->
            let ps, ns = split xs in
            if x < 0 then (x :: ps, ns) else (ps, x :: ns)
    end : S);
  chaff "drops-negatives"
    "Forgets to cons x in the negative branch, returning (ps, ns)."
    (module struct
      let rec split = function
        | [] -> ([], [])
        | x :: xs ->
            let ps, ns = split xs in
            if x >= 0 then (x :: ps, ns) else (ps, ns)
    end : S);
  chaff "classifies-by-head"
    "Decides once from the head and puts the whole list on that side."
    (module struct
      let split = function
        | [] -> ([], [])
        | x :: _ as l -> if x >= 0 then (l, []) else ([], l)
    end : S);
  chaff "acc-reversed"
    "Iterative with two accumulators (like revUnzip) but never reverses, so \
     both lists come out backwards."
    (module struct
      let rec go ps ns = function
        | [] -> (ps, ns)
        | x :: xs -> if x >= 0 then go (x :: ps) ns xs else go ps (x :: ns) xs
      let split l = go [] [] l
    end : S);
  chaff "abs-test"
    "Tests abs x >= 0, which is always true: everything is non-negative."
    (module struct
      let rec split = function
        | [] -> ([], [])
        | x :: xs ->
            let ps, ns = split xs in
            if abs x >= 0 then (x :: ps, ns) else (ps, x :: ns)
    end : S);
]

let as_sets (a, b) = (sort_uniq a, sort_uniq b)

let tests : (module S) test list = [
  test "[]" (fun (module M : S) -> M.split [] = ([], []));
  test "only non-negative" (fun (module M : S) ->
      as_sets (M.split [3; 1; 2]) = ([1; 2; 3], []));
  test "only negative" (fun (module M : S) ->
      as_sets (M.split [-3; -1]) = ([], [-3; -1]));
  test "zero is non-negative" (fun (module M : S) ->
      as_sets (M.split [0; -1]) = ([0], [-1]));
  test "mixed (as multisets)" (fun (module M : S) ->
      let ps, ns = M.split [-2; 5; 0; -7; 5] in
      (List.sort compare ps, List.sort compare ns) = ([0; 5; 5], [-7; -2]));
  test "mixed, order kept" (fun (module M : S) ->
      M.split [-2; 5; 0; -7; 3] = ([5; 0; 3], [-2; -7]));
]

let () = Harness.run meta (module Wheat : S) chaffs tests
