(* Exercise 3.3 (notes 3.8.3)
   "Code a function to return the list consisting of the even-numbered
   elements of the list given as its argument. For example, given
   [a; b; c; d] it should return [b; d]."

   "Even-numbered" counts positions from 1 (the example fixes this), which
   clashes with List.nth counting from 0: a known source of confusion, so
   the README suggests restating it as "the 2nd, 4th, 6th, ... elements".

   The specification is polymorphic ('a list -> 'a list).  The checking
   signature is int list -> int list so that the "filter even values" chaff
   type-checks; the tests use values chosen so that position and value
   parity disagree (e.g. [1;2;3;4] would wrongly pass that chaff).

   Decided (D2): keep the notes' wording, and make it an explicit
   examples-first question.  Browser wording: "First write examples that pin
   down what *even-numbered* means; then code the function."  The wheat
   follows the notes' example (1-based: [a;b;c;d] -> [b;d]), and the
   zero-based chaff is the misconception the examples should catch. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "3.3";
  title = "even-numbered elements of a list";
  question_types = [Write; Fix_the_bug; Examples_first; Fix_the_complexity];
  tail_recursion = Not_required;
  complexity = Some {
    time = "O(n)";
    space = "O(n) for the result";
    family = "List.init n Fun.id, allocation ratio n = 2000 -> 4000 \
              (about 2 for O(n), 4 for an acc @ [x] version)";
  };
  placement = Notes;
  open_questions = [];
}

module type S = sig
  val evens : int list -> int list
end

module Wheat : S = struct
  let rec evens = function
    | _ :: x :: xs -> x :: evens xs
    | _ -> []
end

let chaffs : (module S) chaff list = [
  chaff "zero-based"
    "Counts positions from 0, so returns the 1st, 3rd, 5th, ... elements."
    (module struct
      let rec evens = function
        | x :: _ :: xs -> x :: evens xs
        | [x] -> [x]
        | [] -> []
    end : S);
  chaff "even-values"
    "Reads 'even-numbered' as 'even values' and filters on x mod 2 = 0."
    (module struct
      let evens xs = List.filter (fun x -> x mod 2 = 0) xs
    end : S);
  chaff "no-singleton-case"
    "Handles [] and _::x::xs but forgets the one-element list (raises \
     Match_failure on odd lengths)."
    (module struct
      let rec evens = function
        | [] -> []
        | _ :: x :: xs -> x :: evens xs
        | [_] -> raise (Match_failure ("", 0, 0))
    end : S);
  chaff "steps-by-one"
    "Recurses on x::xs instead of xs, so drops only the first element."
    (module struct
      let rec evens = function
        | _ :: x :: xs -> x :: evens (x :: xs)
        | _ -> []
    end : S);
  chaff "acc-reversed"
    "Iterative with an accumulator but forgets to reverse it at the end."
    (module struct
      let rec go acc = function
        | _ :: x :: xs -> go (x :: acc) xs
        | _ -> acc
      let evens xs = go [] xs
    end : S);
  chaff "acc-append"
    "Correct result but builds it with acc @ [x]: O(n^2) \
     (fix-the-complexity)."
    (module struct
      let rec go acc = function
        | _ :: x :: xs -> go (acc @ [x]) xs
        | _ -> acc
      let evens xs = go [] xs
    end : S);
]

let tests : (module S) test list = [
  test "[]" (fun (module M : S) -> M.evens [] = []);
  test "[10]" (fun (module M : S) -> M.evens [10] = []);
  test "[10;20]" (fun (module M : S) -> M.evens [10; 20] = [20]);
  test "[10;20;30]" (fun (module M : S) -> M.evens [10; 20; 30] = [20]);
  test "notes' example as ints" (fun (module M : S) ->
      M.evens [11; 12; 13; 14] = [12; 14]);
  test "parity disagrees" (fun (module M : S) ->
      M.evens [2; 4; 6; 7; 8] = [4; 7]);
  test "length 6" (fun (module M : S) ->
      M.evens [1; 2; 3; 4; 5; 6] = [2; 4; 6]);
  test ~kind:Cost "linear allocation" (fun (module M : S) ->
      alloc_ratio ~input:(fun n -> List.init n Fun.id) M.evens 2000 < 2.5);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
