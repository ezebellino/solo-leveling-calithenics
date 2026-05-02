# Backend FastAPI

Backend preparado para desplegarse como servicio en Railway.

Estado actual:

- servicio activo Railway: `backend-api-clean`
- dominio publico: `https://backend-api-clean-production.up.railway.app`
- base de datos por defecto en desarrollo: `SQLite`
- base de datos objetivo en produccion: `Postgres` via `DATABASE_URL`

## Endpoints iniciales

- `GET /`
- `GET /health`
- `GET /api/v1/bootstrap`

## Desarrollo local

```powershell
cd backend
py -3 -m venv .venv
. .venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Con la configuracion actual, si no definis `DATABASE_URL`, el backend crea `solo_leveling.db` local y siembra un jugador base con progreso, inventario y quests iniciales.

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
