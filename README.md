# Solo Leveling Calisthenics

App mobile inspirada en la progresion de `Solo Leveling`, aplicada a entrenamiento de calistenia.

## Enfoque tecnico

Tu stack preferido sigue teniendo sentido:

- `Flutter` para la app mobile: una sola base para Android/iOS.
- `FastAPI` para backend futuro: autenticacion, rutinas, progreso, ranking, inventario y sincronizacion.
- `React + Tailwind` para panel web admin o landing.

La recomendacion de usar Flutter para mobile es buena si queres:

- velocidad de desarrollo;
- una UI visualmente fuerte sin duplicar Android/iOS;
- escalar luego hacia animaciones, gamificacion y dashboards.

No puedo evaluar los "puntos e instrucciones" de la otra IA porque no estan en el chat actual. Si me los pegas, los reviso uno por uno y te digo que conservar, que corregir y que descartar.

## Estado actual

El repo ya no esta solo en etapa visual. Hoy tiene una base funcional y una primera capa arquitectonica seria:

- Flutter con `Riverpod` para el vertical inicial de bootstrap del jugador;
- `FastAPI` modularizando el flujo `player bootstrap / progreso base`;
- logging y manejo de errores centralizados en frontend y backend;
- `Alembic` como camino formal de migraciones;
- sincronizacion inicial entre app y backend desplegado.

## Estructura

```text
backend/
  alembic/
  app/
    core/
    modules/
      player/
  Dockerfile
  requirements.txt
  .env.example
lib/
  app.dart
  main.dart
  core/
    errors/
    logging/
    network/
    providers/
    theme/
  features/
    home/
      domain/
      presentation/
    player/
      application/
      data/
      domain/
```

## Estado del entorno

El proyecto ya fue inicializado con Flutter y se dejo un SDK local en `tools/flutter` para trabajo inmediato. Ese SDK esta ignorado en Git para no subir gigas innecesarios al repo.

Tambien se dejo un backend `FastAPI` en `backend/`, preparado para desplegarse como servicio separado en Railway. La app hoy consume el servicio remoto configurado en produccion mientras la base local sigue creciendo por fases.

## Ejecucion local

Desde la raiz del repo podes usar:

1. `.\flutterw.ps1 doctor -v`
2. `.\flutterw.ps1 pub get`
3. `.\flutterw.ps1 run -d windows`
4. `.\flutterw.ps1 run -d chrome`

Para levantar el backend local:

1. `cd backend`
2. `py -3 -m venv .venv`
3. `. .venv\Scripts\Activate.ps1`
4. `pip install -r requirements.txt`
5. `py -3 -m uvicorn app.main:app --reload`

Para correr en Android todavia falta instalar Android Studio o al menos Android SDK y luego configurar `flutter config --android-sdk`.

## Roadmap recomendado

1. `MVP mobile`
   - onboarding
   - login local/mock
   - dashboard
   - rutina diaria
   - progreso de stats
   - quests
2. `Backend FastAPI`
   - usuarios
   - rutinas
   - sesiones
   - progreso
   - logros
3. `Version online`
   - autenticacion
   - almacenamiento
   - sincronizacion cloud
   - ranking social

## Railway

El backend se puede subir como un servicio nuevo en Railway usando este mismo repo:

1. crear un servicio desde GitHub;
2. configurar `Root Directory = backend`;
3. Railway detectara el `Dockerfile` y levantara la API;
4. usar `/health` como healthcheck.

Ademas, la capa de base de datos ya quedo preparada:

- `SQLite` por defecto para desarrollo local;
- `Postgres` listo para usarse cuando Railway exponga `DATABASE_URL`;
- modelos iniciales para usuario, progreso, inventario y quests;
- seed automatico del jugador base al arrancar.

## Phase 1 Baseline

La primera fase del refactor agresivo deja esta base:

- `Riverpod` ya gobierna el bootstrap del jugador y el fallback remoto/local;
- `HomeController` deja de ser la fuente inicial de carga y pasa a concentrarse en la logica del juego;
- backend con `app/core` y `app/modules/player` como primer modulo real;
- `Alembic` agregado como baseline de migraciones;
- tests dedicados para:
  - mapeo de errores,
  - repository bootstrap,
  - controller bootstrap,
  - contrato backend del jugador.

Esta fase no migra toda la app. Construye la base defendible para seguir con `quests`, `inventory`, `shadows` y `sharing` sin volver a mezclar UI, dominio y acceso a datos.

Referencias oficiales Railway:
- FastAPI guide: https://docs.railway.com/guides/fastapi
- Start command: https://docs.railway.com/guides/start-command
