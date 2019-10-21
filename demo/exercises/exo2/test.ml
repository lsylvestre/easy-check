let sort = List.sort compare

let q1 () =
  Assume.compatible "merge" [%ty: 'a list -> 'a list -> 'a list];
  Check.name2 "merge" [%ty : int list -> int list -> int list]     
    ~testers:    [ Autotest.(tester (tuple2 (wrap (list (nat 30)) sort)
                                            (wrap (list (nat 30)) sort))) ]
    [([],[]); ([],[2]); ([],[1;2]); ([1],[]); ([1;2],[]);
     ([1],[1]); ([1],[2]); ([1;2],[3;4]); ([1;3],[2;4]);
     ([2;4],[1;3]); ([1;5;10],[0;7;11])]

let q2 () =
  Assume.using "sort" ["merge"];
  Assume.compatible "sort" [%ty: 'a list -> 'a list];
  Check.name1 "sort" [%ty : int list -> int list]       
    ~testers:    [ Autotest.(tester (list (nat 20))) ]
    [[];[0];[0;0];[1;0];[2;1;0];[1;2;0]]

(** set result *)
let () =
  Result.set (Result.questions ~prefix:"Q" [q1;q2;q3])