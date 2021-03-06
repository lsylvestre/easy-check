open Protect

let default_stdout_equal = ref (fun s1 s2 -> true)
let default_stderr_equal = ref (fun s1 s2 -> true)

(* module utilitaire non fournit dans l'interface *)            
module Check_tools = struct
  module Wrap : 
  sig   
    type 'a testresult = ('a * stdio * stderr) Test_lib.result
    and stdio = string
    and stderr = string

    val equalize : 
      ?equal:('a -> 'a -> bool) ->
      ?exn_equal:(exn -> exn -> bool) ->
      ?stdout_equal:(stdio -> stdio -> bool) -> 
      ?stderr_equal:(stderr -> stderr -> bool) -> 
      unit ->
      ('a testresult -> 'a testresult -> bool)
               
    val instance :
      code:('a -> 'b) ->
      solution:('a -> 'b) ->
      uncurry:(('a -> 'b) -> ('c -> 'd)) ->
      ?equal:('d -> 'd -> bool) ->
      ?exn_equal:(exn -> exn -> bool) ->
      ?stdout_equal:(stdio -> stdio -> bool) ->
      ?stderr_equal:(stdio -> stdio -> bool) ->
      unit ->
      ('c, 'd testresult) Falsify.instance
  end = 
    struct
      type 'a testresult = ('a * stdio * stderr) Test_lib.result
      and stdio = string
      and stderr = string
      (** equalize prend une fonction d'égalité entre valeurs de type 'a, 
          et deux fonctions d'égalité sur stdio et stderr,
          et rend une fonction d'égalité entre valeurs de type 'a testresult *)
      let equalize ?(equal=(=)) ?(exn_equal=(=)) ?(stdout_equal=(!default_stdout_equal)) ?(stderr_equal=(!default_stderr_equal)) () = 
        (fun v1 v2 ->
          match v1,v2 with
          | Error Undefined,_ | _,Error Undefined -> raise Undefined
          | Error e, Error e' -> exn_equal e e' 
          | Ok (x1,stdout1,stderr1), Ok (x2,stdout2,stderr2)
            -> (equal x1 x2) && (stdout_equal stdout1 stdout2) && (stderr_equal stderr1 stderr2)
          | _ -> false )

      let instance ~code ~solution ~uncurry ?equal ?exn_equal ?stdout_equal ?stderr_equal () =
        let exec f x = T.exec (fun () -> f x) in
        let w_test   = exec (uncurry code)
        and w_expect = exec (uncurry solution) in
        Falsify.{ 
            code   = w_test;
            solution = w_expect;
            equal  = equalize ?equal ?exn_equal ?stdout_equal ?stderr_equal ()
        }
    end

  module Default_tester = struct 
    exception Abort
    let tester samples = 
      (fun prop ->
        let counterexample = ref None in
        try 
          let falsify x = 
            match Falsify.falsify prop x with
              | None -> ()
              | ex -> counterexample := ex; raise Abort in
          List.iter falsify samples;
          None
      with Abort -> !counterexample)
    end
end



