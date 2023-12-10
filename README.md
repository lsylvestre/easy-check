# easy-check
------------

```shell-session
$ opam switch create for-learn-ocaml --packages ocaml.4.12.0,learn-ocaml
$ eval $(opam env)      # Only needed if you disabled opam's shell hooks
$ dune build @install && dune install
$ learn-ocaml build serve --repo=./demo
````
