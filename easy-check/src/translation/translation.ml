open Test_env 

type t = {
    (* Protect *)
    not_yet_implemented : string;
    the_following_exception_is_raised_and_never_caught : string;
    (* Check *)
    seems_correct : string;
    is_incorrect : string;
    the_following_expression : string;
    produces_the_following_value : string;
    this_is_incorrect : string;
    raises_the_following_exception: string;
    writes_the_following_string_to: string -> string;
    producing_the_following_value_is_correct : string;
    raising_the_following_exception_is_correct : string;
    writing_the_following_string_is_correct : string -> string;
    (* Get *)
    found_with_unexpected_type : string -> string -> string -> R.text;
    (* Assume *)
    cannot_find : string -> R.text;
    incompatible : R.text;
    unexpected_compatible : string -> R.text;
    should_not_use : string -> string -> R.text;
    should_use : string -> string -> R.text;
    should_be_tail_rec : string -> string -> R.text
  }
type lang = Fr | En

let messages_en = {

    not_yet_implemented =
       "Not yet implemented.";
    
    the_following_exception_is_raised_and_never_caught =
       "The following exception is raised and never caught:";

    seems_correct =
      "seems correct.";
    
    is_incorrect =
      "is incorrect.";
    
    the_following_expression =
      "The following expression:";
    
    produces_the_following_value =
      "produces the following value:";
    
    this_is_incorrect =
      "This is incorrect.";
    
    raises_the_following_exception =
      "raises the following exception:";
    
    writes_the_following_string_to =
      (fun oc_name -> "writes the following string to " ^ oc_name ^ ":");
    
    producing_the_following_value_is_correct =
      "Producing the following value is correct:";
    
    raising_the_following_exception_is_correct =
      "Raising the following exception is correct:";
    
    writing_the_following_string_is_correct =
      (fun oc_name -> "Writing the following string to " ^ oc_name ^ " is correct:");

    found_with_unexpected_type = 
(fun name compiler_msg ty_descr ->
  [Text "Found"; 
         Code name;
         Text "with unexpected type.";
         Break;
         Text " The compiler message is :";
         Break;
         Output compiler_msg;
         Break;
         Text "The expected type is:";
         Output ty_descr;
      ]);
    
    cannot_find =
      (fun name -> [ R.Text "Cannot find"; R.Output name ;R.Text "."]);
    
    incompatible =
      [R.Text  "Your code is not compatible with the expected signature:"];
    
    unexpected_compatible =
      (fun name ->
        [R.Code name;
         R.Text " is compatible with an unexpected type:"]);
    
    should_not_use =
      (fun x y -> [R.Code x; 
                   R.Text " should not use "; 
                   R.Code y; 
                   R.Text "."]);
    
    should_use =
      (fun x y -> [R.Code x; 
                   R.Text " should use "; 
                   R.Code y; 
                   R.Text "."]);
    
    should_be_tail_rec =
      (fun x expr_descr ->
        [ R.Code x;
          R.Text " should be tail-recursive.";
          R.Break;
          R.Text "The recursive call in :";
          R.Output expr_descr;
          R.Break;
          R.Text "is not in tail position.";
      ] );
  }
                

let messages_fr = {

    not_yet_implemented =
       "Vous n'avez pas encore répondu à cette question.";
    
    the_following_exception_is_raised_and_never_caught =
       "L'exception suivante est lancée et jamais rattrapée :";

    seems_correct =
      "semble correcte.";
    
    is_incorrect =
      "est incorrecte.";
    
    the_following_expression =
      "L'expression suivante :";
    
    produces_the_following_value =
      "produit la valeur :";
    
    this_is_incorrect =
      "C'est incorrect.";
    
    raises_the_following_exception =
      "lance l'exception suivante :";
    
    writes_the_following_string_to =
      (fun oc_name -> "écrit la chaîne suivante sur " ^ oc_name ^ " :");
    
    producing_the_following_value_is_correct =
      "Je m'attendais à recevoir la valeur :";
    
    raising_the_following_exception_is_correct =
      "Je m'attendais à rattraper l'exception :";
    
    writing_the_following_string_is_correct =
      (fun oc_name -> "je m'attendais à lire sur " ^ oc_name ^ " la chaîne :");

    found_with_unexpected_type = 
(fun name compiler_msg ty_descr ->
  [Text "J'ai trouvé"; 
         Code name;
         Text "avec un type inattendue.";
         Break;
         Text " Le message du compilateur est :";
         Break;
         Output compiler_msg;
         Break;
         Text "Le type attendu est :";
         Output ty_descr;
      ]);
    
    cannot_find =
      (fun name -> [ R.Text "Je ne trouve ";
                     R.Output name ;
                     R.Text "."]);
    
    incompatible =
      [R.Text "Votre code est compatible avec une signature inattendue :"];
    
    unexpected_compatible =
      (fun name -> [R.Code name;
                    R.Text " est compatible avec un type inattendu :"]);
    
    should_not_use =
      (fun x y -> [R.Code x; 
                   R.Text " ne devrait pas utiliser "; 
                   R.Code y; 
                   R.Text "."]);
    
    should_use =
      (fun x y -> [R.Code x; 
                   R.Text " devrait utiliser "; 
                   R.Code y; 
                   R.Text "."]);

    should_be_tail_rec =
      (fun x expr_descr ->
        [ R.Code x;
          R.Text " devrait être récursive terminale.";
          R.Break;
          R.Text "L'appel récursif dans :";
          R.Output expr_descr;
          R.Break;
          R.Text "n'est pas en position terminale.";
      ] );
  }
                
let messages_lang = ref messages_fr

let set_translation lang = 
  messages_lang := (match lang with
                    | En -> messages_en
                    | Fr -> messages_fr)


let translation () = !messages_lang

