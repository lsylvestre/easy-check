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
Déployer  des exercices
============================

```
$ cd demo/
$ make
## Ouvir localhost:8080
^C
$ cd ..
```

