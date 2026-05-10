# Phase 4 Sync And Observability Design

> **Goal:** Endurecer el sistema dejando una integracion real y estable entre `Flutter`, `FastAPI` y `Postgres`, con ownership claro del estado sincronizado, manejo consistente de errores y una base de observabilidad preparada para produccion.

## Why This Phase Exists

`Phase 1` dejo una base transversal seria:

- `core` en frontend y backend
- `Riverpod`
- `Alembic`
- logging inicial
- primer flujo end-to-end

`Phase 2` ordeno el frontend por fronteras reales:

- `app_shell`
- `player`
- `system`
- `quests`
- `inventory`
- `shadows`

`Phase 3` dejo el backend modular y defendible:

- `player`
- `quests`
- `inventory`
- `shadows`
- `system`

La deuda principal ya no es estructural. La deuda ahora es operativa.

Hoy el proyecto ya tiene buena arquitectura, pero todavia conviven demasiadas zonas de ambiguedad entre:

- estado local
- estado remoto
- persistencia temporal
- fallos de red
- errores de sincronizacion
- logs dispersos

Si seguimos agregando producto arriba de eso:

- van a aparecer bugs de consistencia
- va a ser dificil distinguir error de UI contra error de backend
- el soporte de usuarios reales se va a volver costoso
- auth y sharing van a caer sobre una base de sync todavia blanda

`Phase 4` existe para cerrar esa brecha.

## Phase Goal

Esta fase no busca agregar features vistosas nuevas.

Busca que el sistema quede operacionalmente confiable:

- el frontend sabe que datos son locales y cuales son server-authoritative
- el backend expone surfaces claras para sincronizar estado real
- los errores tienen ownership y contexto
- los logs permiten diagnosticar fallos reales
- el proyecto queda listo para auth, sharing y mas usuarios concurrentes

Al cerrar la fase, el sistema debe poder defender esto:

- bootstrap consistente
- sincronizacion clara de progreso
- sincronizacion clara de quests
- sincronizacion clara de inventario y sombras
- degradacion controlada ante errores
- trazabilidad util en logs

## Out Of Scope

Esta fase no incluye:

- login social
- sistema comercial de descuentos
- share cards finales
- workers, colas o cron jobs complejos
- observabilidad externa full enterprise
- reescritura total del dominio del progreso

Tampoco incluye rehacer toda la UX offline. La prioridad es definir y endurecer el flujo actual.

## Core Problem To Solve

El proyecto necesita responder de forma explicita estas preguntas:

- que estado manda: local o remoto
- que pasa cuando el backend falla
- que pasa cuando el usuario hace una accion rapida y la sync tarda
- cuando se refresca el bootstrap
- que entidades se hidratan juntas
- como se detecta una desincronizacion
- donde queda registrado el error real

Hoy parte de eso existe de manera implicita o repartida. `Phase 4` lo vuelve explicito.

## Architectural Decision

La estrategia recomendada para esta fase es:

- `backend` como fuente de verdad para estado durable
- `frontend` como capa de presentacion con cache local y actualizaciones optimistas puntuales
- `Riverpod` como owner del estado sincronizado por feature
- logging estructurado en ambos lados
- errores normalizados en contratos y presentacion

No vamos a hacer un sistema totalmente offline-first en esta fase.

Vamos a hacer un sistema `online-first with resilient local cache`.

## Data Authority Rules

### `player`

El backend pasa a ser la fuente de verdad para:

- alias
- clase
- nivel
- progreso persistido
- avatar remoto
- estado durable del jugador

El frontend puede cachearlo localmente para bootstrap rapido, pero no debe inventar estados nuevos sin reconciliacion.

### `quests`

El backend pasa a ser la fuente de verdad para:

- quests del dia
- progress real de cada quest
- estado de completado
- special quest de la semana

El frontend puede mostrar actualizacion optimista al tocar botones, pero debe reconciliarse con la respuesta del backend.

### `inventory`

El backend pasa a ser la fuente de verdad para:

- items disponibles
- consumos validos
- recompensas persistidas

El frontend no debe mutar inventario durable por cuenta propia.

### `shadows`

El backend pasa a ser la fuente de verdad para:

- sombras desbloqueadas
- progreso de desbloqueo si aplica
- snapshot durable del roster del jugador

El frontend puede cachear la galeria para experiencia rapida, pero la condicion final de unlock debe venir del backend.

## Synchronization Model

La fase debe converger en este flujo:

1. `bootstrap`
   - el frontend intenta cargar snapshot remoto
   - si hay cache local, se usa como fallback visible
   - si llega remoto valido, reemplaza el snapshot local

2. `action`
   - el usuario ejecuta una accion
   - la UI puede actualizar optimistamente cuando convenga
   - la feature dispara el caso de uso de sync

3. `reconcile`
   - el backend responde con estado actualizado o error
   - el frontend confirma, corrige o revierte

4. `persist`
   - el snapshot local se actualiza desde el resultado reconciliado

El objetivo no es inventar sync complejo. Es dejar un flujo unico y coherente.

