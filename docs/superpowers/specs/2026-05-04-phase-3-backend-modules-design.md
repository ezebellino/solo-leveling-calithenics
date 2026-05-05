# Phase 3 Backend Modules Design

> **Goal:** Modularizar el backend con la misma simetria conceptual que ya ganamos en Flutter, moviendo `quests`, `inventory`, `shadows` y `system` a una arquitectura `module + layers`, reduciendo al minimo los archivos monoliticos residuales y dejando una base defendible, testeable y escalable para integracion estable con `Postgres`, Railway y el frontend actual.

## Why This Phase Exists

`Phase 1` dejo una base backend seria:

- `app/core`
- `Alembic`
- logging estructurado
- manejo unificado de errores
- primer modulo real: `player`

`Phase 2` dejo el frontend mucho mas claro y simetrico:

- `app_shell`
- `player`
- `system`
- `quests`
- `inventory`
- `shadows`

La deuda principal ahora ya no esta en Flutter. Esta en el backend residual.

Hoy el proyecto tiene una contradiccion arquitectonica:

- `player` ya vive en `app/modules/player`
- pero `quests`, `inventory`, parte del bootstrap legacy y varias reglas de progreso siguen apoyadas en:
  - `app/main.py`
  - `app/services.py`
  - `app/models.py`
  - `app/schemas.py`

Eso rompe la simetria con Flutter, vuelve mas dificil testear por modulo y deja demasiada logica de negocio colgando de archivos generales.

Si seguimos agregando features sobre esa base:

- va a crecer la deuda de routing
- va a crecer la deuda de models compartidos sin ownership
- va a empeorar la trazabilidad de errores
- y el backend va a dejar de ser defendible ante otros tecnicos

## Phase Goal

`Phase 3` no busca cambiar el producto ni agregar features nuevas.

Busca que el backend quede claramente organizado por modulos, con capas reconocibles y responsabilidad explicita.

Al cerrar la fase, el backend debe cumplir esto:

- `player` deja de ser el unico modulo real
- `quests`, `inventory`, `shadows` y `system` tienen ownership propio
- `main.py` queda reducido a composicion de app, middleware y registro de routers
- `services.py`, `models.py` y `schemas.py` dejan de ser centros de crecimiento
- la API publica sigue funcionando igual o mejor
- la base queda lista para una `Phase 4` de integracion, observabilidad y endurecimiento

## Out Of Scope

Esta fase no incluye:

- auth / Google login
- nuevos features de negocio grandes
- reescritura total del dominio de progreso
- colas, background jobs o workers
- observabilidad externa completa tipo Sentry / OpenTelemetry distribuido
- endpoints de sharing
- sistema comercial de descuentos

Tampoco busca rehacer Railway ni cambiar de infraestructura. La prioridad es modularidad backend.

## Architecture Target

La forma objetivo del backend pasa a ser:

```text
backend/
  alembic/
  app/
    core/
      config.py
      database.py
      errors.py
      logging.py
      request_context.py
    modules/
      player/
        api/
        application/
        domain/
        infrastructure/
      quests/
        api/
        application/
        domain/
        infrastructure/
      inventory/
        api/
        application/
        domain/
        infrastructure/
      shadows/
        api/
        application/
        domain/
        infrastructure/
      system/
        api/
        application/
        domain/
        infrastructure/
    main.py
```

No todas las carpetas tienen que empezar llenas, pero la frontera arquitectonica tiene que quedar clara desde esta fase.

## Module Responsibilities

### `player`

Ya existe y se conserva como owner de:

- bootstrap del jugador
- overview de progreso base
- actualizacion del progreso del jugador
- datos de identidad del jugador

En esta fase no se lo vuelve a inventar. Se lo usa como patron de referencia.

### `quests`

Debe pasar a ser owner real de:

- `GET /api/v1/quests/today`
- `POST /api/v1/quests/{id}/advance`
- `POST /api/v1/quests/{id}/complete`
- reglas de serializacion de quest
- acceso a datos de quests del jugador
- logica de avance y completado

Las reglas de avance de quest ya no deben vivir en `app/services.py`.

### `inventory`

Debe pasar a ser owner de:

- `GET /api/v1/inventory`
- acceso a items del jugador
- serializacion del inventario
- reglas de lectura que hoy estan mezcladas con bootstrap o servicios generales

No es necesario en esta fase agregar consumo de items por endpoint si todavia no existe un caso de uso maduro. La prioridad es ownership y estructura.

### `shadows`

Debe introducir el modulo backend simetrico para el sistema que ya vive en Flutter.

Minimo esperado en esta fase:

- entidades/contratos del estado de sombras
- infraestructura lista para persistir desbloqueos
- capa de aplicacion para lectura del progreso de sombras

No hace falta exponer todo un set nuevo de endpoints si todavia el frontend no lo consume. Pero el backend debe dejar de depender de `shadow_army` como simple entero aislado sin modulo.

### `system`

Debe quedar como owner de piezas transversales del Sistema que no son `player` puro ni `quests` puras.

Minimo esperado:

