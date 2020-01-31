let q1 () = 
	Check.name1 "fact" [%ty: int -> int] 
                ~testers: [ Autotest.(tester (nat 20)) ] 
                [1;4;9;17] ;;

let q2 () = 
	Check.name1 "fib" [%ty: int -> int]
                ~testers: [ Autotest.(tester (nat 30)) ] 
                [5;8;9] ;;

let q3 () = 
	Check.name2 "pow" [%ty: int -> int -> int] 
                ~testers: [ Autotest.(tester2 (nat 30) (nat 10)) ] 
                [(2,8)] ;;

let () = 
  Result.set (Result.questions [q1;q2;q3]) ;;