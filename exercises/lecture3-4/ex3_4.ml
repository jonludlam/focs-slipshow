(* Exercise 3.4 (notes 3.8.4)
   "Consider the polymorphic types in these two function declarations:
      let id x = x            (* val id : 'a -> 'a *)
      let rec loop x = loop x (* val loop : 'a -> 'b *)
   Explain why these types make logical sense, preventing run time type
   errors, even for expressions like id [id [id 0]] or loop true / loop 3."

   Not a coding exercise.  The checkable part is a set of predictions
   (Predict); the "explain why" part belongs in supervision.  The "wheat" is
   the answer key, the "chaffs" are wrong answers that come from specific
   misconceptions; the tests check answers against the real type checker
   (via [toplevel_types]) and the real evaluator, not against strings typed
   in by hand. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "3.4";
  title = "the types of id and loop (predict)";
  question_types = [Predict];
  tail_recursion = Not_applicable;
  complexity = None;
  placement = Both "predict the types/values/behaviour in the notes; the \
                    explanation (why 'b is safe for a function that never \
                    returns) in supervision";
  open_questions = [];
}

type behaviour =
  | Type_error_at_compile_time
  | Type_error_at_run_time
  | Runs_forever
  | Raises_division_by_zero
  | Returns_a_number

module type S = sig
  val type_of_nested_id : string   (* type of  id [id [id 0]] *)
  val value_of_nested_id : string  (* its value, in OCaml syntax *)
  val type_of_loop_div : string    (* type of  loop true / loop 3 *)
  val behaviour_of_loop_div : behaviour
end

module Wheat : S = struct
  let type_of_nested_id = "int list list"
  let value_of_nested_id = "[[0]]"
  let type_of_loop_div = "int"
  let behaviour_of_loop_div = Runs_forever
end

let prelude = "let id x = x;;\nlet rec loop x = loop x;;\n"

let real_types =
  lazy (match toplevel_types (prelude ^ "id [id [id 0]];;\nfun () -> loop true / loop 3;;\n") with
        | [_; _; t1; t2] -> (t1, t2)
        | l -> failwith ("toplevel_types: " ^ String.concat " | " l))

let chaffs : (module S) chaff list = [
  chaff "id-stays-polymorphic"
    "Thinks the result of id is still 'a, so id [id [id 0]] : 'a list."
    (module struct
      include Wheat
      let type_of_nested_id = "'a list"
    end : S);
  chaff "id-unwraps"
    "Thinks id strips a layer (or that the brackets cancel): int."
    (module struct
      include Wheat
      let type_of_nested_id = "int"
      let value_of_nested_id = "0"
    end : S);
  chaff "loop-returns-arg-type"
    "Reads loop as 'a -> 'a, so loop true : bool and the division is a \
     compile-time type error."
    (module struct
      include Wheat
      let type_of_loop_div = "type error"
      let behaviour_of_loop_div = Type_error_at_compile_time
    end : S);
  chaff "runtime-type-error"
    "Accepts the type int but expects the bool to cause an error at run \
     time, as in a dynamically typed language."
    (module struct
      include Wheat
      let behaviour_of_loop_div = Type_error_at_run_time
    end : S);
  chaff "right-to-left-then-div"
    "Knows OCaml often evaluates right to left, but thinks loop 3 returns \
     and something then divides by zero."
    (module struct
      include Wheat
      let behaviour_of_loop_div = Raises_division_by_zero
    end : S);
]

let tests : (module S) test list = [
  test "type of id [id [id 0]]" (fun (module M : S) ->
      squash M.type_of_nested_id = fst (Lazy.force real_types));
  test "value of id [id [id 0]]" (fun (module M : S) ->
      let id x = x in
      squash M.value_of_nested_id
      = (match id [id [id 0]] with
         | [[0]] -> "[[0]]" | _ -> "?"));
  test "type of loop true / loop 3" (fun (module M : S) ->
      (* the toplevel prints the thunk's type, unit -> int *)
      "unit -> " ^ squash M.type_of_loop_div = snd (Lazy.force real_types));
  test "behaviour of loop true / loop 3" (fun (module M : S) ->
      (* Checked for real: evaluating it must time out (the harness's alarm
         stops it), not raise or return. *)
      let rec loop x = loop x in
      let observed =
        match run_check ~seconds:1 (fun () -> ignore (loop true / loop 3); true) () with
        | Raised "timeout" -> Runs_forever
        | Raised "Division_by_zero" -> Raises_division_by_zero
        | Raised _ -> Type_error_at_run_time
        | Pass | Fail -> Returns_a_number
      in
      M.behaviour_of_loop_div = observed);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
