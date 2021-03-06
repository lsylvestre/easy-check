open Protect

let value ?(modname="Code") name ty = 
    match I.get_value (modname ^ "." ^ name) ty with 
    | I.Present v -> v
    | I.Incompatible msg -> 
       fail ([R.Message ([Text "Found"; 
                          Code name;
                          Text "with unexpected type:";
                          Break;
                          Code msg], Failure)])
    | I.Absent -> fail ([R.Message ([Text "Cannot find " ;
                                     Code name ;Text "."], Failure)])

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
     fail ([R.Message ([ Text "Cannot find " ;
                         Code name ], Failure)])