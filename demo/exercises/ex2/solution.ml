let rev l = 
  let rec aux a = function
  | [] -> a
  | h::t -> aux (h::a) t in aux [] l