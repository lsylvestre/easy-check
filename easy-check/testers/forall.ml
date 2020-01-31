include Samples

(** fonctions auxiliaires : 
    (iter_n f (l1,l2,...,ln)) parcours le produit cartesien de l1,l2,...,ln 
    en appliquant la fonction f à chaque n-uplet à (x1,x2,...,xn) *)
module Product :  sig
    val iter : ('a -> unit) -> 'a list -> unit
    val iter2 : ('a * 'b -> unit) -> 'a list * 'b list -> unit
    val iter3 :
          ('a * 'b * 'c -> unit) -> 'a list * 'b list * 'c list -> unit
    val iter4 :
          ('a * 'b * 'c * 'd -> unit) ->
          'a list * 'b list * 'c list * 'd list -> unit

end = struct
  
  let iter f l = List.iter f l 

  let iter2 f (l1,l2) =
    (List.iter (fun e1 -> 
      List.iter (fun e2 -> 
        f (e1,e2)) 
    l2) 
  l1)

let iter3 f (l1,l2,l3) =
  (List.iter 
    (fun e1 -> List.iter 
      (fun e2 -> List.iter 
        (fun e3 -> f (e1,e2,e3)) 
      l3) 
    l2) 
  l1)

let iter4 f (l1,l2,l3,l4) =
  (List.iter 
    (fun e1 -> List.iter 
      (fun e2 -> List.iter 
        (fun e3 -> List.iter 
          (fun e4 -> f (e1,e2,e3,e4))
        l4) 
      l3) 
    l2) 
  l1)
end

module Testers = struct
  exception Abort

  let main_tester iter samples = 
    (fun prop ->
      let counterexample = ref None in
      let f x = 
        match Falsify.falsify prop x with
        | None -> ()
        | ex -> counterexample := ex; raise Abort 
      in
      (try iter f samples with Abort -> ());
      !counterexample)
     
  let tester l = 
    main_tester Product.iter l
  let tester2 l1 l2 = 
    main_tester Product.iter2 (l1,l2)
  let tester3 l1 l2 l3 = 
    main_tester Product.iter3 (l1,l2,l3)
  let tester4 l1 l2 l3 l4 = 
    main_tester Product.iter4 (l1,l2,l3,l4)
end

module Tools = struct
  let sublist ?(keep=(fun _ -> Random.bool ())) l = 
    List.filter keep l

  let oneof = function
  | [] -> failwith "oneof"
  | l -> let k = List.length l in 
         List.nth l (Random.int k) 

  let support_product iter lists = 
    let acc = ref [] in
    iter (fun x -> acc := x :: !acc) lists;
    !acc

  let product2 a1 a2 = 
    support_product Product.iter2 (a1,a2)

  let product3 a1 a2 a3 = 
    support_product Product.iter3 (a1,a2,a3)

  let product4 a1 a2 a3 a4 = 
    support_product Product.iter4 (a1,a2,a3,a4)
end

include Testers
include Tools