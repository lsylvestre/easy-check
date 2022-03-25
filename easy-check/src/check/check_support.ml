open Test_env

(* On cherche à tester une fonction (f : 'a -> 'b) au regard d’une solution 
(sol : 'a -> 'b) modulo une fonction d’égalité (eq : 'b -> 'b -> bool).
Une instance de ce problème est un triplet p = <f,sol,eq>.
Résoudre p consiste à exhiber un témoin (x0 : 'a) tel que
(eq (f x0) (sol x0)) se réduit en false.

Si c'est en effet le cas, le triplet <x0 ,(f x0),(sol x0)> constitue un contre-
exemple pour p. *)
type ('a,'b) instance = { 
    test: 'a -> 'b ;         (* la fonction à tester                *)
    expect: 'a -> 'b;        (* la comportement attendu             *)
    equal: 'b -> 'b -> bool  (* l'égalité entre éléments de type 'b *)
  }

and  ('a,'b) counterexample = { 
    witness: 'a;             (* le témoin x0             *)
    tested : 'b;             (* la valeur de (test x0)   *)
    expected : 'b            (* la valeur de (expect x0) *)
  }

(** (falsify p x0) rend (Some w(x0)) si w(x0) est un contre-exemple pour p, None sinon. *)
let falsify {equal=equal;test=test;expect=expect} x = 
  (* TODO : réaliser un timeout
     dans le cas où (test x) ou (equal i.tested i.expected) ne se termine pas.
   *)
  let i = { witness = x;
            tested  = test x; 
            expected = expect x} in
  match equal i.tested i.expected  with
  | true -> None 
  | false -> Some i

(** combinateurs qui, étant donnée une instance p0 = <f,sol,eq> avec (f : 'a -> 'b), 
      engendrent un nombre fini de valeurs (xi : 'a) et rendent chacun un éventuel 
      contre-exemple w(xi) pour p. *)
type ('a,'b) tester = ('a,'b) instance -> ('a,'b) counterexample option