Installer "learn-ocaml étendu"
============================
```
$ cd learn-ocaml++
$ opam switch create for-learn-ocaml 4.05.0
$ opam install opam-installer
$ eval $(opam env)
$ opam install . --deps-only
$ make && make opaminstall
$ make testrun
    ## Ouvir localhost:8080
^C
$ cd ..
````
Déployer  les exercices
============================

## TDs de MPIL
```
$ cd learn-ocaml_exercices/td-3I008
$ make
   ## Ouvir localhost:8080
^C
$ cd ..
```
## Projet ORUSH de MPIL
```
$ cd learn-ocaml_exercices/orush-3I008
$ make
## Ouvir localhost:8080
^C
$ cd ..
```
## Ouverture (MU4IN511)
```
$ cd learn-ocaml_exercices/MU4IN511
$ make
## Ouvir localhost:8080
^C
$ cd ..
```
