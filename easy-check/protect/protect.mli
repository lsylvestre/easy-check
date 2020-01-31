(** 
    protect the evaluation of the test code, 
    by catching exceptions and aborting after a timeout.

    assume that an exception `Undefined` is defined previously 
    (typically in "prepare.ml" or "prelude.ml") 
  *)

type question = unit -> Report.t ;;

exception Fail of Report.t

val fail : Report.t -> 'a
val protect : question -> Report.t


module I = Introspection
module T = Test_lib
module R = Learnocaml_report