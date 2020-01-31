let q1 () =
      Assume.compatible "rev" [%ty: 'a list -> 'a list];
      Check.name1 "rev" [%ty: int list -> int list] 
                   ~testers: [ Autotest.(tester (list (nat 10))) ]
      [[];[1];[1;2]] ;;

let () = 
  Result.set [ Result.question "renverser une liste" ~points:3 q1 ] ;;