let show v ty = 
  let typed_printer ty ppf v = Introspection.print_value ppf v ty in
  Format.asprintf "%a" (typed_printer ty) v