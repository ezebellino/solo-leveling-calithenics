# Backend FastAPI

Backend preparado para desplegarse como servicio en Railway.

Estado actual:

- backend listo para `SQLite` local y `Postgres` via `DATABASE_URL`
- `Alembic` agregado como baseline de migraciones
- primer modulo real: `app/modules/player`
- `app/core` concentra config, DB, logging, errores y request context

## Endpoints actuales

- `GET /`
- `GET /health`
- `GET /api/v1/bootstrap`
- `GET /api/v1/player`
- `PATCH /api/v1/player/progress`

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

La estructura objetivo ya quedo iniciada:

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
```

El siguiente paso natural es repetir este patron para `quests`, `inventory`, `shadows` y `system`.
