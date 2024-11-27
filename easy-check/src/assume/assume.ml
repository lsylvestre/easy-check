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
  (** (not_using x) rend un rapport indiquant que la fonction liée à x n'est pas récursive terminale *) 
  val not_tail_rec : string -> Parsetree.expression -> Report.t
end = struct
  let absent (name : string) = 
    let m = (Translation.translation ()).cannot_find name in
    [R.Message (m,R.Failure)]

  let incompatible (message : string) = 
    let m = (Translation.translation ()).incompatible @ 
             [ R.Break;
               R.Output message ] in
    [R.Message (m,R.Failure)]

  let compatible name ty = 
    let m = ((Translation.translation ()).unexpected_compatible name) @
            [ R.Break;
              R.Output (Ty.print ty) ] in
    [R.Message (m,R.Failure)]

  (* fonction auxiliaire *)
  let warning_report m =
    [R.Message ([],R.Failure);
     R.Message (m,R.Warning)]

  let using (x : string) (y : string) =
    fail @@ warning_report ((Translation.translation ()).should_not_use x y)

  let not_using (x : string) (y : string) =
    fail @@ warning_report ((Translation.translation ()).should_use x y)

  let not_tail_rec (x : string) (expr : Parsetree.expression) =
    fail @@ warning_report ((Translation.translation ()).should_be_tail_rec x (Pprintast.string_of_expression expr))
    (* rappel : le module Expr est le support pour l'extension de syntaxe [%code ..] *)

end

module Check_ast = struct
  exception Found of string

  let longident_of_string x = 
      match Longident.unflatten (String.split_on_char '.' x) with
    | None -> assert false
    | Some l -> l

  let string_of_longident ident = String.concat "." @@ Longident.flatten ident

  let find_opt expr_name lidents =
  let lgidents = List.map longident_of_string lidents 
  in
    try 
      ignore (T.find_binding code_ast expr_name @@ 
      fun expr ->
      let on_expression = 
        Parsetree.(function 
        | { pexp_desc = Pexp_ident {txt=v}} 
          -> if List.mem v lgidents then raise (Found (string_of_longident v));
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





module Tail_rec = struct
  open Parsetree 
  open Asttypes

  let idents_of_patern p =
    let acc = ref [] in
    let rec aux {ppat_desc=p} = 
      match p with
      | Ppat_any | Ppat_constant _ | Ppat_interval _ -> ()
      | Ppat_var {txt=s} -> acc := s :: !acc
      | Ppat_tuple ps -> List.iter aux ps
      | Ppat_alias _ -> () (* TODO *)
      | Ppat_construct _ -> () (* TODO *)
      | Ppat_variant (_,None) -> ()
      | Ppat_variant (_,Some p) -> aux p
      | Ppat_record _ -> () (* TODO *)
      | Ppat_array ps -> List.iter aux ps
      | Ppat_or (p1,p2) -> aux p1; aux p2
      | Ppat_constraint (p,_) -> aux p
      | Ppat_type _ -> () (* TODO *) 
      | Ppat_lazy p -> aux p
      | Ppat_unpack _ -> () (* TODO *) 
      | Ppat_exception p -> aux p
      | Ppat_extension _ -> () (* TODO *) 
      | Ppat_open (_,p) -> aux p 
    in 
    aux p;
    !acc

  let idents_of_value_binding {pvb_pat=p} = 
    idents_of_patern p

  let idents_of_value_bindings bds =
    List.fold_left
      (fun acc bd ->
        List.rev_append acc (idents_of_value_binding bd))
      []
      bds

  let check_gobal f name = 
    (* ne fait rien si [name] n'est pas défini *)
    List.iter (function
        | {pstr_desc=Pstr_value(Recursive,bds)} -> 
           let idents = idents_of_value_bindings bds in
           if List.mem name idents then f idents bds
        (* | {pstr_desc=Pstr_value(Nonrecursive,bds)} -> f [] bds  *)
        | _ -> ()) code_ast ;;
    


(* rend la liste des variables globales du module code utilisée dans l'expression e *)
  let globals_used_aux genv e =
    let acc = ref [] in
    let rec aux lenv {pexp_desc=e} = match e with 
    | Pexp_ident {txt=Lident name} -> 
      if List.mem name genv then acc := name :: !acc
    | Pexp_constant _ -> ()
    | Pexp_let (Nonrecursive,bds,e) ->  
        List.iter (function {pvb_expr=vbe} -> aux lenv vbe) bds;
        let lenv' = idents_of_value_bindings bds @ lenv in
        aux lenv' e
    | Pexp_let (Recursive,bds,e) -> 
       let lenv' = idents_of_value_bindings bds @ lenv in
       List.iter (function {pvb_expr=vbe} -> aux lenv' vbe) bds;
       aux lenv' e
    | Pexp_fun (Nolabel,_,p,e) -> 
       let lenv' = idents_of_patern p @ lenv in
       aux lenv' e
    | Pexp_fun _ -> () (* TODO, cas avec labels *)
    | Pexp_function cases -> aux_cases lenv cases 
    | Pexp_match (e,cases) | Pexp_try (e,cases) -> 
       aux lenv e;
       aux_cases lenv cases 
    | Pexp_apply (e,es) -> aux lenv e;
                           List.iter (fun (_,e) -> aux lenv e) es
    | Pexp_ifthenelse (e1,e2,None) -> aux lenv e1;
                                      aux lenv e2
    | Pexp_ifthenelse (e1,e2,Some e3) -> aux lenv e1;
                                         aux lenv e2;
                                         aux lenv e3
    | Pexp_sequence (e1,e2) -> aux lenv e1;
                               aux lenv e2
    | Pexp_tuple (es) ->  List.iter (aux lenv) es 
    | Pexp_record (ms,w) -> List.iter (fun (_,e) -> aux lenv e) ms;
                            (match w with
                             | None -> ()
                             | Some ew -> aux lenv ew)
    | Pexp_field (e,_) -> aux lenv e
    | Pexp_setfield (e1,_,e2) -> aux lenv e1;
                                 aux lenv e2
    | Pexp_array es -> List.iter (aux lenv) es
    | Pexp_while (e1,e2) -> aux lenv e1;
                            aux lenv e2
    | Pexp_for (p,e1,e2,_,e3) -> aux lenv e1;
                                 aux lenv e2;
                                 let lenv' = idents_of_patern p @ lenv in
                                 aux lenv' e3
    | Pexp_constraint (e,_) -> aux lenv e
    | Pexp_coerce (e,_,_) -> aux lenv e
    | Pexp_send (e,_) -> aux lenv e
    | Pexp_new _ -> ()
    | Pexp_setinstvar (_,e) -> aux lenv e
    | Pexp_override ms -> List.iter (fun (_,e) -> aux lenv e) ms
    | Pexp_letexception (_,e) -> aux lenv e
    | Pexp_assert e -> aux lenv e
    | Pexp_lazy e -> aux lenv e
    | Pexp_poly (e,_) -> aux lenv e
    | Pexp_object _ -> () (* TODO *)
    | _ -> ()  (* ... *)
  and aux_cases lenv cases =
    List.iter (function {pc_lhs=p;pc_guard=w;pc_rhs=e} ->            
                 (match w with
                  | None -> ()
                  | Some ew -> aux lenv ew);
                 let lenv' = idents_of_patern p @ lenv in
                 aux lenv' e) cases
  in aux [] e;
  !acc

  let globals_used genv (recflag,bds) =
    let genv' = match recflag with 
                | Nonrecursive -> genv
                | Recursive -> idents_of_value_bindings bds @ genv 
    in
     List.concat @@ List.map (fun {pvb_expr=e} -> globals_used_aux genv' e) bds


  exception NotTailRec of expression

  let capture env idents = 
    List.filter (fun x -> not (List.mem x idents)) env

  let rec check_expr env tail ({pexp_desc=e} as expr) =
    match e with
    | Pexp_ident {txt=Lident name} -> 
      if not tail && List.mem name env then raise (NotTailRec expr)
    | Pexp_constant _ -> ()
    | Pexp_let (Nonrecursive,bds,e) -> 
        let idents = List.fold_left (fun acc vb -> idents_of_value_binding vb @ acc) [] bds in
        List.iter (function {pvb_expr=vbe} -> check_expr env false vbe) bds;
        let env' = capture env idents in
        check_expr env' tail e
    | Pexp_let (Recursive,bds,e) -> 
       let idents = idents_of_value_bindings bds in 
       let env' = idents @ env in    
       List.iter (fun {pvb_expr=e} -> check_expr env' true e) bds;
       check_expr env' tail e
    | Pexp_fun (Nolabel,_,p,e) -> 
       let idents = idents_of_patern p in

       let env' = capture env idents in
       check_expr env' tail e
    | Pexp_fun _ -> () (* TODO, cas avec labels *)
    | Pexp_function cases -> check_cases env tail cases 
    | Pexp_match (e,cases) | Pexp_try (e,cases) -> 
       check_expr env tail e;  
       check_cases env tail cases 
    | Pexp_apply (e,es) -> 
      (let tail' = match e with 
                  | {pexp_desc=Pexp_ident {txt=Lident "||"}} -> tail
                  | {pexp_desc=Pexp_ident {txt=Lident "&&"}} -> tail
                  | _ -> false 
       in
       try 
         check_expr env tail e;
         List.iter (fun (_,e) -> check_expr env tail' e) es
       with NotTailRec _ -> raise (NotTailRec expr))
    | Pexp_ifthenelse (e1,e2,None) -> check_expr env false e1;
                                      check_expr env tail e2
    | Pexp_ifthenelse (e1,e2,Some e3) -> check_expr env false e1;
                                         check_expr env tail e2;
                                         check_expr env tail e3

    | Pexp_sequence (e1,e2) -> check_expr env tail e1;
                               check_expr env tail e2
    | Pexp_tuple (es) ->  List.iter (check_expr env false) es 
    | Pexp_record (ms,w) -> List.iter (fun (_,e) -> check_expr env false e) ms;
                            (match w with
                             | None -> ()
                             | Some ew -> check_expr env false ew)
    | Pexp_field (e,_) -> check_expr env false e
    | Pexp_setfield (e1,_,e2) -> check_expr env false e1;
                                 check_expr env false e2
    | Pexp_array es -> List.iter (check_expr env false) es
    | Pexp_while (e1,e2) -> check_expr env false e1;
                            check_expr env false e2     (* false ?? *)
    | Pexp_for (p,e1,e2,_,e3) -> check_expr env false e1;
                                 check_expr env false e2;
                                 let idents = idents_of_patern p in
                                 let env' = capture env idents in
                                 check_expr env' false e3
    | Pexp_constraint (e,_) -> check_expr env tail e
    | Pexp_coerce (e,_,_) -> check_expr env tail e
    | Pexp_send (e,_) -> check_expr env tail e
    | Pexp_new _ -> ()
    | Pexp_setinstvar (_,e) -> check_expr env tail e
    | Pexp_override ms -> List.iter (fun (_,e) -> check_expr env false e) ms
    | Pexp_letexception (_,e) -> check_expr env tail e
    | Pexp_assert e -> check_expr env tail e  (* false ?? *)
    | Pexp_lazy e -> check_expr env tail e  (* false ?? *)
    | Pexp_poly (e,_) -> check_expr env tail e  (* false ?? *)
    | Pexp_object _ -> () (* TODO *)
    | _ -> ()  (* ... *)
  and check_cases env tail cases =
    List.iter (function {pc_lhs=p;pc_guard=w;pc_rhs=e} ->
                 let idents = idents_of_patern p in
                 let env' = capture env idents in
                 (match w with
                  | None -> ()
                  | Some ew -> check_expr env' false ew);
                 check_expr env' tail e) cases

  (* [find name] cherche dans le code de l'étudiant le bloc déclarant 
     l'idenficateur name. *)
  let find name = 
    let rec aux = function
    | [] -> fail (Assume_report.absent name)
    | {pstr_desc=Pstr_value(recflag,bds)} :: r ->
        let idents = idents_of_value_bindings bds in
        if List.mem name idents then (recflag,bds) 
        else aux r
    | _ :: r -> aux r
    in aux code_ast
    
  (* [globals name] rend la liste des identificateurs déclarés dans
     le code de l'étudiant le bloc déclarant avant l'idenficateur [name]. *)
  let globals name = 
    let rec aux acc = function
    | [] -> assert false
    | {pstr_desc=Pstr_value(_,bds)} :: r ->
        let idents = idents_of_value_bindings bds in
        if List.mem name idents then idents @ acc
        else aux (idents @ acc) r
    in aux [] code_ast

  (* Test de récursivité terminale.
     [tail_rec name] lance une exception transportant un rapport d'erreur si l'identificateur 
     [name] est liée à une valeur utilisant au moins une fonction LOCALE récursive non terminale *)
  let check_single_tail_rec name = 
    let f idents bds = 
      List.iter (function {pvb_expr=e} -> check_expr idents true e) bds 
    in
    check_gobal f name


end

(* Test de récursivité terminale.
   [tail_rec name] lance une exception transportant un rapport d'erreur si l'identificateur 
   [name] est liée à une valeur utilisant au moins une fonction récursive non terminale 
   (que la fonction récursive soit locale ou globale dans le module Code) *)
let tail_rec name = 
  let open Tail_rec in
  let ast = find name in
  let genv = globals name in
  let idents = globals_used genv ast in

  (try check_single_tail_rec name with 
   | NotTailRec expr -> fail (Assume_report.not_tail_rec name expr)); 

  List.iter (function ident -> 
               try check_single_tail_rec ident with 
               | NotTailRec expr -> fail (Assume_report.not_tail_rec name expr)) idents
