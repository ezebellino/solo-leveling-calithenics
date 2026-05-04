# Phase 1 Core Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir la base arquitectonica escalable del proyecto con `core` frontend/backend, `Riverpod`, `Alembic`, logging estructurado y manejo centralizado de errores, validando la nueva arquitectura con el flujo real `player bootstrap / progreso base`.

**Architecture:** La implementacion se hace por cortes verticales que mantengan la app utilizable. Primero se crea la infraestructura compartida del backend y del frontend, luego se migra el flujo `player bootstrap / progreso base` a la nueva arquitectura, y por ultimo se conecta todo con tests y logging real. No se migra toda la app: solo el vertical necesario para probar la base.

**Tech Stack:** Flutter, Riverpod, FastAPI, SQLAlchemy, Alembic, PostgreSQL/SQLite fallback, flutter_test, pytest

---

## File Structure Lock-In

### Frontend files to create

- `lib/core/logging/app_logger.dart`
- `lib/core/errors/app_exception.dart`
- `lib/core/errors/error_mapper.dart`
- `lib/core/network/api_result.dart`
- `lib/core/network/http_client_provider.dart`
- `lib/core/providers/core_providers.dart`
- `lib/features/player/domain/player_snapshot.dart`
- `lib/features/player/domain/player_repository.dart`
- `lib/features/player/application/bootstrap_player_use_case.dart`
- `lib/features/player/application/bootstrap_player_state.dart`
- `lib/features/player/application/bootstrap_player_controller.dart`
- `lib/features/player/data/player_api_client.dart`
- `lib/features/player/data/player_local_data_source.dart`
- `lib/features/player/data/player_repository_impl.dart`

### Frontend files to modify

- `pubspec.yaml`
- `lib/app.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/presentation/controllers/home_controller.dart`
- `lib/features/home/data/home_api_client.dart`
- `lib/features/home/data/local_player_state_repository.dart`

### Frontend tests to create

- `test/features/player/bootstrap_player_controller_test.dart`
- `test/core/errors/error_mapper_test.dart`
- `test/features/player/player_repository_impl_test.dart`

### Backend files to create

- `backend/alembic.ini`
- `backend/alembic/env.py`
- `backend/alembic/script.py.mako`
- `backend/alembic/versions/20260504_01_initial_player_module.py`
- `backend/app/core/__init__.py`
- `backend/app/core/config.py`
- `backend/app/core/database.py`
- `backend/app/core/logging.py`
- `backend/app/core/errors.py`
- `backend/app/core/request_context.py`
- `backend/app/modules/player/__init__.py`
- `backend/app/modules/player/api/router.py`
- `backend/app/modules/player/api/schemas.py`
- `backend/app/modules/player/application/service.py`
- `backend/app/modules/player/domain/entities.py`
- `backend/app/modules/player/domain/exceptions.py`
- `backend/app/modules/player/infrastructure/models.py`
- `backend/app/modules/player/infrastructure/repository.py`

### Backend files to modify

- `backend/requirements.txt`
- `backend/app/main.py`
- `backend/app/models.py`
- `backend/app/database.py`
- `backend/app/config.py`
- `backend/app/services.py`
- `backend/app/schemas.py`

### Backend tests to create

- `backend/tests/test_player_bootstrap.py`
- `backend/tests/test_error_handling.py`

---

### Task 1: Install Riverpod and backend migration/test dependencies

**Files:**
- Modify: `pubspec.yaml`
- Modify: `backend/requirements.txt`

- [ ] **Step 1: Add Riverpod dependency in Flutter**

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  cupertino_icons: ^1.0.8
  http: ^1.5.0
  image_picker: ^1.2.0
  shared_preferences: ^2.5.3
