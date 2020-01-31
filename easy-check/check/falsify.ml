open Protect

(* On cherche à tester une fonction (f : 'a -> 'b) au regard d’une solution 
(sol : 'a -> 'b) modulo une fonction d’égalité (eq : 'b -> 'b -> bool).
Une instance de ce problème est un triplet p = <f,sol,eq>.
Résoudre p consiste à exhiber un témoin (x0 : 'a) tel que
(eq (f x0) (sol x0)) se réduit en false.

Si c'est en effet le cas, le triplet <x0 ,(f x0),(sol x0)> constitue un contre-
exemple pour p. *)
type ('a,'b) instance = { 
    code     : 'a -> 'b ;        (* la fonction à tester                *)
    solution : 'a -> 'b ;        (* la comportement attendu             *)
    equal    : 'b -> 'b -> bool  (* l'égalité entre éléments de type 'b *)
  }

type ('a,'b) counterexample = { 
    x0           : 'a;  (* le témoin                  *)
    code_x0      : 'b;  (* la valeur de (code x0)     *)
    solution_x0  : 'b   (* la valeur de (solution x0) *)
}

(** (falsify p x0) rend (Some w(x0)) si w(x0) est un contre-exemple pour p, None sinon. *)
let falsify {code=code;solution=solution;equal=equal} a =
  (* TODO : réaliser un timeout
     dans le cas où (test x) ou (equal i.tested i.expected) ne se termine pas.
   *)
  let cv = code a 
  and sv = solution a in
  let i = { x0 = a; code_x0 = cv; solution_x0 = sv} in
  match equal cv sv with
  | true -> None 
  | false -> Some i

(** combinateurs qui, étant donnée une instance p0 = <f,sol,eq> avec (f : 'a -> 'b), 
      engendrent un nombre fini de valeurs (xi : 'a) et rendent chacun un éventuel 
      contre-exemple w(xi) pour p. *)
type ('a,'b) tester = ('a,'b) instance -> ('a,'b) counterexample option