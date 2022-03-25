
let identity x = x

let rec fact = function
| 0 -> 1
| n -> n * fact (n - 1)

let rec map f = function
| [] -> []
| h::t -> let x = f h in x :: map f t

let rec even n = n = 0 || odd (pred n)
and odd n = n > 0 && even (pred n)