(** 
    protect the evaluation of the test code, 
    by catching exceptions 
    and aborting after a timeout

    assume that an exception `Undefined` is defined previously in then file prepare.ml
  *)

open Test_env

(* from F. Pottier (https://github.com/ocaml-sf/learn-ocaml-corpus)
"[protect f] evaluates [f()], which either returns normally and produces a
report, or raises [Fail] and produces a report. In either case, the report
is returned.

If an unexpected exception is raised, in student code or in grading code,
the exception is displayed as part of a failure report. (Ideally, grading
code should never raise an exception!) It is debatable whether one should
show just the name of the exception, or a full backtrace; I choose the
latter, on the basis that more information is always preferable." *)

let protect f = 
try
  T.run_timeout f
with
| Fail report ->
   report
| Learnocaml_internal.Undefined ->
  let text = [ R.Text ((Translation.translation ()).not_yet_implemented) ] in
  [R.Message (text, R.Failure)]
| (e : exn) ->
   let text = [
       R.Text ((Translation.translation ()).the_following_exception_is_raised_and_never_caught);
       R.Break;
       R.Output (Printexc.to_string e);
       R.Output (Printexc.get_backtrace ());
     ] in
   let report = [R.Message (text, R.Failure)] in
   report