module Check_report :
  sig
    val correct_expression : ?message:string -> string -> Report.t

    val make_report :
      string -> ('a -> string) -> 'a -> 'a -> Report.t

    val make_report_from_counterexample :
      ('b -> 'b -> bool) ->
      string ->
      ('a -> string) ->
      ('b -> string) ->
      ('a, 'b Check_tools.Wrap.testresult) Falsify.counterexample -> 
      Report.t

  end = struct 
    let correct_expression ?(message="seems correct") source = 
      let message = [R.Text "The following expression:"; R.Break;
                     R.Output source; R.Text (" " ^ message ^ ".") ] in
      [R.Message (message,R.Informative)]


    let string_of_exc e = 
      (* Si le code de l'étudiant affiche une exception Code.E, alors on affiche simplement "E".
         idem pour une exception Solution.E. *)
      let s = Printexc.to_string e in
      match String.index_opt s '.' with
      | None -> s
      | Some dot_pos -> let module_name = String.sub s 0 dot_pos in 
                       if module_name = "Code" || module_name = "Solution" 
                       then String.sub s (dot_pos+1) (String.length s - (dot_pos+1))
                       else s

    let incorrect_expression source ~message = 
      let m = [R.Text "The following expression:"; R.Break; R.Output source; R.Text " is incorrect."; Break] 
              @ message in
      [R.Message (m,R.Failure)]

    let string_of_exc = function
    | Match_failure _ -> "Match_failure _"
    | e -> string_of_exc e ;;

    let unexpected_value s = 
      [R.Text "... produces the following value:";
       R.Output s;
       R.Text "This is incorrect. "] 
    and unexpected_exc e =
      [R.Text "... raises the following exception:";
       R.Output (string_of_exc e);
       R.Text "This is incorrect. "]
    and unexpected_writing oc_name s =
      [R.Text   (Printf.sprintf "... writes the following string to %s: " oc_name);
       R.Output (Printf.sprintf "\"%s\"" s);
       R.Text "This is incorrect. "]

    and expected_value s =
      [R.Text "Producing the following value is correct:"; 
       R.Output s; R.Break]
    and expected_exc e = 
      [R.Text "Raising the following exception is correct:"; 
       R.Output (string_of_exc e); R.Break]
    and expected_writing oc_name s =
      [R.Text   (Printf.sprintf  "Writing the following string to %s is correct:" oc_name);
       R.Output (Printf.sprintf "\"%s\"" s); R.Break]

    let make_report source show_result tested expected = 
      let report = [R.Text "The following expression:";
                   R.Break;
                   R.Output source ; R.Break]
                   @ unexpected_value (show_result tested) @ expected_value (show_result expected) in
      [R.Message (report,R.Failure)]

    let make_report_from_counterexample equal source show_argument show_result (counterexample as c) = 
      let open Falsify in
      let r = ref [R.Text "The following expression:";
                   R.Break;
                   R.Output (source ^ " " ^ show_argument c.x0) ; R.Break] in
      let () =
        match c.code_x0,c.solution_x0 with
        | Error (Fail r) , _ | _ , Error (Fail r) -> fail r
        | Ok (y0,_,_), Error e -> 
           r := !r @ unexpected_value (show_result y0) @ expected_exc e
        | Ok (y0,stdout0,stderr0), Ok (y,stdout,stderr) -> 
           if not (equal y0 y)
           then r := !r @ unexpected_value (show_result y0) @ expected_value (show_result y);
           if stdout0 <> stdout 
           then r := !r @ unexpected_writing "stdout" stdout0 @ expected_writing "stdout" stdout;
           if stderr0 <> stderr 
           then r := !r @ unexpected_writing "stderr" stderr0 @ expected_writing "stderr" stderr
        | Error e, Error e' -> 
           r := !r @ unexpected_exc e @ expected_exc e'
        | Error e,Ok (y,_,_) 
          -> r := !r @ unexpected_exc e @ expected_value (show_result y)
        | Ok (y0,_,_),Error e  
          -> r := !r @ unexpected_value (show_result y0) @ expected_exc e
      in
      let report = !r in
      [R.Message (report,R.Failure)]
  end

module Adapter = struct

  let uncurry1 f x = f x
  and uncurry2 f (x1,x2) = f x1 x2
  and uncurry3 f (x1,x2,x3) = f x1 x2 x3
  and uncurry4 f (x1,x2,x3,x4) = f x1 x2 x3 x4
  and uncurry5 f (x1,x2,x3,x4,x5) = f x1 x2 x3 x4 x5

  (** Etant donnée un valeur (ty : (σ1 -> σ2 -> ... -> τ) Ty.ty),
        isole d'un côté la représentation des types (σ1 Ty.ty,σ2 Ty.ty, ...) 
        des arguments, et de l'autre la représentation du type du résultat τ Ty.ty. *)
  let domains1 ty = Ty.domains ty
  let domains2 ty = 
    let t1,t = Ty.domains ty in 
    let t2,r = Ty.domains t in ((t1,t2),r)
  let domains3 ty =
    let ((t1,t2),t') = domains2 ty in 
    let t3,r = Ty.domains t' in ((t1,t2,t3),r)
  let domains4 ty = 
    let ((t1,t2,t3),t') = domains3 ty in
    let t4,r = Ty.domains t' in ((t1,t2,t3,t4),r)
  let domains5 ty = 
    let ((t1,t2,t3,t4),t') = domains4 ty in
    let t5,r = Ty.domains t' in ((t1,t2,t3,t4,t5),r)

  let show1 ty v = 
    Show.show v ty
  let show2 (t1,t2) (x1,x2) = 
    show1 t1 x1 ^ " " ^ 
    show1 t2 x2
  and show3 (t1,t2,t3) (x1,x2,x3) =
    show1 t1 x1 ^ " " ^ 
    show1 t2 x2 ^ " " ^ 
    show1 t3 x3
  and show4 (t1,t2,t3,t4) (x1,x2,x3,x4) =
    show1 t1 x1 ^ " " ^ 
    show1 t2 x2 ^ " " ^ 
    show1 t3 x3 ^ " " ^ 
    show1 t4 x4
  and show5 (t1,t2,t3,t4,t5) (x1,x2,x3,x4,x5) =
    show1 t1 x1 ^ " " ^ 
    show1 t2 x2 ^ " " ^ 
    show1 t3 x3 ^ " " ^ 
    show1 t4 x4 ^ " " ^ 
    show1 t5 x5
end

type 'a testresult = 'a Check_tools.Wrap.testresult

module Safe = struct 
  open Adapter

  exception Counterexample of Report.t

  let check ~uncurry ~show_argument ~show_result 
        ~code ~solution ~source
        ?(equal=(=)) ?exn_equal ?stdout_equal ?stderr_equal ?(testers=[]) samples =
    
    let instance = 
      Check_tools.Wrap.instance ~code:code ~solution:solution ~uncurry:uncurry 
         ~equal:equal ?exn_equal ?stdout_equal ?stderr_equal () in
    try 
      let () =  
        let falsify instance tester =
          match tester instance with 
          | None -> () 
          | Some counterexemple
            -> let report = Check_report.make_report_from_counterexample equal
                              source show_argument show_result 
                              counterexemple 
               in
               fail report  
        in
        List.iter (falsify instance) (Check_tools.Default_tester.tester samples :: testers) 
      in
      Check_report.correct_expression source
    with Counterexample report -> report


let support uncurry_n domains_n show_n ty =
 let (tyx,tyr) = domains_n ty in 
 check ~uncurry:uncurry_n ~show_argument:(show_n tyx) ~show_result:(show1 tyr) 

  let arity1 ~ty = support uncurry1 domains1 show1 ty
  let arity2 ~ty = support uncurry2 domains2 show2 ty
  let arity3 ~ty = support uncurry3 domains3 show3 ty
  let arity4 ~ty = support uncurry4 domains4 show4 ty
  let arity5 ~ty = support uncurry5 domains5 show5 ty
end

let check ~show_argument = Safe.check ~uncurry:Adapter.uncurry1  ~show_argument:show_argument

let single_suport arity_n ty code apply = 
  let open Safe in
  let vcode x = apply (Get.value ~modname:"Code" code ty) x
  and vsolution = (Get.value ~modname:"Solution" code ty) in
  arity_n ~ty:ty ~code:vcode ~solution:vsolution ~source:code

open Falsify

type ('v,'args,'ret) check = 
  'v Ty.ty ->
  ?apply:('v -> 'v) -> 
  ?equal:('ret -> 'ret -> bool) ->
  ?exn_equal:(exn -> exn -> bool) ->
  ?stdout_equal:(string -> string -> bool) ->
  ?stderr_equal:(string -> string -> bool) ->
  ?testers:(('args, 'ret testresult) tester list) ->
  'args list -> Report.t

type name = string
type 'e expr = 'e * 'e * string

let identity x = x

let name1 code ty ?(apply=identity) = single_suport Safe.arity1 ty code apply
let name2 code ty ?(apply=identity) = single_suport Safe.arity2 ty code apply
let name3 code ty ?(apply=identity) = single_suport Safe.arity3 ty code apply
let name4 code ty ?(apply=identity) = single_suport Safe.arity4 ty code apply
let name5 code ty ?(apply=identity) = single_suport Safe.arity5 ty code apply


let brackets source = "(" ^ source ^ ")"

let expr1 (v,a,s) ty ?(apply=identity) = Safe.arity1 ~ty:ty ~code:(apply v) ~solution:a ~source:(brackets s)
let expr2 (v,a,s) ty ?(apply=identity) = Safe.arity2 ~ty:ty ~code:(apply v) ~solution:a ~source:(brackets s)
let expr3 (v,a,s) ty ?(apply=identity) = Safe.arity3 ~ty:ty ~code:(apply v) ~solution:a ~source:(brackets s)
let expr4 (v,a,s) ty ?(apply=identity) = Safe.arity4 ~ty:ty ~code:(apply v) ~solution:a ~source:(brackets s)
let expr5 (v,a,s) ty ?(apply=identity) = Safe.arity5 ~ty:ty ~code:(apply v) ~solution:a ~source:(brackets s)

let value_support ty code solution source equal = 
  if equal code solution 
  then Check_report.correct_expression ~message:"is correct" source
  else fail (Check_report.make_report source (fun v -> Show.show v ty) code solution)

let name code ty ?(equal=(=)) () = 
  let source = code in
  let vcode =    Get.value ~modname:"Code"     code ty
  and vsolution = Get.value ~modname:"Solution" code ty in

  value_support ty vcode vsolution source equal

let expr (code,sol,source) ty ?(equal=(=)) () = 
  value_support ty code sol source equal