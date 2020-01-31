(** 
    protect the evaluation of the test code, 
    by catching exceptions 
    and aborting after a timeout

    assume that an exception `Undefined` is defined previously in then file prepare.ml
  *)

type question = unit -> Report.t ;;

exception Fail of Report.t

(* from F. Pottier (https://github.com/ocaml-sf/learn-ocaml-corpus)
"[protect f] evaluates [f()], which either returns normally and produces a
report, or raises [Fail] and produces a report. In either case, the report
is returned.

If an unexpected exception is raised, in student code or in grading code,
the exception is displayed as part of a failure report. (Ideally, grading
code should never raise an exception!) It is debatable whether one should
show just the name of the exception, or a full backtrace; I choose the
latter, on the basis that more information is always preferable." *)

let fail r = raise (Fail r)

module I = Introspection
module T = Test_lib
module R = Learnocaml_report

let protect f = 
  try
    T.run_timeout f
  with
  | Fail report -> report
  | Undefined -> let text = [ R.Text "Not yet implemented." ] in
                 [R.Message (text, R.Failure)]
  | (e : exn) ->
     let text = [
         R.Text "The following exception is raised and never caught:";
         R.Break;
         R.Output (Printexc.to_string e);
         R.Output (Printexc.get_backtrace ());
       ] in
     let report = [R.Message (text, R.Failure)] in
     report