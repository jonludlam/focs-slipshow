(* Exercise 4.1 (notes 4.8.1)
   "Sets can be represented in OCaml using lists containing no duplicated
   items ... Using the member function defined above, code a function to
   implement set union. It should avoid introducing repetitions, for
   example the union of the lists [4; 7; 1] and [6; 4; 7] should be
   [1; 6; 4; 7] (though the order does not matter)."

   Tests compare results as sets (order ignored, as the notes say) and check
   there are no repetitions.  Inputs are always sets (no duplicates), as the
   question assumes; what to do with non-set inputs is open (README.md).

   Cost: O(m * n) comparisons for inputs of sizes m and n (member scans ys
   for each element of xs).  Worst-case family: disjoint inputs.  The
   allocation check can't see comparisons, so the complexity is recorded
   here for the browser's Count check (focs-check, task B4) rather than
   tested.

   Decided (D4): the result is compared as a set (any order); inputs are
   sets, so duplicates in the inputs are out of scope; no ban on List.mem /
   List.sort_uniq.  The examples-first version must compare students'
   expected outputs as sets too. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "4.1";
  title = "set union on lists without repetitions";
  question_types = [Write; Fix_the_bug; Examples_first];
  tail_recursion = Not_required;
  complexity = Some {
    time = "O(m n) with member (O(n^2) for equal sizes)";
    space = "O(m) for the new cells";
    family = "disjoint sets: xs = [0..n-1], ys = [n..2n-1] (worst case for \
              member); not yet checked natively";
  };
  placement = Both "writing in the notes; 'why O(mn)? how could sorted \
                    lists do better?' in supervision (link to lecture 5)";
  open_questions = [];
}

let rec member x = function
  | [] -> false
  | y :: l -> if x = y then true else member x l

module type S = sig
  val union : int list -> int list -> int list
end

module Wheat : S = struct
  let rec union xs ys =
    match xs with
    | [] -> ys
    | x :: xs -> if member x ys then union xs ys else x :: union xs ys
end

let chaffs : (module S) chaff list = [
  chaff "just-append"
    "Appends the lists: correct size only when they are disjoint."
    (module struct
      let union xs ys = xs @ ys
    end : S);
  chaff "inverted-test"
    "Keeps x when it IS a member of ys (intersection logic), duplicating it."
    (module struct
      let rec union xs ys =
        match xs with
        | [] -> ys
        | x :: xs -> if member x ys then x :: union xs ys else union xs ys
    end : S);
  chaff "loses-ys"
    "Base case [] -> []: returns xs minus ys (set difference)."
    (module struct
      let rec union xs ys =
        match xs with
        | [] -> []
        | x :: xs -> if member x ys then union xs ys else x :: union xs ys
    end : S);
  chaff "compares-head-only"
    "Compares x only with the head of ys, thinking one comparison suffices."
    (module struct
      let rec union xs ys =
        match xs, ys with
        | [], _ -> ys
        | x :: xs, y :: _ when x = y -> union xs ys
        | x :: xs, _ -> x :: union xs ys
    end : S);
  chaff "stops-early"
    "Copies member's early exit: on finding x in ys it returns ys, \
     forgetting the rest of xs."
    (module struct
      let rec union xs ys =
        match xs with
        | [] -> ys
        | x :: xs -> if member x ys then ys else x :: union xs ys
    end : S);
  chaff "drops-common"
    "Drops elements found in both lists from both: symmetric difference."
    (module struct
      let union xs ys =
        List.filter (fun x -> not (member x ys)) xs
        @ List.filter (fun y -> not (member y xs)) ys
    end : S);
]

let ok xs ys r = no_dups r && same_set r (xs @ ys)

let tests : (module S) test list = [
  test "notes' example" (fun (module M : S) ->
      ok [4; 7; 1] [6; 4; 7] (M.union [4; 7; 1] [6; 4; 7]));
  test "[] and ys" (fun (module M : S) -> same_set (M.union [] [1; 2]) [1; 2]);
  test "xs and []" (fun (module M : S) -> same_set (M.union [1; 2] []) [1; 2]);
  test "disjoint" (fun (module M : S) -> ok [1; 2] [3; 4] (M.union [1; 2] [3; 4]));
  test "equal sets" (fun (module M : S) -> ok [1; 2; 3] [3; 1; 2] (M.union [1; 2; 3] [3; 1; 2]));
  test "common element not at the head" (fun (module M : S) ->
      ok [5] [1; 5; 9] (M.union [5] [1; 5; 9]));
  test "common element, then a new one" (fun (module M : S) ->
      ok [1; 2] [1; 3] (M.union [1; 2] [1; 3]));
]

let () = Harness.run meta (module Wheat : S) chaffs tests
