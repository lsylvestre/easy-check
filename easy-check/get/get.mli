
(** (value ~modname:"M" "v" [%ty: tau]) rend la valeur M.v.
    Si la valeur M.v n'est pas compatible avec le type tau,
    alors l'exception Fail est lancée et transporte un rapport de correction. 
    Par défaut ?(modname="Code"). *)
val value : ?modname:string -> string -> 'a Ty.ty -> 'a

(** (mod_value ~modname:"M" "M0" [%ty: (module S)]) rend le module (M.M0 : S) empaquetée dans une valeur.
    Si le module M.M0 n'est pas compatible avec la signature S, 
    alors l'exception Fail est lancée et transporte un rapport de correction.
    Par défaut ?(modname="Code"). *)
val mod_value : ?modname:string -> string -> 'a Ty.ty -> 'a

(** (code [%ty: (module S)]) rend le module (Code : S) empaquetée dans une valeur.
    C'est une abréviation pour (mod_value "M0" [%ty: (module S)]) *)
val code : 'a Ty.ty -> 'a