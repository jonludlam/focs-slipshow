(* Exercise 4.4 (notes 4.8.4)
   "What assumptions do the 'making change' functions make about the
   variables till and amt? Describe what could happen if these assumptions
   were violated."

   The assumptions (answer for supervision): every coin is positive; the
   till is in descending order (needed for "largest coin first", not for
   termination); amt >= 0.  Violations: a 0 or negative coin can make change
   recurse forever (stack overflow); a negative amt raises
   Failure "no more coins!" (or returns no solutions, for the all-ways
   version) although nothing is wrong with the till; an ascending till gives
   valid but not fewest-coins change.  Separately, even when every
   assumption holds, the greedy version can fail when change exists.

   Made checkable as two find-a-breaking-input questions, both checked by
   running the notes' code, not against an answer key:
   (a) a valid till and amount (assumptions hold) for which the greedy
       change raises Failure although the all-ways change finds a solution;
   (b) a till and amount violating an assumption that make change run for
       ever.  Checked with a fuel counter (10^5 calls) rather than a
       timeout, so it is deterministic and safe in a browser worker.

   Decided (D6): keep (b) in the notes, but run it in its own worker, so
   that a student's non-terminating experiment can be stopped or abandoned
   without losing the rest of the page.  Needs x-ocaml support for a
   per-cell (or per-exercise) worker. *)

#use "harness.ml";;
open Harness

let meta = {
  id = "4.4";
  title = "assumptions of change (find breaking inputs)";
  question_types = [Find_a_breaking_input; Examples_first];
  tail_recursion = Not_applicable;
  complexity = None;
  placement = Both "the two breaking inputs in the notes; listing the \
                    assumptions and their consequences in supervision";
  open_questions = [];
}

(* The notes' greedy change (4.6), with a fuel counter. *)
exception Out_of_fuel

let greedy ?(fuel = 100_000) till amt =
  let fuel = ref fuel in
  let rec change till amt =
    decr fuel;
    if !fuel < 0 then raise Out_of_fuel;
    match till, amt with
    | _, 0 -> []
    | [], _ -> raise (Failure "no more coins!")
    | c :: till, amt ->
        if amt < c then change till amt else c :: change (c :: till) (amt - c)
  in
  change till amt

(* The notes' all-ways change (4.7). *)
let rec all_ways till amt =
  match till, amt with
  | _, 0 -> [ [] ]
  | [], _ -> []
  | c :: till, amt ->
      if amt < c then all_ways till amt
      else
        let rec allc = function [] -> [] | cs :: css -> (c :: cs) :: allc css in
        allc (all_ways (c :: till) (amt - c)) @ all_ways till amt

let valid till amt =
  amt >= 0 && till <> []
  && List.for_all (fun c -> c > 0) till
  && List.sort (fun a b -> compare b a) till = till

module type S = sig
  val greedy_fails : int list * int   (* (a) *)
  val runs_forever : int list * int   (* (b) *)
end

module Wheat : S = struct
  let greedy_fails = ([5; 2], 6)
  let runs_forever = ([5; 0], 3)
end

let chaffs : (module S) chaff list = [
  chaff "no-change-possible"
    "Picks an amount nobody can change ([5;2], 3): greedy fails, but so does \
     every method, so this doesn't show greedy is wrong."
    (module struct include Wheat let greedy_fails = ([5; 2], 3) end : S);
  chaff "ascending-till"
    "Uses an ascending till ([2;5], 6), which breaks the ordering \
     assumption (and greedy happens to succeed)."
    (module struct include Wheat let greedy_fails = ([2; 5], 6) end : S);
  chaff "has-a-penny"
    "Includes 1 in the till, so greedy can always finish."
    (module struct include Wheat let greedy_fails = ([5; 2; 1], 6) end : S);
  chaff "zero-coin-unreached"
    "Has a 0 coin but the amount is used up before reaching it ([1;0], 3)."
    (module struct include Wheat let runs_forever = ([1; 0], 3) end : S);
  chaff "zero-amount"
    "Has a 0 coin but asks for 0, which the first clause handles at once."
    (module struct include Wheat let runs_forever = ([0], 0) end : S);
  chaff "negative-amount"
    "A negative amount violates an assumption but terminates (Failure)."
    (module struct include Wheat let runs_forever = ([5; 2], -1) end : S);
]

let tests : (module S) test list = [
  test "(a) assumptions hold" (fun (module M : S) ->
      let till, amt = M.greedy_fails in valid till amt);
  test "(a) greedy raises Failure" (fun (module M : S) ->
      let till, amt = M.greedy_fails in
      match greedy till amt with
      | _ -> false
      | exception Failure _ -> true);
  test "(a) change can be made" (fun (module M : S) ->
      let till, amt = M.greedy_fails in all_ways till amt <> []);
  test "(b) greedy runs out of fuel" (fun (module M : S) ->
      let till, amt = M.runs_forever in
      match greedy till amt with
      | _ -> false
      | exception Out_of_fuel -> true
      | exception Stack_overflow -> true
      | exception _ -> false);
]

let () = Harness.run meta (module Wheat : S) chaffs tests
