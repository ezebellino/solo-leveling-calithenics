# Phase 1 Core Foundation Design

> **Goal:** Establecer la base arquitectonica escalable del proyecto con `feature + layers + Riverpod` en Flutter, `module + layers` en FastAPI, `Alembic`, logging estructurado y manejo centralizado de errores, validando todo con un flujo real end-to-end de `player bootstrap / progreso base`.

## Why This Phase Exists

El proyecto ya tiene varias piezas valiosas:

- flujo principal jugable
- sincronizacion backend inicial
- persistencia local
- `Sombras`
- popups ceremoniales

Pero la arquitectura todavia tiene deuda importante:

- `home` sigue concentrando demasiada responsabilidad
- el backend sigue demasiado apoyado en archivos generales
- logging y observabilidad no estan formalizados
- el manejo de errores no tiene un camino consistente
- no hay migraciones formales
- el estado del frontend todavia no expresa bien sus dependencias

Si intentamos seguir agregando features sobre esa base, el costo marginal de cada cambio va a subir, y el proyecto va a ser menos defendible ante otros tecnicos.

## Phase Goal

`Phase 1` no busca migrar toda la app.

Busca dejar una base nueva **funcionando end-to-end** y no solo scaffold vacio.

Al cerrar la fase, el proyecto debe tener:

- `core` compartido claro en frontend
- `Riverpod` como base formal de composicion de dependencias y estado
- `core` backend con config, db, logging y errores desacoplados
- `Alembic` operativo
- logging estructurado en frontend y backend
- manejo de errores centralizado en ambos lados
- un flujo real `player bootstrap / progreso base` corriendo sobre la nueva arquitectura

## Out Of Scope

Esta fase no incluye:

- migrar todas las features a la nueva estructura
- auth o Google login
- share cards
- storage binario de imagenes
- observabilidad externa completa tipo Sentry/DataDog
- modularizacion total de `quests`, `inventory`, `shadows` y `system`

Eso se deja para fases siguientes.

## Architecture Target

## Flutter

Se adopta una estructura por feature y capas:

- `lib/core/`
  - configuracion
  - logging
  - manejo de errores
  - networking base
  - estado compartido minimo
  - providers raiz
- `lib/features/player/`
  - `domain/`
  - `application/`
  - `data/`
  - `presentation/`

`home` no desaparece todavia, pero deja de ser el centro de la logica nueva. El primer flujo serio sobre la arquitectura nueva se mueve a `player`.

### Riverpod

Riverpod entra como base formal de:

- inyeccion de dependencias
- providers de repositorios
- providers de casos de uso
- estado del flujo `player bootstrap / progreso base`

No se migra todo el estado actual en esta fase. Solo lo necesario para validar el patron correctamente.

### Frontend Logging

Se incorpora un logger estructurado con:

- nivel (`debug`, `info`, `warning`, `error`)
- evento
- contexto
- source

Debe servir para:

- diagnosticar errores de sync
- diagnosticar fallos de bootstrap
- rastrear transiciones importantes del flujo de jugador

### Frontend Error Handling

Se incorpora una capa centralizada para:

- mapear errores de red
- mapear errores de persistencia
- mapear errores desconocidos
- mostrar feedback de UI consistente
- loggear siempre antes de degradar la experiencia

## FastAPI

Se adopta una estructura por modulos y capas:

- `backend/app/core/`
  - config
  - logging
  - db session
  - exception handling
- `backend/app/modules/player/`
  - `api/`
  - `application/`
  - `domain/`
  - `infrastructure/`

`main.py`, `schemas.py`, `models.py` y `services.py` dejan de ser el centro de crecimiento para este flujo.

## Alembic

`Alembic` entra en esta fase como sistema oficial de migraciones.

Objetivo:

- poder recrear el schema de forma formal
- dejar trazabilidad de cambios de DB
- eliminar dependencia de inicializacion improvisada del esquema

El modelo actual de base puede mantenerse como punto de partida, pero la evolucion del schema debe pasar por migraciones.

## Backend Logging

Se define logging estructurado para:

- startup
- requests
- errores de aplicacion
- errores de infraestructura
- eventos relevantes del flujo `player bootstrap`

Minimo esperado:

- request id o correlacion basica
- ruta
- metodo
- duracion
- resultado

## Backend Error Handling

Debe haber una estrategia unificada para:

- errores de dominio
- errores de aplicacion
- errores de persistencia
- errores HTTP

Objetivo:

- respuestas consistentes
- logs utiles
- no filtrar detalles internos al cliente

## End-To-End Vertical For Validation

El vertical elegido para `Phase 1` es:

### `player bootstrap / progreso base`

Incluye:

- obtener snapshot base del jugador
- hidratar estado inicial del frontend
- persistencia local del estado del jugador
- refresco remoto del snapshot
- manejo de error controlado si la API falla
- logging de bootstrap y sync
- uso de providers y casos de uso sobre Riverpod
- backend modular equivalente del lado `player`

Este vertical es ideal para la fase porque:

- ya existe funcionalmente
- toca frontend, backend, red, persistencia y estado
- es simple de validar
- no obliga a migrar todas las quests o sombras desde el dia uno

## Migration Strategy

La fase se implementa por cortes que mantengan la app funcional.

### Step 1: Core Backend Base

Crear:

- `app/core/config`
- `app/core/logging`
- `app/core/db`
- `app/core/errors`
- `alembic/`

Y preparar el modulo `player`.

### Step 2: Core Frontend Base

Crear:

- `lib/core/logging`
- `lib/core/errors`
- `lib/core/network`
- `lib/core/providers`

Y dejar `Riverpod` instalado y operativo.

### Step 3: Player Module Backend

Mover el flujo base de jugador a un modulo real:

- endpoint bootstrap
- esquema de respuesta
- servicio de aplicacion
- acceso a datos

### Step 4: Player Feature Frontend

Crear feature `player` con:

- entidad/snapshot del jugador en `domain`
- repositorio en `data`
- caso de uso de bootstrap en `application`
- provider / notifier en `presentation`

### Step 5: Integracion End-To-End

Conectar:

- provider de bootstrap
- cliente API modular
- persistencia local
- logs
- manejo de errores

## Testing Strategy

La fase debe dejar tests claros en ambos lados.

### Flutter

- tests de providers / notifier de `player`
- tests de mapeo de errores
- tests de repositorio si hay adaptadores relevantes

### Backend

- tests de modulo `player`
- tests de error handling
- tests de contrato del endpoint bootstrap
- smoke test de migracion si aplica

## Success Criteria

`Phase 1` se considera exitosa si:

- existe `core` nuevo en frontend y backend
- `Riverpod` ya participa del flujo real
- `Alembic` ya es el camino oficial de schema
- logs estructurados existen en ambos lados
- errores tienen tratamiento consistente
- `player bootstrap / progreso base` funciona end-to-end sobre la nueva arquitectura
- el proyecto queda mejor preparado para migrar `quests`, `inventory`, `shadows` y `system` en fases siguientes

## Next Phase Dependency

Si `Phase 1` sale bien, `Phase 2` puede enfocarse en migrar arquitectura Flutter completa sin improvisar infraestructura nueva.

La idea es que despues de esta fase ya no tengamos que volver a discutir:

- estado base
- logging
- errores
- DI
- migraciones

Esas piezas ya deben quedar resueltas.
