# Backend FastAPI

Backend preparado para desplegarse como servicio en Railway.

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

## Deploy en Railway

1. Crear un nuevo servicio desde este repositorio.
2. En Railway, configurar el `Root Directory` del servicio a `backend`.
3. Dejar que Railway construya el servicio usando el `Dockerfile`.
4. Generar dominio público para el servicio.
5. Variables recomendadas:
   - `APP_ENV=production`
   - `APP_DEBUG=false`
   - `ALLOWED_ORIGIN=*`
   - `DATABASE_URL` cuando agreguemos persistencia real

## Healthcheck sugerido

- Path: `/health`
