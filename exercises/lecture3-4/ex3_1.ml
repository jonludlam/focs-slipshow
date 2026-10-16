(* Exercise 3.1 (notes 3.8.1)
   "Code a recursive function to compute the sum of a list's elements. Then
   code an iterative version and comment on the improvement in efficiency."

   Two parts, checked separately:
   - [sum]: any correct recursive definition.
   - [isum]: must be iterative, i.e. tail recursive (FoCS's meaning of
     "iterative"; cf. [summing] in lecture 2 and [addlen] in 3.4).
   The "comment on the improvement" part is for the supervision: both are
   O(n) time; the gain is O(n) -> O(1) stack space, not time.

   Decided (D8): library functions are not allowed, so the point (learning
   the accumulator pattern) is not sidestepped with List.fold_left.  Checked
   on the source with [Harness.uses_library]; in the browser, a Typedtree
   path check. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "3.1";
  title = "sum of a list, recursive and iterative";
  question_types = [Write; Make_tail_recursive; Fix_the_bug];
  tail_recursion = Required;  (* for isum only *)
  complexity = Some {
    time = "O(n) for both";
    space = "sum: O(n) stack; isum: O(1)";
    family = "List.init n (fun i -> i mod 7 - 3); tail check at n = 10^6 \
              on a 200k-word stack";
  };
  placement = Both "writing and the tail-recursion check in the notes; \
                    'comment on the improvement in efficiency' (time vs \
                    space) in supervision";
  open_questions = [];
}

module type S = sig
  val sum : int list -> int
  val isum : int list -> int
end

(* The wheat's source, checked against the library ban; it must match
   [Wheat] below. *)
let wheat_src = {|
let rec sum = function
  | [] -> 0
  | x :: xs -> x + sum xs

let rec go acc = function
  | [] -> acc
  | x :: xs -> go (acc + x) xs

let isum xs = go 0 xs
|}

module Wheat : S = struct
  let rec sum = function
    | [] -> 0
    | x :: xs -> x + sum xs

  let rec go acc = function
    | [] -> acc
    | x :: xs -> go (acc + x) xs

  let isum xs = go 0 xs
end

(* Chaffs replace one of the two functions; the other stays correct. *)
let chaffs : (module S) chaff list = [
  chaff "base-one"
    "Base case returns 1 (the identity for product, or 'one element left')."
    (module struct
      let rec sum = function [] -> 1 | x :: xs -> x + sum xs
      let isum = Wheat.isum
    end : S);
  chaff "length-not-sum"
    "Copies nlength's shape: adds 1 per element instead of the element."
    (module struct
      let rec sum = function [] -> 0 | _ :: xs -> 1 + sum xs
      let isum = Wheat.isum
    end : S);
  chaff "no-empty-case"
    "Base case is the singleton list [x], so sum [] raises Match_failure."
    (module struct
      let rec sum = function
        | [x] -> x
        | x :: xs -> x + sum xs
        | [] -> raise (Match_failure ("", 0, 0))
      let isum = Wheat.isum
    end : S);
  chaff "drops-accumulator"
    "Iterative version returns 0 at the end instead of the accumulator."
    (module struct
      let sum = Wheat.sum
      let rec go acc = function [] -> 0 | x :: xs -> go (acc + x) xs
      let isum xs = go 0 xs
    end : S);
  chaff "acc-not-tail"
    "Has an accumulator but still adds after the recursive call returns, \
     so it is not tail recursive."
    (module struct
      let sum = Wheat.sum
      let rec go acc = function [] -> acc | x :: xs -> x + go acc xs
      let isum xs = go 0 xs
    end : S);
  chaff "fold-left"
    ~src:"let rec sum = function [] -> 0 | x :: xs -> x + sum xs\n\
          let isum xs = List.fold_left ( + ) 0 xs"
    "Uses List.fold_left: correct and tail recursive, but sidesteps the \
     accumulator pattern the exercise is about (D8)."
    (module struct
      let sum = Wheat.sum
      let isum xs = List.fold_left ( + ) 0 xs
    end : S);
  chaff "stdlib-qualified"
    ~src:"let rec sum = function [] -> 0 | x :: xs -> x + sum xs\n\
          let isum xs = Stdlib.List.fold_left ( + ) 0 xs"
    "Same, written as Stdlib.List.fold_left to get round a naive ban."
    (module struct
      let sum = Wheat.sum
      let isum xs = Stdlib.List.fold_left ( + ) 0 xs
    end : S);
  chaff "acc-starts-at-one"
    "Starts the accumulator at 1, confusing the initial value with a count."
    (module struct
      let sum = Wheat.sum
      let rec go acc = function [] -> acc | x :: xs -> go (acc + x) xs
      let isum xs = go 1 xs
    end : S);
]

let both name f =
  [ test ("sum " ^ name) (fun (module M : S) -> f M.sum);
    test ("isum " ^ name) (fun (module M : S) -> f M.isum) ]

let tests : (module S) test list =
  both "[]" (fun s -> s [] = 0)
  @ both "[5]" (fun s -> s [5] = 5)
  @ both "[1;2;3;4]" (fun s -> s [1; 2; 3; 4] = 10)
  @ both "negatives" (fun s -> s [3; -5; 2] = 0 && s [-1; -1] = -2)
  @ [ test ~kind:Tail "isum long list (10^6)" (fun (module M : S) ->
          M.isum long_list = List.fold_left ( + ) 0 long_list) ]

let () = Harness.run ~no_library:wheat_src meta (module Wheat : S) chaffs tests
