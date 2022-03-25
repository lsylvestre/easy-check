open Test_env

type question = {
   title: string; 
   points:int;
   test: (unit -> Report.t)
}

let question title ?(points=1) fq =
    {title=title;points=points;test=fq}

let questions ?(prefix="Question") ?(points=1) lfq =
    let make_question i fq =
      let title = Printf.sprintf "%s %d" prefix (i+1) in 
      question title ~points:points fq in
    List.mapi make_question lfq

(** fonction auxiliaire.
  (make_report q) corrige la question q. *)
let make_report (q : question) : Report.t =
  set_progress ("Grading " ^ q.title);
  match Protect.protect
            (fun () -> 
             [R.Message ([], R.Success q.points)] 
             @ q.test ()) with
  | [] -> []
  | report -> [R.section ~title:q.title report]

let set ?(forbidden_modules=[]) questions = 
  T.set_result
     (T.ast_sanity_check 
         ~modules:forbidden_modules 
         code_ast (fun () -> List.concat (List.map make_report questions)))

let handler f =
  try f () with Fail r ->
  (T.set_result r)