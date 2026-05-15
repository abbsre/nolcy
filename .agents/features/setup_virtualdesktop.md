# Feature: Setup VirtualDesktop

## Objetivo

Preparar la dependencia `VirtualDesktop` de forma explicita y separada del flujo diario de apertura del workspace.

## Entrada

1. Ejecutar un script de preparacion desde Windows.

## Resultado esperado

1. Descargar `VirtualDesktop` version `1.5.11` desde PowerShell Gallery.
2. Guardar la dependencia en `.tools/VirtualDesktop.1.5.11` dentro del repositorio.
3. Dejar disponible `VirtualDesktop.psd1` para que `start-work.ps1` pueda importarlo.
4. Validar que el modulo pueda importarse correctamente al finalizar.

## Restricciones

1. Esta feature no debe abrir `opencode`, `lazygit` ni `nvim`.
2. Esta feature no debe crear ni mover escritorios virtuales.
3. Esta feature debe tener su propio ejecutable separado del launcher principal.
4. La instalacion debe quedar local al repositorio, no depender de una instalacion global.

## Comportamiento minimo esperado

1. Crear `.tools/` si no existe.
2. Descargar el paquete `VirtualDesktop` version `1.5.11`.
3. Extraerlo en `.tools/VirtualDesktop.1.5.11`.
4. Reemplazar la copia local si ya existe una version previa incompleta o desactualizada.
5. Validar que `VirtualDesktop.psd1` exista al final.
6. Importar el modulo para confirmar que la instalacion local es usable.
7. Fallar con un mensaje claro si la descarga o la validacion no funcionan.

## Archivos de implementacion

1. `setup-virtualdesktop.ps1`: script principal de preparacion.
2. `setup-virtualdesktop.bat`: lanzador para ejecutar el setup.

## Criterios de aceptacion

1. Ejecutar el script deja disponible `.tools/VirtualDesktop.1.5.11/VirtualDesktop.psd1`.
2. El modulo se puede importar desde la ruta local del repositorio.
3. Si hay fallo de red o de extraccion, el script devuelve un error entendible.
4. `start-work.ps1` puede depender de esta salida sin mezclar la instalacion con el uso diario.
