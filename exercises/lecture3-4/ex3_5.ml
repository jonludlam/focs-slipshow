(* Exercise 3.5 (notes 3.8.5)
   "Code a function tails to return the list of the tails of its argument.
   For example, given [1; 2; 3] it should return
   [[1; 2; 3]; [2; 3]; [3]; []]."

   The example includes both the whole list and [] (so tails [] = [[]]),
   but only by example: see README.md.

   Cost: the result shares structure with the input (each tail *is* a
   suffix of the argument), so a correct definition allocates only the n+1
   outer cons cells: O(n) time and space, although the printed result has
   O(n^2) elements.  A version that copies each tail is correct but
   allocates O(n^2), which the Cost test catches.  Good material for the
   sharing picture in lecture 3 (and a predict-the-allocation question).

   Decided (D3): state it in the question.  Browser wording: "... the list
   of the tails of its argument, including the list itself and the empty
   list." *)

#use "harness.ml";;
open Harness

let meta = {
  id = "3.5";
  title = "tails of a list";
  question_types = [Write; Fix_the_bug; Examples_first; Fix_the_complexity];
  tail_recursion = Not_required;
  complexity = Some {
    time = "O(n)";
    space = "O(n): the tails are shared with the argument, not copied";
    family = "List.init n Fun.id, allocation ratio n = 500 -> 1000 \
              (about 2 when sharing, 4 when copying)";
  };
  placement = Both "writing in the notes; 'why is this O(n) when the \
                    output has n(n+1)/2 elements?' (sharing) in supervision";
  open_questions = [];
}

module type S = sig
  val tails : int list -> int list list
end

module Wheat : S = struct
  let rec tails = function
    | [] -> [ [] ]
    | _ :: xs as l -> l :: tails xs
end

let chaffs : (module S) chaff list = [
  chaff "omits-empty"
    "Base case [] -> [], so the empty tail is missing."
    (module struct
      let rec tails = function
        | [] -> []
        | _ :: xs as l -> l :: tails xs
    end : S);
  chaff "singleton-base"
    "Base case [x] -> [[x]]: omits [] and fails on the empty list."
    (module struct
      let rec tails = function
        | [x] -> [ [x] ]
        | _ :: xs as l -> l :: tails xs
        | [] -> raise (Match_failure ("", 0, 0))
    end : S);
  chaff "skips-whole-list"
    "Conses xs rather than the whole list x::xs, so the argument itself is \
     missing."
    (module struct
      let rec tails = function
        | [] -> [ [] ]
        | _ :: xs -> xs :: tails xs
    end : S);
  chaff "reversed-order"
    "Accumulates the tails but in reverse, shortest first."
    (module struct
      let rec go acc = function
        | [] -> [] :: acc
        | _ :: xs as l -> go (l :: acc) xs
      let tails l = go [] l
    end : S);
  chaff "prefixes"
    "Confuses tails with prefixes: returns [[]; [1]; [1;2]; [1;2;3]]."
    (module struct
      let rec tails = function
        | [] -> [ [] ]
        | x :: xs -> [] :: List.map (fun p -> x :: p) (tails xs)
    end : S);
  chaff "copies-each-tail"
    "Correct result but rebuilds every tail (here with xs @ []), losing \
     sharing: O(n^2) (fix-the-complexity)."
    (module struct
      let rec tails = function
        | [] -> [ [] ]
        | _ :: xs as l -> (l @ []) :: tails xs
    end : S);
]

let tests : (module S) test list = [
  test "notes' example" (fun (module M : S) ->
      M.tails [1; 2; 3] = [[1; 2; 3]; [2; 3]; [3]; []]);
  test "[]" (fun (module M : S) ->
      M.tails [] = [[]]);
  test "[5]" (fun (module M : S) -> M.tails [5] = [[5]; []]);
  test "length n+1" (fun (module M : S) ->
      List.length (M.tails (List.init 10 Fun.id)) = 11);
  test ~kind:Cost "linear allocation (shares tails)" (fun (module M : S) ->
      alloc_ratio ~input:(fun n -> List.init n Fun.id) M.tails 500 < 2.5);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
