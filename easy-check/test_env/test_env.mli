(** from F. Pottier. 
    @ref https://github.com/ocaml-sf/learn-ocaml-corpus *)

module I = Introspection
module T = Test_lib
module R = Learnocaml_report

exception Fail of Report.t

(** (fail r) lance l'exception (Fail r) *)
val fail : Report.t -> 'a