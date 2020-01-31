include module type of Samples

val tester : ?gen:int -> ?candidates:int -> ?compare:('a -> 'a -> int) -> 'a sampler -> ('a,'b) Falsify.tester

val tester2 : ?gen:int -> ?candidates:int -> ?compare:(('a * 'b) -> ('a * 'b) -> int) -> 'a sampler ->  'b sampler -> ('a * 'b,'c) Falsify.tester