
type question = unit -> Report.t

val question : 
  string -> ?points:int -> question -> question

val questions :
  ?prefix:string -> ?points:int -> question list -> question list

val set :
  ?forbidden_modules:string list -> question list -> unit

val handler : (unit -> unit) -> unit