# Release tags

## Formato

1. Los tags de release deben seguir el formato `VYYMMDDhhmm`.
2. El formato usa `V` mayuscula, fecha de dos digitos y hora/minuto en formato 24 horas.
3. Ejemplo valido: `V2606161435`.
4. La parte `hhmm` permite crear varios releases durante el mismo dia sin colisiones.

## Comentario del tag

1. Cada release tag debe ser anotado.
2. El comentario del tag debe resumir los cambios incluidos desde el release anterior.
3. Para preparar el comentario, revisar los commits entre el tag anterior y el nuevo punto de release.
4. El comentario debe describir el comportamiento entregado, no una lista generica de tareas.

## CI/CD

1. El workflow `.github/workflows/release.yml` se ejecuta cuando se publica un tag que empieza con `V`.
2. El workflow solo crea release si el tag cumple `VYYMMDDhhmm`, por ejemplo `V2606161435`.
3. El workflow compila `desktop-app/Nocly.exe` en un runner Windows.
4. El release adjunta un unico archivo `nocly-<tag>-windows.zip`.
5. El zip debe contener solo lo necesario para ejecutar Nocly en Windows: `desktop-app/Nocly.exe`, `desktop-app/projects.example.txt`, `start-work.bat`, `start-work.ps1` y `.tools/VirtualDesktop.1.5.11`.
6. El zip no debe incluir `desktop-app/projects.txt` ni archivos generados de estado local.
7. Las notas del GitHub release se generan desde los commits incluidos entre releases.
