open Protect

type question = Protect.question

(** fonction auxiliaire.
  (make_report q) corrige la question q. *)
let make_report ~title ~points (q : question) : question =
  (fun () ->
    set_progress ("Grading " ^ title);
    match Protect.protect
              (fun () -> 
               [R.Message ([], R.Success points)] 
               @ q ()) with
    | [] -> []
    | report -> [R.section ~title:title report])


let question title ?(points=1) q =
  make_report ~title:title ~points:points q 

let questions ?(prefix="Question") ?(points=1) lq =
    let make_question i q =
      let title = Printf.sprintf "%s %d" prefix (i+1) in 
      question title ~points:points q in
    List.mapi make_question lq


let set ?(forbidden_modules=[]) questions = 
  T.set_result
     (T.ast_sanity_check 
         ~modules:forbidden_modules 
         code_ast (fun () -> List.concat (List.map Protect.protect questions)))

let handler f =
  try f () with Fail r ->
  (T.set_result r)