```

- [ ] **Step 2: Add Alembic and backend test dependencies**

Append to `backend/requirements.txt`:

```txt
alembic==1.16.4
pytest==8.4.1
httpx==0.28.1
```

- [ ] **Step 3: Refresh Flutter packages**

Run:

```powershell
.\flutterw.ps1 pub get
```

Expected: `Got dependencies!`

- [ ] **Step 4: Commit dependency baseline**

```powershell
git add pubspec.yaml pubspec.lock backend/requirements.txt
git commit -m "chore: add phase 1 foundation dependencies"
```

### Task 2: Create backend core package and logging/error infrastructure

**Files:**
- Create: `backend/app/core/__init__.py`
- Create: `backend/app/core/config.py`
- Create: `backend/app/core/database.py`
- Create: `backend/app/core/logging.py`
- Create: `backend/app/core/errors.py`
- Create: `backend/app/core/request_context.py`
- Modify: `backend/app/main.py`

- [ ] **Step 1: Create `backend/app/core/config.py`**

```python
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "solo-leveling-api"
    app_env: str = "development"
    api_prefix: str = "/api/v1"
    allowed_origin: str = "*"
    database_url: str = "sqlite:///./solo_leveling.db"
    log_level: str = "INFO"


settings = Settings()
```

- [ ] **Step 2: Create `backend/app/core/logging.py`**

```python
import logging


def configure_logging(level: str) -> None:
    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )


logger = logging.getLogger("solo_leveling")
```

- [ ] **Step 3: Create `backend/app/core/errors.py`**

```python
from fastapi import Request
from fastapi.responses import JSONResponse


class AppError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400):
        super().__init__(message)
        self.code = code
        self.message = message
        self.status_code = status_code


async def app_error_handler(_: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": {"code": exc.code, "message": exc.message}},
    )
```

- [ ] **Step 4: Create request correlation middleware helper**

`backend/app/core/request_context.py`:

```python
import time
import uuid
from collections.abc import Awaitable, Callable

from fastapi import Request, Response

from .logging import logger


