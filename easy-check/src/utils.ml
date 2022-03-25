
(* List.init absent in OCaml 4.05 *)   
let list_init n f =                          
  let rec aux l = function 
  | 0 -> l
  | n -> aux (f n :: l) (n - 1) in
  aux [] n 