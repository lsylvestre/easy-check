
let identity x = x

let rec fact = function
| 0 -> 1
| n -> n * fact (n - 1)

let puiss a b =
	if b < 0 then failwith "puiss" else
	let rec aux a = function
	| 0 -> 1
	| 1 -> a
	| n ->  if n mod 2 = 0 then let p = aux a (n / 2) in p * p
	        else let p = aux a ((n - 1) / 2) in p * p * a 
	in aux a b

let rec map f = function
| [] -> []
| h::t -> let x = f h in x :: map f t

let rec even n = n = 0 || odd (pred n)
and odd n = n > 0 && even (pred n)