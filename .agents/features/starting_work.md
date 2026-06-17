# Feature: Starting Work

## Objetivo

Automatizar la preparacion del entorno de trabajo al iniciar una sesion de desarrollo.

## Entrada

1. Leer una ruta desde el parametro `ProjectPath` o desde `path.txt`.
2. Si existe `ProjectPath`, esa ruta tiene prioridad sobre `path.txt`.
3. Leer el editor desde el parametro `Editor`.
4. Si no se recibe `Editor`, usar `vscode` por defecto.
5. La ruta resultante representa el `working directory` comun para todas las herramientas.

## Estado actual

La version actual implementada es una v2 operativa.

1. Abre `opencode`, `lazygit` y un editor seleccionado entre `vscode` y `nvim`.
2. Usa la ruta recibida por parametro o la ruta definida en `path.txt` como `working directory` comun.
3. Requiere al menos dos escritorios virtuales de Windows ya creados.
4. Mueve `opencode` y `lazygit` al escritorio 1.
5. Mueve el editor seleccionado al escritorio 2.
6. Acomoda las ventanas en la pantalla principal de la PC: izquierda, derecha y maximizada.
7. Finaliza mostrando el escritorio 2 con el editor en primer plano.
8. Valida que ya exista soporte para mover ventanas entre escritorios virtuales antes de continuar.
9. Depende de una feature separada para preparar `VirtualDesktop`.

## Resultado esperado final

El sistema debe abrir `opencode`, `lazygit` y un editor usando la ruta resuelta como contexto:

1. En el escritorio 1, abrir `opencode` y ajustar la ventana al lado izquierdo de la pantalla principal de la PC.
2. En el escritorio 1, abrir `lazygit` y ajustar la ventana al lado derecho de la pantalla principal de la PC.
3. En el escritorio 2, abrir el editor seleccionado y maximizar su ventana en la pantalla principal de la PC.

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

1. Validar que exista una ruta valida recibida por parametro o en `path.txt`.
2. Si falta la ruta o no existe, detener la ejecucion con un error claro.
3. Abrir `opencode` y `lazygit` en nuevas consolas.
4. Abrir `nvim` en consola cuando ese editor fue seleccionado.
5. Abrir `VSCode` en una nueva ventana cuando ese editor fue seleccionado.
6. Validar que `opencode` y `lazygit` existan en `PATH` antes de abrirlos.
7. Validar `nvim` en `PATH` cuando ese editor fue seleccionado.
8. Validar `VSCode` mediante el comando `code` o una instalacion estandar de `Code.exe` cuando ese editor fue seleccionado.
9. Validar que existan al menos dos escritorios virtuales antes de ubicar ventanas.
10. Mover `opencode` y `lazygit` al escritorio 1.
11. Mover el editor seleccionado al escritorio 2.
12. Abrir el editor sobre el directorio objetivo.
13. Aplicar la disposicion de ventanas en la pantalla principal: izquierda para `opencode`, derecha para `lazygit` y maximizada para el editor.
14. Abrir `lazygit` en la consola de Windows para conservar su fondo oscuro habitual.
15. Mostrar el escritorio 2 al finalizar para dejar el editor listo para uso inmediato.
16. Fallar con un mensaje claro si faltan escritorios virtuales o el soporte necesario para mover ventanas.

## Dependencias operativas

1. El script depende del modulo `VirtualDesktop` version `1.5.11`.
2. El modulo puede existir instalado en el sistema o disponible localmente en `.tools/VirtualDesktop.1.5.11`.
3. La preparacion local del modulo se documenta en `.agents/features/setup_virtualdesktop.md`.
4. Si el modulo no existe en ninguna de esas ubicaciones, el script falla y no intenta instalarlo.

## Archivos de implementacion

1. `start-work.ps1`: script principal.
2. `start-work.bat`: lanzador para ejecutar el script con doble clic o desde `cmd`.
4. `.tools/VirtualDesktop.1.5.11/`: ubicacion opcional para una copia local ya disponible del modulo.
5. `setup-virtualdesktop.ps1`: script de preparacion de la dependencia.
6. `setup-virtualdesktop.bat`: lanzador del setup de la dependencia.

## Criterios de aceptacion de v2

1. Ejecutar el script abre `opencode`, `lazygit` y el editor seleccionado sin pedir pasos manuales intermedios.
2. Las tres herramientas usan el directorio recibido por parametro o definido en `path.txt`.
3. Si existen menos de dos escritorios virtuales, el script falla y le indica al usuario que debe crear el escritorio faltante manualmente.
4. `opencode` y `lazygit` quedan abiertos en el escritorio 1.
5. El editor seleccionado queda abierto en el escritorio 2.
6. `opencode` queda visible a la izquierda en la pantalla principal cuando se muestra el escritorio 1.
7. `lazygit` queda visible a la derecha en la pantalla principal cuando se muestra el escritorio 1.
8. `lazygit` se abre en la consola de Windows con su fondo oscuro habitual.
9. El editor abre el directorio objetivo y no queda en una vista inicial vacia.
10. El editor queda maximizado en la pantalla principal cuando se muestra el escritorio 2.
11. El script termina dejando visible el escritorio 2.
12. Si la configuracion de entrada es invalida, el script falla con un mensaje entendible.
13. Si falta alguno de los comandos requeridos, el script falla con un mensaje entendible.
14. Si el soporte para escritorios virtuales no esta disponible, el script falla sin instalar nada por su cuenta.
