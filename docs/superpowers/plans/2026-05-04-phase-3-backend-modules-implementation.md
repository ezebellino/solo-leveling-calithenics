# Phase 3 Backend Modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` for execution. This phase touches backend ownership, routing and persistence boundaries, so each task should have a narrow write scope, a verification step and its own commit.

**Goal:** Ejecutar la modularizacion del backend hacia una arquitectura `module + layers`, extrayendo `quests`, `inventory`, `shadows` y `system` fuera de `main/models/schemas/services`, manteniendo la API funcional y dejando el backend simetrico respecto al frontend actual.

**Architecture:** La migracion se hace por modulos funcionales, no por carpetas vacias. Primero se extrae `quests`, luego `inventory`, despues se introduce `shadows` como modulo backend serio, luego se delimita `system` y finalmente se limpia el legado residual. Cada bloque debe dejar al backend corriendo con el mismo contrato visible o con cambios explicitos y defendibles.

**Tech Stack:** FastAPI, SQLAlchemy, Alembic, PostgreSQL/SQLite fallback, pytest

---

## File Structure Lock-In

### New backend directories to create

- `backend/app/modules/quests/`
- `backend/app/modules/quests/api/`
- `backend/app/modules/quests/application/`
- `backend/app/modules/quests/domain/`
- `backend/app/modules/quests/infrastructure/`
- `backend/app/modules/inventory/`
- `backend/app/modules/inventory/api/`
- `backend/app/modules/inventory/application/`
- `backend/app/modules/inventory/domain/`
- `backend/app/modules/inventory/infrastructure/`
- `backend/app/modules/shadows/`
- `backend/app/modules/shadows/api/`
- `backend/app/modules/shadows/application/`
- `backend/app/modules/shadows/domain/`
- `backend/app/modules/shadows/infrastructure/`
- `backend/app/modules/system/`
- `backend/app/modules/system/api/`
- `backend/app/modules/system/application/`
- `backend/app/modules/system/domain/`
- `backend/app/modules/system/infrastructure/`

### Legacy backend files expected to shrink or stop owning behavior

- `backend/app/main.py`
- `backend/app/services.py`
- `backend/app/models.py`
- `backend/app/schemas.py`

### New backend tests expected

- `backend/tests/test_quests_module.py`
- `backend/tests/test_inventory_module.py`
- `backend/tests/test_shadows_module.py`
- `backend/tests/test_system_module.py`

---

## Task 1: Extract `quests` into a real backend module

**Files:**
- Create: `backend/app/modules/quests/api/router.py`
- Create: `backend/app/modules/quests/api/schemas.py`
- Create: `backend/app/modules/quests/application/service.py`
- Create: `backend/app/modules/quests/domain/entities.py`
- Create: `backend/app/modules/quests/domain/exceptions.py`
- Create: `backend/app/modules/quests/infrastructure/models.py`
- Create: `backend/app/modules/quests/infrastructure/repository.py`
- Modify: `backend/app/main.py`
- Modify: `backend/app/services.py`
- Modify: `backend/app/models.py`
- Modify: `backend/app/schemas.py`

- [ ] **Step 1: Move quest request/response contracts into `modules/quests/api/schemas.py`**

Create dedicated schemas for:

- `AdvanceQuestRequest`
- `DailyQuestResponse`
- `QuestListResponse`

The old generic schemas file must stop being the owner of these contracts.

- [ ] **Step 2: Move quest persistence ownership into `modules/quests/infrastructure`**

Extract:

- `DailyQuest` SQLAlchemy model ownership
- query/list helpers
- lookup by `quest_id`

If temporary imports are needed from legacy files, keep them small and clearly transitional.

- [ ] **Step 3: Create quest repository**

Repository responsibilities:

- fetch today quests for default user
- get quest by id
- persist quest changes

- [ ] **Step 4: Create quest application service**

Application service should own:

- list today quests
- advance quest
- complete quest
- XP/streak side effects currently embedded in generic services

- [ ] **Step 5: Create quest router and mount it in `main.py`**

`main.py` should include the new router and stop depending on generic quest functions.

- [ ] **Step 6: Verify quest endpoints still work**

