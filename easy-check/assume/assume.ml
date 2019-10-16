open Test_env

module Assume_report :
  sig 
    (** (absent msg) rend qu'une certaine valeur est absente dans l'environnement *)
    val absent : string -> Report.t
    (** (compatible msg) rend un rapport indiquant que l'étudiant n'a pas respecté
        une certaine contrainte de signature.
        Le rapport justifie cette remarque par le message msg (qui peut être par exemple : 
        - une représentation de la signature sous forme de chaîne de caractères, 
        - ou bien le message d'erreur fournit par le compilateur OCaml) *)
     val incompatible : string -> Report.t

    (** (compatible msg) rend un rapport indiquant que l'étudiant a respecté 
        une certaine contrainte de signature, alors qu'il ne le devrait pas. 
        Le rapport justifie cette remarque par le message msg (qui peut être par exemple : 
        - une représentation de la signature sous forme de chaîne de caractères, 
        - ou bien le message d'erreur fournit par le compilateur OCaml) *)
    val compatible : string -> 'a Ty.ty -> Report.t
   
    (** (using x y) rend un rapport indiquant que la fonction liée à x ne devrait pas utiliser la variable y *) 
    val using : string -> string -> Report.t
    
    (** (not_using x y) rend un rapport indiquant que la fonction liée à x doit utiliser la variable y *) 
    val not_using : string -> string -> Report.t
    
  end = struct
  let absent (name : string) = 
    let m = [ R.Text "Cannot find "; R.Output name ] in
      [R.Message (m,R.Failure)]

  let incompatible (message : string) = 
    let m = [ R.Text "your code is not compatible with the expected signature : "; R.Break;
              R.Output message ] in
      [R.Message (m,R.Failure)]

  let compatible name ty = 
    let m = [ R.Text ("the value " ^ name ^ " is compatible with an unexpected type : "); R.Break;
              R.Output (Ty.print ty) ] in
      [R.Message (m,R.Failure)]

  (* fonction auxiliaire *)
  let warning_report m =
    [R.Message ([],R.Failure);
     R.Message ([R.Text m],R.Warning)]

  let using (x : string) (y : string) =
    fail @@ warning_report (x ^ " should not use " ^ y)

  let not_using (x : string) (y : string) =
    fail @@ warning_report (x ^ " should use " ^ y)

end

module Check_ast = struct
  exception Found of string

  let find_opt expr_name lidents =
    try 
      ignore (T.find_binding code_ast expr_name @@ fun expr ->
      let on_expression = Parsetree.(function 
          | { pexp_desc = Pexp_ident {txt=Longident.Lident v }} 
                  -> if List.mem v lidents then raise (Found v);
                     []
          | _ -> []) in T.ast_check_expr ~on_expression:on_expression expr);
      None
    with Found v -> Some v
end

let using f lst_lident = 
  let aux g = 
    match Check_ast.(find_opt f [g]) with
    | Some _ -> ()
    | _ -> fail @@ Assume_report.not_using f g in
  List.iter aux lst_lident

let not_using f lst_lident = 
  let aux g = 
    match Check_ast.find_opt f [g] with
    | Some _ -> fail @@ Assume_report.using f g
    | _ -> () in
  List.iter aux lst_lident

let compatible name ty =
  Get.value name ty |> ignore

let incompatible name ty =
  let vname = match name with "" -> "Code" | s -> "Code." ^ s in
  match I.get_value vname ty with
  | Incompatible _ -> ()
  | Present v -> fail @@ Assume_report.compatible name ty
  | Absent -> fail @@ Assume_report.absent name

