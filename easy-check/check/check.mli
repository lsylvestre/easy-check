val default_stdout_equal : (string -> string -> bool) ref
val default_stderr_equal : (string -> string -> bool) ref

(** une valeur (r: τ testresult) est un valeur qui, 
    en plus de conserver la valeur de retour de la fonction 
    (f : σ1 -> σ2 -> ... -> σN -> τ) testée 
    et de la solution (sol : σ1 -> σ2 -> ... -> σN -> τ) :

    1. conserve une trace des écritures réalisées par la f et sol 
       sur les cannaux stdout et stderr,
    2. encapsule le resultat dans une valeur du type ('a,exn) Pervasives.result 
       ayant un constructeur (Ok v) si la fonction f (resp. sol) à bien rendu une valeur,
      (Error e) si f (resp. sol) a lancé l'exception e. 
*)
type 'a testresult

val name1 : 
  string -> ('a -> 'b) Ty.ty ->
  ?equal:('b -> 'b -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:(('a, 'b testresult) Check_support.tester list) ->
  'a list ->
  Report.t

val name2 :
  string -> ('a -> 'b -> 'c) Ty.ty ->
  ?equal:('c -> 'c -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b) as 'args, 'c testresult) Check_support.tester list) ->
  'args list ->
  Report.t

val name3 :
  string -> ('a -> 'b -> 'c -> 'd) Ty.ty ->
  ?equal:('d -> 'd -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c) as 'args, 'd testresult) Check_support.tester list) ->
  'args list ->
  Report.t

val name4 :
  string -> ('a -> 'b -> 'c -> 'd -> 'e) Ty.ty ->
  ?equal:('e -> 'e -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c * 'd) as 'args, 'e testresult) Check_support.tester list) ->
  'args list ->
  Report.t

val name5 :
  string -> ('a -> 'b -> 'c -> 'd -> 'e -> 'f) Ty.ty ->
  ?equal:('f -> 'f -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c * 'd * 'e) as 'args, 'f testresult) Check_support.tester list) ->
  'args list ->
  Report.t

val expr1 :
  ((('a -> 'b) as 'expr) * 'expr * string) -> 
  'expr Ty.ty ->
  ?equal:('b -> 'b -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:(('a, 'b testresult) Check_support.tester list) ->
  'a list ->
  Report.t

val expr2 :
  ((('a -> 'b -> 'c) as 'expr) * 'expr * string) -> 
  'expr Ty.ty ->
  ?equal:('c -> 'c -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b) as 'args, 'c testresult) Check_support.tester list) -> 
  'args list ->
  Report.t

val expr3 :
  ((('a -> 'b -> 'c -> 'd) as 'expr) * 'expr * string) -> 
  'expr Ty.ty ->  
  ?equal:('d -> 'd -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c) as 'args, 'd testresult) Check_support.tester list) -> 
  'args list ->
  Report.t

val expr4 :
  ((('a -> 'b -> 'c -> 'd -> 'e) as 'expr) * 'expr * string) ->
  'expr Ty.ty ->
  ?equal:('e -> 'e -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c * 'd) as 'args, 'e testresult) Check_support.tester list) -> 
  'args list ->
  Report.t

val expr5 : 
  ((('a -> 'b -> 'c -> 'd -> 'e -> 'f) as 'expr) * 'expr * string) ->
  'expr Ty.ty ->
  ?equal:('f -> 'f -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:((('a * 'b * 'c * 'd * 'e) as 'args, 'f testresult) Check_support.tester list) -> 
  'args list ->
  Report.t


val name : string -> 'a Ty.ty -> ?equal:('a -> 'a -> bool) -> unit -> Report.t

val expr : 'a * 'a * string -> 'a Ty.ty -> ?equal:('a -> 'a -> bool) -> unit -> Report.t
