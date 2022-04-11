# easy-check
------------

```bash
$ git clone https://github.com/ocaml-sf/learn-ocaml.git
$ cd learn-ocaml
$ opam switch create for-learn-ocaml ocaml-base-compiler.4.12.0
$ opam install opam-installer
$ eval $(opam env)
$ opam install . --deps-only
$ make && make opaminstall
$ make testrun
    ## Ouvir localhost:8080
^C
$ cd ../demo
$ make
^C
$ make clean
````