Run focused backend tests or smoke checks for:

- `GET /api/v1/quests/today`
- `POST /api/v1/quests/{id}/advance`
- `POST /api/v1/quests/{id}/complete`

- [ ] **Step 7: Commit quest extraction**

```powershell
git add backend/app/modules/quests backend/app/main.py backend/app/services.py backend/app/models.py backend/app/schemas.py
git commit -m "refactor: extract quests backend module"
```

## Task 2: Extract `inventory` into a real backend module

**Files:**
- Create: `backend/app/modules/inventory/api/router.py`
- Create: `backend/app/modules/inventory/api/schemas.py`
- Create: `backend/app/modules/inventory/application/service.py`
- Create: `backend/app/modules/inventory/domain/entities.py`
- Create: `backend/app/modules/inventory/domain/exceptions.py`
- Create: `backend/app/modules/inventory/infrastructure/models.py`
- Create: `backend/app/modules/inventory/infrastructure/repository.py`
- Modify: `backend/app/main.py`
- Modify: `backend/app/services.py`
- Modify: `backend/app/models.py`
- Modify: `backend/app/schemas.py`

- [ ] **Step 1: Move inventory response contracts into `modules/inventory/api/schemas.py`**

At minimum:

- `InventoryItemResponse`

- [ ] **Step 2: Move inventory model ownership into module infrastructure**

Extract:

- `InventoryItem` ownership
- repository logic for default user inventory lookup

- [ ] **Step 3: Create inventory application service**

Service should own:

- list inventory items
- future-friendly inventory read abstraction

- [ ] **Step 4: Create inventory router and mount it in `main.py`**

`GET /api/v1/inventory` must route through the module, not through generic services.

- [ ] **Step 5: Verify inventory endpoint contract**

Smoke check:

- `GET /api/v1/inventory`

- [ ] **Step 6: Commit inventory extraction**

```powershell
git add backend/app/modules/inventory backend/app/main.py backend/app/services.py backend/app/models.py backend/app/schemas.py
git commit -m "refactor: extract inventory backend module"
```

## Task 3: Introduce `shadows` as a real backend module

**Files:**
- Create: `backend/app/modules/shadows/api/router.py`
- Create: `backend/app/modules/shadows/api/schemas.py`
- Create: `backend/app/modules/shadows/application/service.py`
- Create: `backend/app/modules/shadows/domain/entities.py`
- Create: `backend/app/modules/shadows/domain/exceptions.py`
- Create: `backend/app/modules/shadows/infrastructure/models.py`
- Create: `backend/app/modules/shadows/infrastructure/repository.py`
- Create if needed: Alembic revision for shadow progression persistence
- Modify: `backend/app/models.py`
- Modify: `backend/app/services.py`

- [ ] **Step 1: Define backend shadow domain shape**

Model the minimum backend truth for shadows:

- unlocked shadow ids or records
- obtained timestamp if useful
- relationship to user

- [ ] **Step 2: Add persistence model and migration if needed**

If current schema is insufficient, create a dedicated Alembic revision instead of inventing tables at startup.

- [ ] **Step 3: Create shadow repository and service**

Service should support at least:

- reading current shadow progression
- mapping unlocked shadows for frontend sync

- [ ] **Step 4: Create minimal shadow API surface**

Only expose what is needed to stop backend ownership from being implicit. A read endpoint is enough if write-side unlocks are still local or transitional.

- [ ] **Step 5: Verify module behavior**

Add tests or smoke checks around shadow progression serialization and schema behavior.

- [ ] **Step 6: Commit shadows module introduction**

```powershell
git add backend/app/modules/shadows backend/alembic backend/app/models.py backend/app/services.py
git commit -m "refactor: add shadows backend module"
```

## Task 4: Create `system` backend boundary

**Files:**
- Create: `backend/app/modules/system/api/router.py`
- Create: `backend/app/modules/system/api/schemas.py`
- Create: `backend/app/modules/system/application/service.py`
- Create: `backend/app/modules/system/domain/entities.py`
- Create: `backend/app/modules/system/domain/exceptions.py`
- Create: `backend/app/modules/system/infrastructure/` as needed
- Modify: `backend/app/main.py`

