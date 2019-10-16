
val tester : 
   'a list -> 
   ('a,'b) Check_support.tester

val tester2 : 
   'a list -> 'b list -> 
   (('a * 'b),'c) Check_support.tester

val tester3 : 
   'a list -> 'b list -> 'c list -> 
   (('a * 'b * 'c),'d) Check_support.tester

val tester4 : 
   'a list -> 'b list -> 'c list -> 'd list ->
    (('a * 'b * 'c * 'd),'e) Check_support.tester


(** (oneof l) rend un élément arbritraire de la liste l. 
    lance (Failure "oneof") si l est vide. *)

val oneof : 'a list -> 'a

(** (sublist l) rend une sous-liste arbritraire de la liste l. 
    (sublist ~keep:f l) est analogue à (List.filter f l). *)
val sublist : ?keep:('a -> bool) -> 'a list -> 'a list 

(** (product2 l1 l2) rend le produit cartésien 
    des listes l1 et l2 *)
val product2 : 
   'a list -> 'b list -> 
   ('a * 'b) list

(** (product3 l1 l2 l3) rend le produit cartésien 
    des listes l1, l2 et l3 *)
val product3 : 
   'a list -> 'b list -> 'c list -> 
   ('a * 'b * 'c) list

(** (product3 l1 l2 l3 l4) rend le produit cartésien 
    des listes l1, l2, l3 et l4 *)
val product4 : 
   'a list -> 'b list -> 'c list -> 'd list 
   -> ('a * 'b * 'c * 'd) list
