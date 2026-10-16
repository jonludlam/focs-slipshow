(* Exercise 4.6 (notes 4.8.6)
   "We know nothing about the functions f and g other than their
   polymorphic types: val f : 'a * 'b -> 'b * 'a and val g : 'a -> 'a list.
   Suppose that f (1, true) and g 0 are evaluated and return their results.
   State, with reasons, what you think the resulting values will be."

   Made checkable as Predict:
   - f (1, true) can only be (true, 1).
   - g 0 is not determined: it is some list whose elements are all 0
     (possibly empty).  Asked as "which of these values are possible?".
   The answer key is itself checked with the type checker: every "possible"
   value has a witness implementation that type-checks against the
   explicitly polymorphic type and returns it; every "impossible" value's
   natural implementation is rejected.  The "with reasons" (parametricity)
   part is for supervision.

   Decided (D7): the browser version states the caveat explicitly:
   "assume both calls return normally (no exception, no infinite loop)". *)

#use "harness.ml";;
open Harness

let meta = {
  id = "4.6";
  title = "what can a function of type 'a * 'b -> 'b * 'a return? (predict)";
  question_types = [Predict];
  tail_recursion = Not_applicable;
  complexity = None;
  placement = Both "the predictions in the notes; the reasons in \
                    supervision";
  open_questions = [];
}

let candidates = ["[]"; "[0]"; "[0; 0]"; "[1]"; "[0; 1]"; "[true]"]

module type S = sig
  val f_value : string           (* the value of f (1, true) *)
  val g_possible : string list   (* which candidates g 0 could return *)
end

module Wheat : S = struct
  let f_value = "(true, 1)"
  let g_possible = ["[]"; "[0]"; "[0; 0]"]
end

let chaffs : (module S) chaff list = [
  chaff "f-identity"
    "Thinks f might return its argument unchanged."
    (module struct include Wheat let f_value = "(1, true)" end : S);
  chaff "f-computes"
    "Thinks f could compute a new bool, e.g. (not y, x)."
    (module struct include Wheat let f_value = "(false, 1)" end : S);
  chaff "g-singleton"
    "Thinks g must be fun x -> [x], so only [0] is possible."
    (module struct include Wheat let g_possible = ["[0]"] end : S);
  chaff "g-any-int-list"
    "Thinks g 0 : int list can contain any ints."
    (module struct include Wheat let g_possible = ["[]"; "[0]"; "[0; 0]"; "[1]"; "[0; 1]"] end : S);
  chaff "g-nonempty"
    "Thinks g must use its argument, so [] is impossible."
    (module struct include Wheat let g_possible = ["[0]"; "[0; 0]"] end : S);
]

(* A witness that type-checks against the polymorphic signature and
   produces the value, or an implementation that would be needed and is
   rejected. *)
let g_impl = function
  | "[]" -> "fun _ -> []" | "[0]" -> "fun x -> [x]" | "[0; 0]" -> "fun x -> [x; x]"
  | "[1]" -> "fun _ -> [1]" | "[0; 1]" -> "fun x -> [x; 1]"
  | "[true]" -> "fun _ -> [true]" | s -> failwith s

let g_witness v =
  Printf.sprintf "let g : 'a. 'a -> 'a list = %s;;\nlet () = assert (g 0 = %s);;\n"
    (g_impl v) v

let tests : (module S) test list = [
  test "f (1, true)" (fun (module M : S) ->
      squash M.f_value = "(true, 1)"
      && typechecks "let f : 'a 'b. 'a * 'b -> 'b * 'a = fun (x, y) -> (y, x);;\n\
                     let () = assert (f (1, true) = (true, 1));;\n"
      && not (typechecks "let f : 'a 'b. 'a * 'b -> 'b * 'a = fun (x, y) -> (not y, x);;\n"));
  test "possible values of g 0" (fun (module M : S) ->
      List.sort compare M.g_possible = List.sort compare Wheat.g_possible);
  test "answer key agrees with the type checker" (fun _ ->
      List.for_all
        (fun v -> typechecks (g_witness v) = List.mem v Wheat.g_possible)
        candidates);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
