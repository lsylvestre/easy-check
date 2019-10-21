(*let split l = 
	let rec aux a1 a2 = function
	| [] -> (List.rev a1,List.rev a2)
	| h :: t ->  aux a2 (h::a1) t in
	aux [] [] l

let rec merge l1 l2 = 
	match (l1,l2) with
    [],_ -> l2
	| _,[] -> l1
 	| t1::q1,t2::q2 -> if t1 < t2 then t1::(merge q1 l2) 
                       else t2::(merge l1 q2);;

let rec sort = function 
	 [] -> []
   | [_] as s -> s
   | l -> let l1,l2 = split l in 
          merge (sort l1) (sort l2)

*)
let split l1 =
  let half_len = List.length l1 / 2 in
  let rec aux i left right =
    match right with
    | right when i >= half_len -> List.rev left, right
    | head :: tail -> aux (i + 1) (head :: left) tail
  in
  aux 0 [] l1

let merge l1 l2 =
  let rec aux acc l1 l2 = 
    match l1, l2 with
    | [], l2 -> List.rev acc @ l2
    | l1, [] -> List.rev acc @ l1
    | head1 :: tail1, head2 :: tail2 -> 
      if head1 <= head2 then
        aux (head1 :: acc) tail1 l2
      else
        aux (head2 :: acc) l1 tail2
  in
  aux [] l1 l2

let rec sort l =
  match l with
  | [] -> []
  | [x] -> [x]
  | [x1; x2] -> if x1 <= x2 then [x1; x2] else [x2; x1]
  | l ->
    let l1, l2 = split l in
    merge (sort l1) (sort l2)

