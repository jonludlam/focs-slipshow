(* Exercise 3.2 (notes 3.8.2)
   "Code a function to return the last element of a non-empty list. How
   efficiently can this be done?"

   Answer to "how efficiently": O(n) time (must walk the whole spine) and
   O(1) extra space; the natural recursive definition is already tail
   recursive and allocates nothing. [List.hd (List.rev xs)] is correct but
   allocates a whole reversed copy: O(n) space.  That makes this a natural
   fix-the-complexity question, checked here by allocation.

   Tests use non-empty lists, plus one test that [last []] raises.

   Decided (D1): [last []] must raise some exception; which one is not
   specified. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "3.2";
  title = "last element of a non-empty list";
  question_types = [Write; Fix_the_bug; Fix_the_complexity; Examples_first];
  tail_recursion = Required;  (* natural here; also guards against O(n) stack *)
  complexity = Some {
    time = "O(n)";
    space = "O(1): no allocation, constant stack";
    family = "List.init n Fun.id, allocation compared at n = 1000 and 2000; \
              tail check at n = 10^6";
  };
  placement = Both "writing, the allocation and tail checks in the notes; \
                    'how efficiently, and why can't it be O(1)?' in \
                    supervision";
  open_questions = [];
}

module type S = sig
  val last : int list -> int
end

module Wheat : S = struct
  let rec last = function
    | [x] -> x
    | _ :: xs -> last xs
    | [] -> invalid_arg "last"
end

let chaffs : (module S) chaff list = [
  chaff "returns-head"
    "Confuses the last element with the head (the most easily reached one)."
    (module struct
      let last = function x :: _ -> x | [] -> invalid_arg "last"
    end : S);
  chaff "wrong-clause-order"
    "Puts the general x::xs clause first, so [x] is never reached and the \
     recursion always runs off the end."
    (module struct
      [@@@warning "-11"]
      let rec last = function
        | _ :: xs -> last xs
        | [x] -> x
        | [] -> invalid_arg "last"
    end : S);
  chaff "steps-by-two"
    "Recurses on the tail of the tail, so it works only for odd lengths."
    (module struct
      let rec last = function
        | [x] -> x
        | _ :: _ :: xs -> last xs
        | [] -> invalid_arg "last"
    end : S);
  chaff "nth-length"
    "Uses List.nth xs (List.length xs): off by one, since nth counts from 0."
    (module struct
      let last xs = List.nth xs (List.length xs)
    end : S);
  chaff "second-to-last"
    "Matches [x; _] as the base case, returning the penultimate element."
    (module struct
      let rec last = function
        | [x] -> x
        | [x; _] -> x
        | _ :: xs -> last xs
        | [] -> invalid_arg "last"
    end : S);
  chaff "rev-then-hd"
    "Correct answer but reverses the list first: O(n) extra space \
     (fix-the-complexity)."
    (module struct
      let last xs = List.hd (List.rev xs)
    end : S);
]

let tests : (module S) test list = [
  test "[7]" (fun (module M : S) -> M.last [7] = 7);
  test "[1;2]" (fun (module M : S) -> M.last [1; 2] = 2);
  test "[1;2;3]" (fun (module M : S) -> M.last [1; 2; 3] = 3);
  test "[4;3;2;1]" (fun (module M : S) -> M.last [4; 3; 2; 1] = 1);
  test "repeated values" (fun (module M : S) -> M.last [5; 5; 9] = 9);
  test "[] raises"
    (fun (module M : S) -> raises (fun () -> M.last []));
  test ~kind:Tail "long list (10^6)" (fun (module M : S) ->
      M.last long_list = List.nth long_list 999_999);
  test ~kind:Cost "no allocation" (fun (module M : S) ->
      let xs = List.init 2000 Fun.id in
      alloc_words M.last xs < 100.);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
