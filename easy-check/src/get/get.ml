open Test_env

let value ?(modname="Code") name ty = 
    match I.get_value (modname ^ "." ^ name) ty with 
    | I.Present v -> v
    | I.Incompatible msg ->
       fail ([R.Message ((Translation.translation ()).found_with_unexpected_type name msg (Ty.print ty)
                        , Failure)])
    | I.Absent -> fail ([R.Message (((Translation.translation ()).cannot_find name), Failure)])

let code ty =
   match I.get_value "Code" ty with 
    | I.Present v -> v
    | I.Incompatible m ->
       fail [R.Message ([Code m], Failure)]
    | I.Absent -> assert false

let mod_value ?modname name ty = 
  let long_name = match modname with 
                  | None -> name 
                  | Some m -> (m ^ "." ^ name) 
  in
  match I.get_value long_name ty with 
  | I.Present v -> v
  | I.Incompatible m ->
     fail [R.Message ([Code (name ^ " : " ^ m)], Failure)]
  | I.Absent ->
     fail ([R.Message (((Translation.translation ()).cannot_find name), Failure)])