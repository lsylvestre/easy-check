let q1 () =
  Assume.compatible "identity" [%ty : 'a -> 'a]; 
  Check.name1 "identity" [%ty : unit -> unit]  
     [();()]

let q2 () =
  Check.name1 "fact" [%ty : int -> int] 
    ~testers: [ Autotest.(tester (nat 21)) ]
    [0;3;6]

let q3 () =
  Check.name2 "puiss" [%ty : int -> int -> int] 
    ~testers: [ Autotest.(tester (tuple2 (nat 5) (nat 5)));
                Autotest.(tester (tuple2 (nat 10) (nat 15))) ]
    [(2,8)]

let q4 () =
  let module Code = struct 
        let map = Get.value "map" [%ty: ('a -> 'b) -> 'a list -> 'b list]
      end in
  Check.expr1 
      (let e = Code.map string_of_int 
       and e' = Solution.map string_of_int
       and es = "map string_of_int" in
       (e,e',es))    
      [%ty: int list -> string list] 
      ~testers: [ Autotest.(tester (list (nat 100))) ] 
      [[];[0];[0;1]]

let q5 () = 
  Assume.using "odd" ["even"];
  Assume.using "even" ["odd"];
  let test_parity source = 
    Check.name1 source [%ty: int -> bool]    
        ~testers:  [ Autotest.(tester (nat 100)) ]
        [200;201]
  in
  test_parity "odd" @ test_parity "even"

(** set result *)
let () =
  Result.set (Result.questions [q1;q2;q3;q4])