## API Surface Target

No hace falta un rediseño total de endpoints, pero esta fase debe dejar una surface mas estable.

Minimo esperado:

- `GET /api/v1/player`
- `PATCH /api/v1/player/progress`
- `GET /api/v1/quests/today`
- `POST /api/v1/quests/{id}/advance`
- `POST /api/v1/quests/{id}/complete`
- `GET /api/v1/inventory`
- `GET /api/v1/shadows/progression`

Si algun endpoint hoy devuelve contratos demasiado ambiguos, esta fase puede endurecerlos siempre que el frontend se adapte dentro del mismo hito.

## Frontend Target

Cada feature sincronizada debe tender a esta forma:

- `application`
  - provider/controlador del estado sincronizado
  - caso de uso de bootstrap o refresh
  - caso de uso de accion
- `data`
  - repositorio
  - API client
  - cache local
- `presentation`
  - UI que consume estado derivado
  - feedback consistente de loading/error/success

`app_shell` no debe convertirse otra vez en un mega-coordinador.

La prioridad es que cada feature pueda responder:

- de donde viene su estado
- como se refresca
- como reporta errores

## Backend Target

Cada modulo backend debe dejar mas claro:

- que endpoint es owner de que estado
- que errores devuelve
- que logging genera
- que parte del estado es durable

Tambien debe existir una forma clara de construir snapshots consistentes para el frontend, sobre todo en `player bootstrap`.

## Error Handling Target

Esta fase debe estandarizar dos cosas:

### Backend

- errores estructurados
- codigos consistentes
- mensajes seguros para cliente
- detalle tecnico solo en logs
- contexto minimo:
  - modulo
  - accion
  - identificador de jugador si aplica

### Frontend

- mapeo consistente de errores
- mensaje de usuario legible
- retry donde tenga sentido
- logs con contexto suficiente para reconstruir el flujo

No queremos mas errores "mudos" ni feedback ambiguo.

## Observability Target

La observabilidad minima de produccion para esta fase es:

### Frontend

- logging estructurado por feature
- eventos clave:
  - bootstrap started
  - bootstrap succeeded
  - bootstrap failed
  - action started
  - action succeeded
  - action failed
  - reconcile fallback
- contexto util:
  - feature
  - action
  - entity id
  - source local/remoto

### Backend

- request logging basico
- logging por modulo
- errores con stack trace y contexto
- health util para diagnostico

### Persistencia / exportabilidad

No hace falta integrar una plataforma externa completa en esta fase, pero la estructura debe quedar lista para:

- Railway logs
- correlacion simple de requests
- futura integracion con Sentry o equivalente

## Offline And Fallback Policy

La politica recomendada para esta fase es:

- bootstrap puede usar cache local si el remoto falla
- acciones mutantes no deben "simular exito" si el backend no confirmo
- si una accion optimista falla:
  - rollback
  - feedback visible
  - log estructurado

Esto es mas importante que agregar complejidad offline prematura.

## Testing Strategy

La fase debe traer pruebas para:

### Frontend

- bootstrap remoto exitoso
- fallback a cache local
- refresh despues de accion
- rollback al fallar una accion
- mapeo de errores a UI

### Backend

- contratos de endpoints de sync
- errores estructurados
- consistencia de actualizacion de progreso
- consistencia de snapshot de player

### Integration

Minimo esperado:

- player bootstrap end-to-end
- avanzar una quest y reconciliar estado
- aceptar/rechazar special quest y persistir
- leer inventario y sombras desde snapshot consistente

## Migration Strategy

Esta fase debe ejecutarse por cortes controlados.

### Step 1: Sync ownership

Definir por feature:

- provider principal
- repositorio
- cache local
- contrato remoto

Primero `player`, despues `quests`, luego `inventory` y `shadows`.

### Step 2: Reconcile actions

Endurecer los flujos mutantes:

- advance quest
- complete quest
- special quest decision
- inventory actions que apliquen

### Step 3: Observability baseline

Agregar o completar:

- logs estructurados frontend
- logs estructurados backend
- request context minimo
- errores normalizados

### Step 4: Integration verification

Verificar que el flujo real entre app, API y DB funciona de forma consistente, no solo por modulo aislado.

## Success Criteria

`Phase 4` se considera exitosa si:

- el frontend ya no depende de estados ambiguos para progreso durable
- el backend responde como fuente de verdad clara
- bootstrap, quests, inventory y shadows tienen estrategia de sync explicita
- errores y retries se comportan de forma consistente
- los logs permiten ubicar fallos reales sin adivinar
- el sistema queda preparado para `auth`, `sharing` y uso mas serio

## Dependency On Future Work

Si `Phase 4` sale bien, las siguientes fases pueden apoyarse en una base mucho mas segura:

- `auth`
- multi-device sync
- share cards
- programa comercial y beneficios
- observabilidad externa mas completa

La idea es simple: despues de esta fase, el sistema ya no solo se ve bien y esta bien ordenado. Tambien se comporta como una app seria.
