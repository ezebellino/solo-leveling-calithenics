# Git Strategy For Scalable Refactor

> **Goal:** Definir una estrategia de ramas, merges y hitos para ejecutar el refactor agresivo del proyecto sin conflictos innecesarios y con trazabilidad clara entre frontend, backend, observabilidad y migraciones.

## Current Baseline

- `master` representa la ultima linea estable mergeada.
- `codex/shadows-mvp` contiene los cambios mas recientes de `Sombras`, cofres y popups ceremoniales.
- El proximo trabajo es un refactor agresivo con impacto transversal en Flutter, FastAPI, logging, estado y base de datos.

## Branching Model

La unidad principal de trabajo va a ser la **fase**, no la capa tecnica.

No se van a abrir ramas separadas por:
- frontend
- backend
- logs
- Riverpod

Porque esas capas se tocan entre si y eso elevaria mucho el riesgo de conflictos, rebases complejos y merges poco defendibles.

En cambio, se usaran ramas por fase:

- `codex/refactor-phase-1-core-foundation`
- `codex/refactor-phase-2-flutter-architecture`
- `codex/refactor-phase-3-backend-modules`
- `codex/refactor-phase-4-integration-observability`

Cada fase puede contener varios commits pequenos, pero solo una rama de fase activa va a modificar arquitectura compartida al mismo tiempo.

## Merge Policy

- `master` debe permanecer siempre estable.
- Antes de abrir la fase siguiente, la fase anterior debe estar mergeada a `master`.
- Los merges a `master` deben ser frecuentes por hito grande, no al final de todo el refactor.
- Cada merge debe corresponder a una app funcionando y testeable.

## Commit Policy

Cada cambio importante debe cerrar con:

1. `analyze` / tests relevantes en verde
2. commit pequeno y defendible
3. push inmediato de la rama activa

Ejemplos de commits validos:
- `feat: add ceremonial system evolution popups`
- `refactor: introduce frontend core providers`
- `refactor: split backend player module boundaries`
- `feat: add structured logging pipeline`

## Phase Responsibilities

### Phase 1: Core Foundation

Objetivo:
- preparar el terreno comun para el resto del refactor

Incluye:
- `core/` frontend
- logging frontend/backend
- manejo centralizado de errores
- configuracion
- Alembic
- estructura base de modulos backend
- providers raiz / composicion de dependencias

### Phase 2: Flutter Architecture

Objetivo:
- mover el frontend a `feature + layers + Riverpod`

Incluye:
- separar `domain / application / data / presentation`
- retirar logica pesada de widgets/controladores
- dejar casos de uso y providers explicitamente reconocibles

### Phase 3: Backend Modules

Objetivo:
- mover FastAPI a `module + layers`

Incluye:
- `players`
- `quests`
- `shadows`
- `inventory`
- `system`
- `core`
- repositorios, servicios de aplicacion y routers modulares

### Phase 4: Integration And Observability

Objetivo:
- estabilizar la conexion entre frontend, backend y base de datos

Incluye:
- cliente API alineado a los nuevos modulos
- trazabilidad de requests
- logs estructurados
- manejo de errores consistente
- tests de integracion clave

## Conflict Avoidance Rules

- No trabajar en dos ramas grandes en paralelo modificando los mismos archivos base.
- No abrir una fase nueva hasta que la anterior este mergeada.
- Si se necesita exploracion paralela, usar subagentes o ramas temporales de corta vida y mergearlas primero a la rama de fase, nunca directo a `master`.
- Mantener los cambios de documentacion, arquitectura y ejecucion agrupados por hito.

## Immediate Next Steps

1. Mergear `codex/shadows-mvp` a `master`
2. Crear `codex/refactor-phase-1-core-foundation`
3. Escribir el spec de `Phase 1`
4. Escribir el plan de implementacion de `Phase 1`
5. Ejecutar el refactor por hitos pequenos con commit y push frecuente

## Success Criteria

Esta estrategia se considera correcta si:

- cualquier tecnico puede entender rapido que se trabajo por fases
- `master` siempre queda utilizable
- los merges son pequenos y justificables
- el refactor nunca queda atrapado en una rama eterna
- frontend y backend evolucionan coordinados sin ramas caoticas por capa
