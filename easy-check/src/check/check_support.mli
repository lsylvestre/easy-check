(** On cherche à tester une fonction (f : σ -> τ) au regard d’une solution 
(sol : σ -> τ) modulo une fonction d’égalité (eq : τ -> τ -> bool).
Une instance de ce problème est un triplet p = <f,sol,eq>.
Résoudre p consiste à exhiber un témoin (x0 : σ) tel que
(eq (f x0) (sol x0)) se réduit en false.

Si c’est en effet le cas, le triplet <x0 ,(f x0),(sol x0)> constitue un 
contre-exemple pour p. *)


(** le type ('a,'b) instance représente les instances p = <f,sol,eq>
pour (f : 'a -> 'b)) *)
type ('a,'b) instance = { 
    test   : 'a -> 'b ;        (* la fonction à tester                *)
    expect : 'a -> 'b ;        (* la comportement attendu             *)
    equal  : 'b -> 'b -> bool  (* l'égalité entre éléments de type 'b *)
  }

(** le type ('a,'b) contrexample représente les contre-exemples associés
aux instances (pi : ('a,'b) instance *)
type ('a,'b) counterexample = { 
    witness  : 'a;  (* le témoin x0             *)
    tested   : 'b;  (* la valeur de (test x0)   *)
    expected : 'b   (* la valeur de (expect x0) *)
}

(** (falsify p x0) rend (Some w(x0)) 
    si w(x0) est un contre-exemple pour p, 
    None sinon. *)
val falsify : ('a, 'b) instance -> 'a -> ('a, 'b) counterexample option

(** le type ('a,'b) tester définit les combinateurs qui, 
    étant donnée une instance p = <f,sol,eq> avec (f : 'a -> 'b), 
    engendrent un nombre fini de valeurs (xi : 'a) 
    et rendent chacun un éventuel contre-exemple w(xi) pour p. *)
type ('a, 'b) tester = ('a, 'b) instance -> ('a, 'b) counterexample option