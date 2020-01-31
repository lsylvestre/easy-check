let rec fact = function
| 0 -> 1
| n -> n * fact (n-1)

let fib n =
	let rec f a b = function 
	| 0 -> b
	| n -> f b (a+b) (n-1) in f 0 1 n

let rec pow a = function
| 0 -> 1
| n -> a * pow a (n-1)