- [ ] **Step 1: Define what belongs to `system` in backend terms**

Keep the scope intentionally small:

- system/meta responses if useful
- future global notices boundary
- transversals that are not `player`, `quests` or `inventory`

- [ ] **Step 2: Move or create meta/system response contracts**

If `health` or root/meta pieces can be made cleaner through the module without overcomplicating `main.py`, do it here.

- [ ] **Step 3: Keep `main.py` thinner**

The point is not to explode abstractions, but to make the composition line cleaner and future-safe.

- [ ] **Step 4: Verify root and health still respond**

Smoke check:

- `GET /`
- `GET /health`

- [ ] **Step 5: Commit system boundary**

```powershell
git add backend/app/modules/system backend/app/main.py
git commit -m "refactor: add system backend boundary"
```

## Task 5: Reduce or retire legacy monolith files

**Files:**
- Modify heavily or remove:
  - `backend/app/services.py`
  - `backend/app/models.py`
  - `backend/app/schemas.py`
- Modify: `backend/app/main.py`

- [ ] **Step 1: Remove legacy ownership from `services.py`**

After module extraction, `services.py` should either:

- disappear
- or become a tiny compatibility shim with explicit TODO removal target

It must not remain a hidden aggregation point.

- [ ] **Step 2: Remove legacy ownership from `schemas.py`**

Generic schemas should not continue growing. Move remaining module-specific contracts out.

- [ ] **Step 3: Remove legacy ownership from `models.py`**

If still present, it should no longer be the place where new module persistence lives.

- [ ] **Step 4: Simplify `main.py` to composition**

Target responsibilities:

- FastAPI app creation
- middleware
- exception handlers
- router registration
- lifespan/startup minimum

- [ ] **Step 5: Verify compile integrity**

Run:

```powershell
py -3 -m compileall backend\app backend\tests
```

- [ ] **Step 6: Commit legacy cleanup**

```powershell
git add backend/app/main.py backend/app/services.py backend/app/models.py backend/app/schemas.py
git commit -m "refactor: reduce backend legacy monolith files"
```

## Task 6: Backend verification and docs update

**Files:**
- Create: `backend/tests/test_quests_module.py`
- Create: `backend/tests/test_inventory_module.py`
- Create: `backend/tests/test_shadows_module.py`
- Create: `backend/tests/test_system_module.py`
- Modify: `backend/README.md`
- Modify: `README.md`

- [ ] **Step 1: Add module tests**

Minimum test coverage:

- quests list/advance/complete
- inventory list
- shadow progression read contract
- health/root/system smoke

- [ ] **Step 2: Run backend tests**

Run:

```powershell
Set-Location backend
py -3 -m pytest tests -q
```

Expected: all targeted backend tests pass

- [ ] **Step 3: Run compile smoke**

Run:

```powershell
py -3 -m compileall backend\app backend\tests
```

- [ ] **Step 4: Update docs**

Document the new backend module boundaries in:

- `backend/README.md`
- root `README.md`

- [ ] **Step 5: Final commit for Phase 3**

```powershell
git add backend/tests backend/README.md README.md
git commit -m "docs: document phase 3 backend module baseline"
```

---

## Execution Rules

- Do not run two parallel subtasks editing the same legacy files (`main.py`, `services.py`, `models.py`, `schemas.py`) without integration in between.
- Prefer one subagent per backend ownership slice:
  - `quests`
  - `inventory`
  - `shadows`
  - `system`
- Integrate and verify each slice before opening the next one if file overlap is high.
- Keep `DEVELOPMENT_PLAN.md` and temporary run logs out of commits.

## Success Criteria

`Phase 3` is successful if:

- `quests` and `inventory` are real backend modules
- `shadows` exists as a backend module with serious ownership
- `system` is established as a clean transversal backend boundary
- `main.py` is composition-oriented
- `services.py`, `models.py` and `schemas.py` stop being the backend growth bucket
- tests cover the migrated modules
- the API keeps serving the current frontend contract
- another tecnico can recognize the same architectural discipline on both Flutter and FastAPI sides
