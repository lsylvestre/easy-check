(** (using f [x1;x2;...]) retourne () si il y a au moins une occurrence 
    de chaque variable x1;x2 ... dans le corps de f.
    Sinon, lance l'exception Test_env.Fail transportant un rapport d'erreur 
    indiquant quelle variable n'a malencontreusement pas été utilisée *)
val using : string -> string list -> unit


(** (not_using f [x1;x2;...]) retourne () si il y'a au moins 
     une variable x1;x2 ... n'ayant aucune occurence  dans le corps de f.
     Sinon, lance l'exception Test_env.Fail transportant un rapport d'erreur
     indiquant quelle variable est malencontreusement absente. *)
val not_using : string -> string list -> unit

(** (incompatible name [%ty: tau]) lance l'exception Test_env.Fail transportant un rapport détaillé 
    si la valeur liée à name dans le module Code est compatible avec le type tau, 
    ou si cette valeur est absente. *)

val incompatible : string -> 'a Ty.ty -> unit

(** (compatible name [%ty: tau]) lance l'exception Test_env.Fail transportant un rapport détaillé 
    si la valeur liée à name dans le module Code est incompatible avec le type tau, 
    ou si cette valeur est absente. *)
val compatible : string -> 'a Ty.ty -> unit