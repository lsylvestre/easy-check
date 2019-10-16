
type question

val question : 
  string -> ?points:int -> (unit -> Report.t) -> question

val questions :
  ?prefix:string -> ?points:int -> (unit -> Report.t) list -> question list

val set :
  ?forbidden_modules:string list -> question list -> unit

val handler : (unit -> unit) -> unit