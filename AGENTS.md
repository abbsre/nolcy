# Guia del repositorio para agentes

## Objetivo

Este repositorio se trabaja con enfoque SDD. La documentacion funcional y operativa vive en `.agents/`.

## Reglas de trabajo

1. Priorizar soluciones simples antes que abstracciones innecesarias.
2. Todo cambio en codigo debe actualizar la documentacion afectada.
3. La documentacion debe describir el comportamiento real del codigo, no el deseado.
4. Antes de implementar, revisar si ya existe una especificacion relacionada en `.agents/`.

## Criterios para escribir cambios

1. Usar instrucciones concretas, sin ambiguedades y faciles de verificar.
2. Definir entradas, salidas, restricciones y resultado esperado cuando aplique.
3. Evitar listas vagas como "configurar", "mejorar" o "ajustar" sin contexto operativo.
4. Si una decision afecta el flujo de trabajo, dejarla documentada en `.agents/`.

## Verificacion minima

1. Confirmar que el codigo implementa lo documentado.
2. Confirmar que la documentacion refleja el estado final del cambio.
3. Si hay diferencias entre codigo y documentacion, corregir ambas antes de cerrar la tarea.
