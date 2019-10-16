(** 
    protect the evaluation of the test code, 
    by catching exceptions and aborting after a timeout.

    assume that an exception `Undefined` is defined previously 
    (typically in "prepare.ml" or "prelude.ml") 
  *)

val protect : (unit -> Report.t) -> Report.t