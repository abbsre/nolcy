# Release tags

## Formato

1. Los tags de release deben seguir el formato del ultimo tag creado.
2. El formato actual es `vYYMMDD`, por ejemplo `v260616`.
3. Si ya existe un tag para el mismo dia, mantener el prefijo `vYYMMDD` y extenderlo solo con la precision necesaria para evitar colisiones, siguiendo el formato del tag mas reciente disponible.

## Comentario del tag

1. Cada release tag debe ser anotado.
2. El comentario del tag debe resumir los cambios incluidos desde el release anterior.
3. Para preparar el comentario, revisar los commits entre el tag anterior y el nuevo punto de release.
4. El comentario debe describir el comportamiento entregado, no una lista generica de tareas.
