let () = 
    Random.self_init ();;

type 'a sampler = unit -> 'a

let tester ?(gen=100) ?(candidates=(max 1 (gen/10))) ?(compare=compare) sample =
  if gen < 0 || candidates < 0 then invalid_arg "tester";
  let safe_compare x1 x2 = 
    try compare x1 x2 with _ -> -1
  in 
  (fun prop ->
    let rec aux (c,x) k = function
      | 0 -> c
      | n -> let x' = sample () in
             (match Check_support.falsify prop x' with
              | None -> aux (c,x) k (n - 1)
              | c' -> if safe_compare x' x < 0
                      then aux (c',x') (k-1) (n - 1)
                      else aux (c,x) (k-1) (n - 1))
    in
    aux (None, sample ()) candidates gen)

let choose x y a = (if Random.bool () then x else y) a ;;

let range (a:int) (b:int) : int =  Random.int (b - a) + a 

let const c () = c

let oneof l () = List.nth l (Random.int (List.length l))

let unit () = ()
let bool () = Random.bool ()

let nat max () = 
  if max < 0 then invalid_arg "nat" else Random.int (max+1)

let int a b () = 
  if b < a then invalid_arg "int";
  let nat a b = range a (b+1)
  and choose a b = if Random.bool () then a else b
  in 
  if a < 0 && b < 0 then - (nat (-b) (-a))
  else if a < 0 then choose (nat a 0) (nat 1 b)
  else (nat a b)

let float (a:int) (b:int) () = 
  if b < a then invalid_arg "float";
  if a = b then float_of_int a else 
  float_of_int (int a (b-1) ()) +. Random.float 1.

let char a b () = 
  let c1 = Char.code a
  and c2 = Char.code b in
  if c2 < c1 then invalid_arg "char";
  Char.chr (range c1 c2)

let char_az = char 'a' 'z'
let char_09 = char '0' '9'

let string ?(length=(int 0 5)) char () = 
  let l = length () in
  if l < 0 then  invalid_arg "string";
  String.init l (fun _ -> char ())
   
let list ?(length=(int 0 5)) s () =
  let l = length () in
  if l < 0 then invalid_arg "list";
  let rec aux = function
  | 0 -> []
  | n -> s () :: aux (n-1) in aux l

let array ?(length=(int 0 5)) s () = 
  let l = length () in
  if l < 0 then invalid_arg "array";
  Array.init l (fun _ -> s ())

let sublist ?(keep=bool) l () = 
  List.filter (fun _ -> bool ()) l


let tuple2 s1 s2 () = (s1 (), s2 ())
let tuple3 s1 s2 s3 () = (s1 (), s2 (), s3 ())
let tuple4 s1 s2 s3 s4 () = (s1 (), s2 (), s3 (), s4 ())
let tuple5 s1 s2 s3 s4 s5 () = (s1 (), s2 (), s3 (), s4 (), s5 ())

let option ?(frequency=(fun () -> Random.int 6 = 0)) s () =
  if frequency () then None else Some (s ())

let tree ?(depth=(int 2 5)) leaf node () = 
  let d = depth () in
  if d < 0 then invalid_arg "tree";
  let rec aux = function
  | 0 -> leaf () 
  | n -> node (fun () -> aux (n-1)) in
  aux d

let wrap g f = (fun () -> f (g ()))


(***************
 exemple :

type expr = Mul of expr * expr | Add of expr * expr | Const of int  

let sampler_expr =
  tree (fun () -> Const (int 0 100 ())) 
       (fun tree -> if bool () 
                    then Add (tree (), tree ()) 
                    else Mul (tree (), tree ()))
   *************)
