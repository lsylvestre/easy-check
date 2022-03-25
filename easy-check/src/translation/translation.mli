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

val set_translation : lang -> unit


val translation : unit -> t