async def request_logging_middleware(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    request_id = str(uuid.uuid4())
    started_at = time.perf_counter()
    request.state.request_id = request_id
    response = await call_next(request)
    elapsed_ms = round((time.perf_counter() - started_at) * 1000, 2)
    logger.info(
        "request_completed",
        extra={
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "elapsed_ms": elapsed_ms,
        },
    )
    response.headers["X-Request-Id"] = request_id
    return response
```

- [ ] **Step 5: Wire backend core into `backend/app/main.py`**

Adjust imports and startup:

```python
from app.core.config import settings
from app.core.errors import AppError, app_error_handler
from app.core.logging import configure_logging
from app.core.request_context import request_logging_middleware
```

And in module init:

```python
configure_logging(settings.log_level)
app = FastAPI(...)
app.add_exception_handler(AppError, app_error_handler)
app.middleware("http")(request_logging_middleware)
```

- [ ] **Step 6: Run backend import smoke check**

Run:

```powershell
py -3 -m compileall backend\app
```

Expected: compile succeeds

- [ ] **Step 7: Commit backend core scaffold**

```powershell
git add backend/app/core backend/app/main.py
git commit -m "refactor: add backend core logging and error infrastructure"
```

### Task 3: Introduce Alembic and formal migration baseline

**Files:**
- Create: `backend/alembic.ini`
- Create: `backend/alembic/env.py`
- Create: `backend/alembic/script.py.mako`
- Create: `backend/alembic/versions/20260504_01_initial_player_module.py`
- Modify: `backend/app/database.py`

- [ ] **Step 1: Make SQLAlchemy metadata importable from a stable place**

Ensure `backend/app/database.py` exposes:

```python
from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
```

- [ ] **Step 2: Create `backend/alembic.ini` minimal config**

```ini
[alembic]
script_location = alembic
sqlalchemy.url = sqlite:///./solo_leveling.db

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic
```

- [ ] **Step 3: Create `backend/alembic/env.py`**

Include:

```python
from alembic import context
from sqlalchemy import engine_from_config, pool

from app.core.config import settings
from app.core.database import Base
from app.modules.player.infrastructure import models as player_models  # noqa: F401
```

And set:

```python
config.set_main_option("sqlalchemy.url", settings.database_url)
target_metadata = Base.metadata
```

- [ ] **Step 4: Create initial migration for player tables**

Create revision file with `upgrade()` and `downgrade()` for the player-oriented tables currently needed by bootstrap. Keep it explicit instead of autogenerate-only.

- [ ] **Step 5: Remove schema bootstrap from service startup path**

The old path in `backend/app/services.py` currently calls:

```python
Base.metadata.create_all(bind=engine)
_run_lightweight_migrations()
```

Replace with a migration-first approach. In this phase, keep fallback seeding, but stop mutating schema there.

- [ ] **Step 6: Smoke test Alembic configuration**

Run:

```powershell
Set-Location backend
py -3 -m alembic current
```

Expected: command runs without import/config errors

- [ ] **Step 7: Commit Alembic baseline**

```powershell
git add backend/alembic.ini backend/alembic backend/app/database.py backend/app/services.py
git commit -m "refactor: add alembic migration baseline"
```

### Task 4: Create backend player module boundaries

**Files:**
- Create: `backend/app/modules/player/api/router.py`
- Create: `backend/app/modules/player/api/schemas.py`
- Create: `backend/app/modules/player/application/service.py`
- Create: `backend/app/modules/player/domain/entities.py`
- Create: `backend/app/modules/player/domain/exceptions.py`
- Create: `backend/app/modules/player/infrastructure/models.py`
- Create: `backend/app/modules/player/infrastructure/repository.py`
- Modify: `backend/app/main.py`
- Modify: `backend/app/models.py`
- Modify: `backend/app/services.py`
- Modify: `backend/app/schemas.py`

- [ ] **Step 1: Define player API schemas**

Move the player/bootstrap response contracts into `backend/app/modules/player/api/schemas.py`. At minimum create:

```python
class PlayerSummary(BaseModel): ...
class StageSummary(BaseModel): ...
class PlayerOverviewResponse(BaseModel): ...
class BootstrapResponse(BaseModel): ...
class UpdatePlayerProgressRequest(BaseModel): ...
```

- [ ] **Step 2: Create player repository**

`backend/app/modules/player/infrastructure/repository.py` should expose small methods:

```python
class PlayerRepository:
    def get_default_user(self, session: Session) -> User: ...
    def save(self, session: Session) -> None: ...
```

- [ ] **Step 3: Create player application service**

`backend/app/modules/player/application/service.py` should expose:

```python
def get_player_bootstrap(session: Session) -> BootstrapResponse: ...
def get_player_overview(session: Session) -> PlayerOverviewResponse: ...
def update_player_progress(session: Session, payload: UpdatePlayerProgressRequest) -> PlayerOverviewResponse: ...
```

- [ ] **Step 4: Create player router**

`backend/app/modules/player/api/router.py`:

```python
router = APIRouter(prefix=settings.api_prefix, tags=["player"])

@router.get("/bootstrap")
def bootstrap(...): ...

@router.get("/player")
def player_overview(...): ...

@router.patch("/player/progress")
def patch_player_progress(...): ...
```

- [ ] **Step 5: Mount router in `backend/app/main.py`**

```python
from app.modules.player.api.router import router as player_router
app.include_router(player_router)
```

- [ ] **Step 6: Keep compatibility layer while trimming old files**

`backend/app/services.py` and `backend/app/schemas.py` should stop being the growth path. For this phase they can re-export or delegate if needed, but the new router must depend on the module package, not the old generic services module.

- [ ] **Step 7: Run backend compile smoke test**

```powershell
py -3 -m compileall backend\app
```

Expected: success

- [ ] **Step 8: Commit player backend module**

```powershell
git add backend/app/modules backend/app/main.py backend/app/models.py backend/app/services.py backend/app/schemas.py
git commit -m "refactor: add modular player backend flow"
```

### Task 5: Add backend tests for player bootstrap and error handling

**Files:**
- Create: `backend/tests/test_player_bootstrap.py`
- Create: `backend/tests/test_error_handling.py`

- [ ] **Step 1: Write bootstrap contract test**

Add a FastAPI test client test like:

```python
def test_bootstrap_returns_player_stage_and_flags(client):
    response = client.get("/api/v1/bootstrap")
    assert response.status_code == 200
    payload = response.json()
    assert "player" in payload
    assert "stage" in payload
    assert "featureFlags" in payload
```

- [ ] **Step 2: Write player overview test**

```python
def test_player_overview_returns_inventory_and_completed_days(client):
    response = client.get("/api/v1/player")
    assert response.status_code == 200
    payload = response.json()
    assert "inventory" in payload
    assert "completedDays" in payload
```

- [ ] **Step 3: Write error handler test**

Create a route or test path that raises `AppError` and assert:

```python
assert response.status_code == 400
assert response.json()["error"]["code"] == "example_error"
```

- [ ] **Step 4: Run backend tests**

Run:

```powershell
Set-Location backend
py -3 -m pytest tests -q
```

Expected: passing tests

- [ ] **Step 5: Commit backend test coverage**

```powershell
git add backend/tests
git commit -m "test: add backend player bootstrap and error coverage"
```

### Task 6: Create frontend core logging, error, and network primitives

**Files:**
- Create: `lib/core/logging/app_logger.dart`
- Create: `lib/core/errors/app_exception.dart`
- Create: `lib/core/errors/error_mapper.dart`
- Create: `lib/core/network/api_result.dart`
- Create: `lib/core/network/http_client_provider.dart`
- Create: `lib/core/providers/core_providers.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Create `lib/core/logging/app_logger.dart`**

```dart
enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger();

  void log({
    required LogLevel level,
    required String event,
    String source = 'app',
    Map<String, Object?> context = const {},
  }) {
    debugPrint('[${level.name}] $source::$event $context');
  }
}
```

- [ ] **Step 2: Create error model**

`lib/core/errors/app_exception.dart`:

```dart
class AppException implements Exception {
  const AppException(this.code, this.message);

  final String code;
  final String message;
}
```

- [ ] **Step 3: Create error mapper**

`lib/core/errors/error_mapper.dart`:

```dart
import 'dart:io';

import 'app_exception.dart';

AppException mapToAppException(Object error) {
  if (error is AppException) return error;
  if (error is SocketException) {
    return const AppException('network_unavailable', 'No se pudo conectar al servidor.');
  }
  return const AppException('unknown_error', 'Ocurrio un error inesperado.');
}
```

- [ ] **Step 4: Create core providers**

`lib/core/providers/core_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logging/app_logger.dart';

final appLoggerProvider = Provider<AppLogger>((ref) => const AppLogger());
```

- [ ] **Step 5: Wrap app in Riverpod**

In `lib/app.dart` or `lib/main.dart` wrap root with:

```dart
runApp(const ProviderScope(child: SoloLevelingApp()));
```

- [ ] **Step 6: Add frontend unit test for error mapper**

Create `test/core/errors/error_mapper_test.dart`:

```dart
test('maps socket exception to network error', () {
  final exception = mapToAppException(const SocketException('offline'));
  expect(exception.code, 'network_unavailable');
});
```

- [ ] **Step 7: Run frontend focused test**

```powershell
.\flutterw.ps1 test test\core\errors\error_mapper_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 8: Commit frontend core primitives**

```powershell
git add lib/core lib/app.dart lib/main.dart test/core/errors/error_mapper_test.dart
git commit -m "refactor: add frontend core logging and error primitives"
```

### Task 7: Create frontend player feature and Riverpod bootstrap flow

**Files:**
- Create: `lib/features/player/domain/player_snapshot.dart`
- Create: `lib/features/player/domain/player_repository.dart`
- Create: `lib/features/player/application/bootstrap_player_use_case.dart`
- Create: `lib/features/player/application/bootstrap_player_state.dart`
- Create: `lib/features/player/application/bootstrap_player_controller.dart`
- Create: `lib/features/player/data/player_api_client.dart`
- Create: `lib/features/player/data/player_local_data_source.dart`
- Create: `lib/features/player/data/player_repository_impl.dart`
- Modify: `lib/features/home/data/home_api_client.dart`
- Modify: `lib/features/home/data/local_player_state_repository.dart`

- [ ] **Step 1: Define player snapshot domain object**

`lib/features/player/domain/player_snapshot.dart` should contain a focused model for bootstrap only:

```dart
class PlayerSnapshot {
  const PlayerSnapshot({
    required this.alias,
    required this.rank,
    required this.title,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.completedDays,
  });
}
```

- [ ] **Step 2: Define repository contract**

`lib/features/player/domain/player_repository.dart`:

```dart
abstract class PlayerRepository {
  Future<PlayerSnapshot> bootstrap();
}
```

- [ ] **Step 3: Create API client for player feature**

Move player/bootstrap HTTP calls out of `HomeApiClient` into `PlayerApiClient`:

```dart
class PlayerApiClient {
  Future<Map<String, dynamic>> fetchBootstrapJson() async { ... }
  Future<Map<String, dynamic>> fetchPlayerJson() async { ... }
}
```

- [ ] **Step 4: Create repository implementation**

`PlayerRepositoryImpl` should:

- request remote snapshot
- fallback to local source when remote fails
- log the path taken
- map all errors through `AppException`

- [ ] **Step 5: Create Riverpod state and controller**

`bootstrap_player_state.dart`:

```dart
class BootstrapPlayerState {
  const BootstrapPlayerState({
    this.snapshot,
    this.isLoading = false,
    this.errorMessage,
  });
}
```

`bootstrap_player_controller.dart`:

```dart
final bootstrapPlayerControllerProvider =
    NotifierProvider<BootstrapPlayerController, BootstrapPlayerState>(...);
```

with:

```dart
Future<void> load() async { ... }
```

- [ ] **Step 6: Add tests for controller and repository**

Create `test/features/player/bootstrap_player_controller_test.dart` and `test/features/player/player_repository_impl_test.dart`.

Minimum controller expectations:

```dart
expect(state.isLoading, true);
expect(state.snapshot, isNotNull);
```

Minimum repository expectations:

```dart
expect(snapshot.alias, isNotEmpty);
```

- [ ] **Step 7: Run focused tests**

```powershell
.\flutterw.ps1 test test\features\player\bootstrap_player_controller_test.dart
.\flutterw.ps1 test test\features\player\player_repository_impl_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 8: Commit player frontend feature**

```powershell
git add lib/features/player lib/features/home/data/home_api_client.dart lib/features/home/data/local_player_state_repository.dart test/features/player
git commit -m "refactor: add Riverpod player bootstrap feature"
```

### Task 8: Integrate home flow with new player bootstrap vertical

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Modify: `lib/features/home/domain/player_state.dart`

- [ ] **Step 1: Stop treating HomeController as bootstrap source of truth**

`HomePage` should read the initial player snapshot from the new Riverpod player bootstrap flow, not from `HomeController.load()` as the only source of truth.

- [ ] **Step 2: Keep existing game logic but feed it from the new snapshot**

The migration target in this phase is not to delete `HomeController`; it is to make bootstrap start through the new architecture and then hydrate the old flow safely.

- [ ] **Step 3: Log bootstrap lifecycle**

Add logger calls for:

```dart
bootstrap_started
bootstrap_remote_success
bootstrap_local_fallback
bootstrap_failed
```

- [ ] **Step 4: Show consistent bootstrap failure UI**

If both remote and local fail, show a stable message instead of silent crash:

```dart
Text('No se pudo cargar el estado del jugador.')
FilledButton(onPressed: retry, child: Text('REINTENTAR'))
```

- [ ] **Step 5: Run analyze**

```powershell
.\flutterw.ps1 analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit integration step**

```powershell
git add lib/features/home/presentation/pages/home_page.dart lib/features/home/presentation/controllers/home_controller.dart lib/features/home/domain/player_state.dart
git commit -m "refactor: integrate home bootstrap with Riverpod player flow"
```

### Task 9: End-to-end verification and documentation update

**Files:**
- Modify: `README.md`
- Modify if needed: `backend/README.md`

- [ ] **Step 1: Start backend locally**

Run:

```powershell
Set-Location backend
py -3 -m uvicorn app.main:app --reload
```

Expected:

```text
Uvicorn running on http://127.0.0.1:8000
```

- [ ] **Step 2: Start Flutter web server**

Run:

```powershell
Set-Location ..
.\flutterw.ps1 run -d web-server --web-port 7361 --web-hostname 127.0.0.1
```

Expected:

```text
lib\main.dart is being served at http://127.0.0.1:7361
```

- [ ] **Step 3: Verify the vertical**

Manually verify:

- player bootstrap loads from backend
- app still opens into the main experience
- remote failure falls back cleanly if simulated
- no crash during startup

- [ ] **Step 4: Update docs**

Add a short section to `README.md` documenting:

- Riverpod now powers bootstrap state
- Alembic is the migration path
- player module is the first modular backend flow

- [ ] **Step 5: Final commit for phase 1 implementation**

```powershell
git add README.md backend/README.md
git commit -m "docs: document phase 1 architecture baseline"
```

