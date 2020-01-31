(** Runtime library for an other customisation of 'ppx_metaquot'.

    let (e1,e2,show) = [%code : e];;

    [%code : e] = `(let open Code in ~e, let open Solution in ~e, ~(Expr.print e))

    for instance,
    [%code : (fun x -> x + 1)] ==> (let open Code in (fun x -> x + 1),
                                    let open Solution in (fun x -> x + 1),
                                    "(fun x -> x + 1)")
*)

let print = Pprintast.string_of_expression