type 'a sampler = unit -> 'a

(** (const c) engendre constamment la valeur c *) 
val const : 'a -> 'a sampler

val choose : ('a -> 'b) -> ('a -> 'b) -> 'a -> 'b

(** (oneof l ()) rend un élément de l *)
val oneof : 'a list -> 'a sampler

(** (unit ()) rend () *)
val unit : unit sampler

(** (bool ()) rend true ou false *)
val bool : bool sampler

(** (nat max ()) engendre un entier compris entre 0 et max inclus.
    Lance (Invalid_arg "int") si max < 0. *)
val nat : int -> int sampler

(** (int a b ()) engendre un entier compris entre a et b inclus. 
    Lance (Invalid_arg "int") si b < a. *)
val int : int -> int -> int sampler

(** (float a b ()) engendre un entier compris entre a et b inclus. 
    Lance (Invalid_arg "float") si b < a. 
    Si a = b, rend (float_of_int a) *)
val float : int -> int -> float sampler

(** (char a b ()) engendre un char compris entre a et b inclus. 
    Lance (Invalid_arg "char") si b < a.  *)
val char : char -> char -> char sampler 

(** (char_az ()) engendre un char compris entre 'a' et 'z' inclus. *)
val char_az : char sampler 

(** (char_09 ()) engendre un char compris entre '0' et '9' inclus. *)
val char_09 : char sampler 

(** (string ~length:f chr ()) engendre une string de longueur l = (f ()) 
    formée de caractères obtenus en appellant (chr ()) l fois.
    Lance (Invalid_arg "string") si (f ()) < 0 *)
val string : ?length:int sampler -> char sampler -> string sampler

(** (list ~length:f s ()) engendre une liste de longueur l = (f ()) 
    formée de valeurs obtenues en appellant (s ()) l fois.
    Lance (Invalid_arg "list") si (f ()) < 0 *)
val list : ?length:int sampler -> 'a sampler -> 'a list sampler

(** (array ~length:f s ()) engendre un tableau de longueur l = (f ()) 
    formé de valeurs obtenues en appellant (s ()) l fois.
    Lance (Invalid_arg "array") si (f ()) < 0 *)
val array : ?length:int sampler -> 'a sampler -> 'a array sampler

(** (sublist ~keep:f l) rend une sous-liste l' de l : 
    chaque élement de l est consevé si (f ()) rend true. *)
val sublist : ?keep:bool sampler -> 'a list -> 'a list sampler

(** (tuple2 x1 x2 ()) rend (x1 (), x2 ()) *)
val tuple2 : 'a sampler -> 'b sampler -> ('a * 'b) sampler
(** (tuple3 x1 x2 x3 ()) rend (x1 (), x2 (), x3 ()) *)
val tuple3 : 'a sampler -> 'b sampler -> 'c sampler -> 
  ('a * 'b * 'c) sampler
(** (tuple4 x1 x2 x3 x4 ()) rend (x1 (), x2 (), x3 (), x4 ()) *)
val tuple4 : 'a sampler -> 'b sampler -> 'c sampler -> 'd sampler -> 
  ('a * 'b * 'c * 'd) sampler
(** (tuple5 x1 x2 x3 x4 x5 ()) rend (x1 (), x2 (), x3 (), x4 (), x5 ()) *)
val tuple5 : 'a sampler -> 'b sampler -> 'c sampler -> 'd sampler -> 'e sampler ->
  ('a * 'b * 'c * 'd * 'e) sampler

(** (option ~frequency:f s ()) rend None si (f ()) rend false, sinon (Some (s ())) *)
val option : ?frequency:bool sampler -> 'a sampler -> 'a option sampler

(** (tree ~depth:d leaf node ()) engendre un arbre de profondeur (d ())
    avec des feuilles (leaf ()) et des noeuds (node t') où t' est un sampler qui prend unit et rend un sous-arbre.
    Lance (Invalid_arg "tree") si (depth ()) < 0. *)
val tree :
  ?depth:int sampler -> 'a sampler -> ('a sampler -> 'a) -> 'a sampler

val tree_p :
  ?depth:(unit -> int) ->
  ('a -> 'b) -> (('a -> 'b) -> 'a -> 'b) -> 'a -> unit -> 'b
  
val wrap : 'a sampler -> ('a -> 'b) -> 'b sampler