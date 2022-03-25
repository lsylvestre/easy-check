# Exercice - demo.
---------

### Q.3.1 
Définissez la fonction `identity : 'a -> 'a` , qui rend son argument intact.

### Q.3.2 
Définissez une fonction  `fact : int -> int` calculant la factorielle.

### Q.3.3
 Définissez la fonction map de type `('a -> 'b) -> 'a list -> 'b list`, telle que `map f l` applique la fonction `f` à tous les éléments de la liste `l`.

### Q.3.4
Définissez une fonction `even` de type `int -> bool` rendant true si son argument est pair, false sinon, et une fonction `odd` de type `int -> bool`  rendant true si son argument est impair, false sinon. 

Si dans votre solution `even` et `odd` ne sont pas mutuellement récursives, redéfinissez-les de manière mutuellement récursive et en n’utilisant pour seule fonction arithmétique que le prédécesseur `(let pred n = n − 1;;)`.




### Q.3.1 

<style>
table, th, td {
  border: 1px solid black;
}
</style>
 <table>
  <tr><th>AA</th><th>BB</th><th>CC</th></tr>
  <tr><td>aa</td><td>bb</td><td>cc</td></tr>
  <tr><td>11</td><td>22</td><td>33</td></tr>
</table>