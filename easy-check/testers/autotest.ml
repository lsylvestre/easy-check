include Samples


let tester ?(gen=100) ?(candidates=gen) ?(compare=compare) sample =
  if gen < 0 || candidates < 0 then invalid_arg "tester";
  let safe_compare x1 x2 = 
    try compare x1 x2 with _ -> -1
  in 
  (fun prop ->
    let rec aux (c,x) k = function
      | 0 -> c
      | n -> let x' = sample () in
             (match Falsify.falsify prop x' with
              | None -> aux (c,x) k (n - 1)
              | c' -> if safe_compare x' x < 0
                      then aux (c',x') (k-1) (n - 1)
                      else aux (c,x) (k-1) (n - 1))
    in
    aux (None, sample ()) candidates gen)

let tester2 ?(gen=100) ?(candidates=gen) ?(compare=compare) sample1 sample2 = 
  tester ~gen:gen ~candidates:candidates ~compare:compare (tuple2 sample1 sample2)