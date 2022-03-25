
module I = Introspection
module T = Test_lib
module R = Learnocaml_report

(* When we fail, the exception carries a learn-ocaml report. *)

exception Fail of Report.t

let fail report = raise (Fail report)

