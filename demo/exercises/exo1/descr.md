# Exercice 3 : Les classiques
---------

### Q.3.1 
Définissez la fonction `identity : 'a -> 'a` , qui rend son argument intact.

### Q.3.2 
Définissez une fonction  `fact : int -> int` calculant la factorielle.

### Q.3.3
Définissez une fonction `puiss : int -> int - int` calculant la puissance.

### Q.3.4
La fonction calculant le n-ième nombre de la suite de Fibonacci peut être ainsi définie pour tout nombre entier positif :

- fib(0) = 1
- fib(1) = 1
- fib(n) = fib(n − 2) + fib(n − 1)

Écrivez cette fonction, de type `int -> int`.

### Q.3.5
Définissez une fonction fib2 : `int -> int`, version de complexité linéaire pour le calcul de n-ième nombre de la suite de Fibonacci.

### Q.3.6
 Définissez la fonction map de type `('a -> 'b) -> 'a list -> 'b list`, telle que `map f l` applique la fonction `f` à tous les éléments de la liste `l`.
### Q.3.7
Définissez une fonction `even` de type `int -> bool` rendant true si son argument est pair, false sinon, et une fonction `odd` de type `int -> bool`  rendant true si son argument est impair, false sinon. 

Si dans votre solution `even` et `odd` ne sont pas mutuellement récursives, redéfinissez-les de manière mutuellement récursive et en n’utilisant pour seule fonction arithmétique que le prédécesseur `(let pred n = n − 1;;)`.
