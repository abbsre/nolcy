# Feature: Starting Work

## Objetivo

Automatizar la preparacion del entorno de trabajo al iniciar una sesion de desarrollo.

## Entrada

1. Leer una ruta desde `path.txt`.
2. El contenido de `path.txt` representa el `working directory` comun para todas las herramientas.

## Estado actual

La version actual implementada es una v2 operativa.

1. Abre `opencode`, `lazygit` y `nvim` en consolas separadas de PowerShell.
2. Usa la ruta definida en `path.txt` como `working directory` comun.
3. Requiere al menos dos escritorios virtuales de Windows ya creados.
4. Mueve `opencode` y `lazygit` al escritorio 1.
5. Mueve `nvim` al escritorio 2.
6. Acomoda las ventanas en la pantalla principal de la PC: izquierda, derecha y maximizada.
7. Finaliza mostrando el escritorio 2 con `nvim` en primer plano.
8. Valida que ya exista soporte para mover ventanas entre escritorios virtuales antes de continuar.
9. Depende de una feature separada para preparar `VirtualDesktop`.

## Resultado esperado final

El sistema debe abrir tres consolas en Windows usando la ruta de `path.txt` como contexto:

1. En el escritorio 1, abrir PowerShell con `opencode` y ajustar la ventana al lado izquierdo de la pantalla principal de la PC.
2. En el escritorio 1, abrir PowerShell con `lazygit` y ajustar la ventana al lado derecho de la pantalla principal de la PC.
3. En el escritorio 2, abrir PowerShell con `nvim` y maximizar la ventana en la pantalla principal de la PC.

## Restricciones

1. No usar monitores externos.
2. La pantalla objetivo siempre es la pantalla principal de la PC.
3. La logica debe implementarse en un script ejecutable de Windows.
4. Todas las herramientas deben iniciarse usando el mismo `working directory`.
5. La asignacion de escritorios usa la numeracion visible para el usuario: escritorio 1 y escritorio 2.
6. El script no crea escritorios virtuales nuevos.
7. El script no instala ni descarga dependencias automaticamente.
8. La preparacion de `VirtualDesktop` se resuelve en una feature independiente.

## Comportamiento minimo esperado en v2

1. Validar que `path.txt` exista.
2. Validar que la ruta dentro de `path.txt` exista antes de abrir las herramientas.
3. Si falta el archivo o la ruta no existe, detener la ejecucion con un error claro.
4. Abrir cada herramienta en una nueva consola de PowerShell.
5. Validar que `opencode`, `lazygit` y `nvim` existan en `PATH` antes de abrirlas.
6. Validar que existan al menos dos escritorios virtuales antes de ubicar ventanas.
7. Mover `opencode` y `lazygit` al escritorio 1.
8. Mover `nvim` al escritorio 2.
9. Aplicar la disposicion de ventanas en la pantalla principal: izquierda para `opencode`, derecha para `lazygit` y maximizada para `nvim`.
10. Mostrar el escritorio 2 al finalizar para dejar `nvim` listo para uso inmediato.
11. Fallar con un mensaje claro si faltan escritorios virtuales o el soporte necesario para mover ventanas.

## Dependencias operativas

1. El script depende del modulo `VirtualDesktop` version `1.5.11`.
2. El modulo puede existir instalado en el sistema o disponible localmente en `.tools/VirtualDesktop.1.5.11`.
3. La preparacion local del modulo se documenta en `.agents/features/setup_virtualdesktop.md`.
4. Si el modulo no existe en ninguna de esas ubicaciones, el script falla y no intenta instalarlo.

## Archivos de implementacion

1. `start-work.ps1`: script principal.
2. `start-work.bat`: lanzador para ejecutar el script con doble clic o desde `cmd`.
3. `path.txt.example`: ejemplo del formato esperado para `path.txt`.
4. `.tools/VirtualDesktop.1.5.11/`: ubicacion opcional para una copia local ya disponible del modulo.
5. `setup-virtualdesktop.ps1`: script de preparacion de la dependencia.
6. `setup-virtualdesktop.bat`: lanzador del setup de la dependencia.

## Criterios de aceptacion de v2

1. Ejecutar el script abre `opencode`, `lazygit` y `nvim` sin pedir pasos manuales intermedios.
2. Las tres herramientas usan el directorio definido en `path.txt`.
3. Si existen menos de dos escritorios virtuales, el script falla y le indica al usuario que debe crear el escritorio faltante manualmente.
4. `opencode` y `lazygit` quedan abiertos en el escritorio 1.
5. `nvim` queda abierto en el escritorio 2.
6. `opencode` queda visible a la izquierda en la pantalla principal cuando se muestra el escritorio 1.
7. `lazygit` queda visible a la derecha en la pantalla principal cuando se muestra el escritorio 1.
8. `nvim` queda maximizado en la pantalla principal cuando se muestra el escritorio 2.
9. El script termina dejando visible el escritorio 2.
10. Si la configuracion de entrada es invalida, el script falla con un mensaje entendible.
11. Si falta alguno de los comandos requeridos, el script falla con un mensaje entendible.
12. Si el soporte para escritorios virtuales no esta disponible, el script falla sin instalar nada por su cuenta.
