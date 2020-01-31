open Falsify

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

val check :
      show_argument:('a -> string) ->
      show_result:('b -> string) ->
      code:('a -> 'b) ->
      solution:('a -> 'b) ->
      source:string ->
      ?equal:('b -> 'b -> bool) ->
      ?exn_equal:(exn -> exn -> bool) ->
      ?stdout_equal:(string -> string -> bool) ->
      ?stderr_equal:(string -> string -> bool) ->
      ?testers:('a, 'b testresult) tester list ->
      'a list -> Report.t


type ('v,'args,'ret) check = 
  'v Ty.ty ->
  ?apply:('v -> 'v) -> 
  ?equal:('ret -> 'ret -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:(('args, 'ret testresult) tester list) ->
  'args list -> Report.t

type name = string
type 'e expr = 'e * 'e * string


val name1 : 
  name -> 
   ('a1 -> 'ret, 'a1, 'ret) check

val name2 : 
  name ->
   ('a1 -> 'a2 -> 'ret, 'a1 * 'a2, 'ret) check

val name3 :
  name ->
  ('a1 -> 'a2 -> 'a3 -> 'ret, 'a1 * 'a2 * 'a3, 'ret) check

val name4 :
  name ->
  ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'ret, 
    'a1 * 'a2 * 'a3 * 'a4, 'ret) check

val name5 :
  name -> 
  ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'a5 -> 'ret,
  'a1 * 'a2 * 'a3 * 'a4 * 'a5, 
  'ret) check

val expr1 :
  ('a1 -> 'ret) expr ->
   ('a1 -> 'ret, 
   'a1, 
   'ret) check

val expr2 :
  ('a1 -> 'a2 -> 'ret) expr ->
   ('a1 -> 'a2 -> 'ret,
    'a1 * 'a2,  
    'ret) check

val expr3 :
  ('a1 -> 'a2 -> 'a3 -> 'ret) expr ->
    ('a1 -> 'a2 -> 'a3 -> 'ret,
    'a1 * 'a2 * 'a3, 
    'ret) check

val expr4 :
  ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'ret) expr ->
    ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'ret, 
    'a1 * 'a2 * 'a3 * 'a4, 
    'ret) check

val expr5 : 
 ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'a5 -> 'ret) expr ->
   ('a1 -> 'a2 -> 'a3 -> 'a4 -> 'a5 -> 'ret,
   'a1 * 'a2 * 'a3 * 'a4 * 'a5, 
   'ret) check


val name : string -> 'a Ty.ty -> ?equal:('a -> 'a -> bool) -> unit -> Report.t

val expr : 'a * 'a * string -> 'a Ty.ty -> ?equal:('a -> 'a -> bool) -> unit -> Report.t
