# Backend FastAPI

Backend preparado para desplegarse como servicio en Railway.

Estado actual:

- backend listo para `SQLite` local y `Postgres` via `DATABASE_URL`
- `Alembic` agregado como baseline de migraciones
- backend modularizado por features reales:
  - `player`
  - `quests`
  - `inventory`
  - `shadows`
  - `system`
- `app/core` concentra config, DB, logging, errores y request context

## Endpoints actuales

- `GET /`
- `GET /health`
- `GET /api/v1/bootstrap`
- `GET /api/v1/player`
- `PATCH /api/v1/player/progress`
- `GET /api/v1/quests/today`
- `POST /api/v1/quests/{id}/advance`
- `POST /api/v1/quests/{id}/complete`
- `GET /api/v1/inventory`
- `GET /api/v1/shadows/progression`

## Desarrollo local

```powershell
cd backend
py -3 -m venv .venv
. .venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Con la configuracion actual, si no definis `DATABASE_URL`, el backend crea `solo_leveling.db` local y siembra un jugador base con progreso, inventario y quests iniciales.

## Migraciones

Inicializar o inspeccionar migraciones:

```powershell
cd backend
py -3 -m alembic current
py -3 -m alembic upgrade head
```

`Phase 1` deja a `Alembic` como camino oficial para cambios de esquema. El arranque del backend ya no debe ser el lugar donde se inventan tablas nuevas.

## Deploy en Railway

Proyecto Railway inicializado:

- Workspace: `Pink Panthers`
- Project: `solo-leveling-calithenics`

Configuracion en codigo:

- archivo: `backend/railway.json`
- `Root Directory` esperado: `backend`
- `Config File` sugerido en Railway: `/backend/railway.json`

Pasos en Railway:

1. Crear un servicio vacio dentro de `solo-leveling-calithenics`.
2. Configurar el `Root Directory` del servicio a `backend`.
3. Configurar `Config File` a `/backend/railway.json`.
4. Conectar este repo o desplegar el directorio local `backend`.
5. Generar dominio publico para el servicio.
6. Variables recomendadas:
   - `APP_ENV=production`
   - `APP_DEBUG=false`
   - `ALLOWED_ORIGIN=*`
   - `DATABASE_URL` apuntando a Postgres en Railway
   - `DB_ECHO=false`

## Healthcheck sugerido

- Path: `/health`

El healthcheck ahora informa tambien el estado de la base de datos.

## Arquitectura actual

`Phase 3` deja esta forma base:

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

### Ownership actual

- `player`
  - bootstrap del jugador
  - overview/progreso base
  - update de progreso
  - modelos `User` y `PlayerProgress`
  - seed/reconcile base del jugador
- `quests`
  - listado de quests del dia
  - avance y completado
  - persistencia `DailyQuest`
- `inventory`
  - lectura del inventario del jugador
  - persistencia `InventoryItem`
- `shadows`
  - lectura de progresion de sombras
  - persistencia `ShadowUnlock`
  - fallback legacy a `shadow_army` mientras existan entornos sin migration aplicada
- `system`
  - `GET /`
  - `GET /health`
  - composicion de estado global/meta

### Legacy reducido

- `app/main.py`
  - ahora compone la app y registra routers
- `app/services.py`
  - quedo como shim chico para inicializacion de esquema/seed
- `app/models.py`
  - ya no es owner de persistencia; es un shim de compatibilidad explicito
- `app/schemas.py`
  - retirado en `Phase 3`

### Migraciones

Migraciones activas:

- `20260504_01_initial_player_module.py`
- `20260505_01_add_shadow_unlocks.py`

Las nuevas tablas/modulos no se agregan inventando schema en startup. El camino oficial sigue siendo `Alembic`.

### Verificacion de Phase 3

Al cierre de la fase se verifico:

- `py -3 -m pytest tests -q`
- `py -3 -m compileall backend\app backend\tests`

Resultado esperado en la baseline actual:

- `24 passed`
- warnings viejos de `Pydantic` alias todavia presentes en `test_error_handling`, no introducidos por esta fase

### Nota sobre archivos temporales

En worktrees de refactor pueden aparecer `.db` de pruebas locales. No forman parte del estado versionado del backend y deben quedar fuera de los commits.

## Phase 4 Sync + Observability Baseline

`Phase 4` endurece la integracion entre Flutter y FastAPI y deja una baseline de observabilidad mas cercana a produccion.

### Autoridad de datos

El backend pasa a ser la fuente de verdad durable para:

- `player bootstrap`
- `inventory`
- `shadow progression`
- mutaciones de `quests` aceptadas

El frontend mantiene cache local y aplica fallback controlado, pero ya no inventa verdad durable silenciosamente.

### Contratos y surface relevantes

- `GET /api/v1/bootstrap`
  - incluye metadata de sync y fuente seleccionada
- `GET /api/v1/player`
- `PATCH /api/v1/player/progress`
- `GET /api/v1/quests/today`
- `POST /api/v1/quests/{id}/advance`
- `POST /api/v1/quests/{id}/complete`
- `GET /api/v1/inventory`
- `PATCH /api/v1/inventory/sync`
- `GET /api/v1/shadows/progression`
- `PATCH /api/v1/shadows/progression`

### Politica de errores y trazabilidad

- respuestas `AppError` incluyen:
  - `code`
  - `message`
  - `requestId`
- el backend devuelve `X-Request-Id`
- el middleware deja trazas de:
  - request started
  - request completed
  - request failed
- los servicios de `inventory` y `shadows` ya emiten logs estructurados de lectura/sync

### Resultado operativo

La historia integrada queda asi:

1. Flutter hace bootstrap y selecciona fuente.
2. Lee backend como verdad durable para `inventory` y `shadows`.
3. Ejecuta mutaciones de `quests` con rollback si la confirmacion backend falla.
4. Persiste nuevamente el estado reconciliado en cache local.

### Deuda conocida

- la `special quest decision` todavia no tiene endpoint propio en backend y sigue siendo `local_only`
- siguen presentes warnings viejos de aliases `Pydantic` en tests; no bloquean la baseline de `Phase 4`

### Verificacion de Phase 4

Al cierre de la fase se verifico:

- `py -3 -m pytest tests -q`
- `py -3 -m compileall app tests`

La expectativa de la baseline actual es que el backend pase completo con el contrato nuevo de `requestId` y los endpoints durables de `inventory` + `shadows`.
