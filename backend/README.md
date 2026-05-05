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