- respuestas de health o metadatos que pertenezcan al sistema general
- evolucion posterior de notices, popups y estados sistemicos
- punto natural para futuras integraciones de clase, level-up y eventos globales

`system` no necesita arrancar grande. Necesita arrancar bien delimitado.

## Layering Rules

Cada modulo debe tender a esta estructura:

- `domain/`
  - entidades
  - reglas puras
  - excepciones del dominio
- `application/`
  - casos de uso
  - servicios de orquestacion
  - puertos/contratos si hacen falta
- `infrastructure/`
  - SQLAlchemy models
  - repositorios
  - adaptadores DB
- `api/`
  - routers
  - request/response schemas
  - traduccion HTTP

Reglas de dependencia:

- `api` puede depender de `application`
- `application` puede depender de `domain` e interfaces
- `infrastructure` implementa detalles concretos
- `domain` no depende de FastAPI ni de SQLAlchemy

## Main.py Target

`app/main.py` debe quedar reducido a:

- creacion de `FastAPI`
- registro de middleware
- registro de exception handlers
- registro de routers
- lifespan/startup minimo

No debe seguir cargando casos de uso concretos de `quests` o `inventory`.

## Legacy File Reduction

Esta fase se considera bien ejecutada si:

- `app/services.py` queda vacio, removido o reducido a compatibilidad temporal muy chica
- `app/schemas.py` deja de alojar contratos de `quests` o `inventory`
- `app/models.py` deja de concentrar ownership de modulos nuevos

Idealmente:

- los modelos legacy se reparten por modulo
- los schemas legacy se reparten por modulo
- los routers legacy desaparecen del centro de `main.py`

## Data Model Strategy

No conviene rehacer la base completa en esta fase.

La estrategia correcta es:

- conservar compatibilidad con el schema actual
- mover ownership de los modelos a los modulos
- usar `Alembic` para cualquier ajuste de estructura nuevo
- evitar cambios destructivos innecesarios

Si algun modelo compartido necesita convivir temporalmente entre legacy y modulo, debe existir un plan claro de eliminacion antes del cierre de la fase.

## Logging And Error Handling

`Phase 1` ya introdujo la infraestructura transversal. `Phase 3` debe aprovecharla de forma consistente.

Cada modulo nuevo debe:

- loggear eventos relevantes de aplicacion
- loggear errores de negocio con contexto
- no filtrar errores internos al cliente
- usar las excepciones comunes donde corresponda

Objetivo:

- que un error en `quests` o `inventory` tenga ownership claro
- que los logs permitan ubicar el modulo responsable sin leer todo el proyecto

## Testing Strategy

Cada modulo migrado debe traer tests propios.

Minimo esperado:

- tests de `quests`:
  - listar quests del dia
  - avanzar quest
  - completar quest
  - errores de quest inexistente o avance invalido
- tests de `inventory`:
  - obtener inventario del jugador
- tests de wiring:
  - routers registrados
  - health sigue respondiendo
- tests de compatibilidad:
  - los contratos API existentes siguen devolviendo la forma esperada

No alcanza con que compile. La modularizacion tiene que demostrar que no rompio el comportamiento actual.

## Migration Strategy

La fase debe implementarse por cortes chicos, manteniendo el backend funcional en cada hito.

### Step 1: `quests`

Extraer primero el modulo con mas logica residual:

- models
- repository
- service
- schemas
- router

Objetivo: sacar de `app/services.py` el avance/completado/listado de misiones.

### Step 2: `inventory`

Extraer:

- lectura de inventario
- schemas
- router
- repository/service

Objetivo: que el inventario deje de colgar de servicios generales.

### Step 3: `shadows`

Introducir el modulo backend espejo del feature frontend:

- contratos
- persistencia base del progreso de sombras
- punto de consulta/serializacion

Objetivo: preparar el backend para una integracion limpia de `Sombras` sin volver al monolito.

### Step 4: `system`

Ordenar ownership de piezas transversales:

- health/meta si corresponde
- futuros estados sistemicos
- capa base para eventos generales del Sistema

### Step 5: limpieza legacy

- adelgazar o remover `app/services.py`
- adelgazar o remover `app/schemas.py`
- adelgazar o remover `app/models.py`
- dejar `main.py` como composicion real

## Success Criteria

`Phase 3` se considera exitosa si:

- el backend ya no depende de archivos generales como centro de crecimiento
- `quests` e `inventory` son modulos reales
- `shadows` existe como modulo backend serio, aunque arranque chico
- `system` queda preparado como frontera transversal
- `main.py` queda significativamente mas chico y limpio
- tests cubren los modulos migrados
- la API actual sigue funcionando con el mismo contrato visible
- la simetria entre Flutter y FastAPI se vuelve evidente para otro tecnico

## Dependency On Phase 4

Si `Phase 3` sale bien, `Phase 4` ya puede enfocarse en:

- integracion mas fuerte frontend-backend
- observabilidad mas completa
- endurecimiento de sync
- surface real para auth y sharing

La idea es que despues de esta fase ya no tengamos que debatir donde vive cada responsabilidad del backend. Eso debe quedar explicitamente resuelto.
