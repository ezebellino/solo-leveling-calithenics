# Phase 4 Sync And Observability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` for execution. This phase crosses frontend state ownership, backend contracts and logging, so each task must have a narrow write scope, explicit verification and its own commit.

**Goal:** Ejecutar el endurecimiento del sistema dejando `Flutter`, `FastAPI` y `Postgres` sincronizados de forma consistente, con ownership claro del estado durable, reconciliacion controlada de acciones, errores normalizados y observabilidad basica preparada para produccion.

**Architecture:** La fase se ejecuta por verticales funcionales, no por capas vacias. Primero se fija el ownership de sync de `player bootstrap`, despues se endurecen `quests`, luego `inventory` y `shadows`, despues se completa la observabilidad transversal y finalmente se verifica la integracion real de punta a punta. El backend sigue siendo la fuente de verdad durable; el frontend usa cache local y actualizaciones optimistas solo donde sean defendibles.

**Tech Stack:** Flutter, Riverpod, FastAPI, SQLAlchemy, Alembic, PostgreSQL/SQLite fallback, pytest

---

## File Structure Lock-In

### Frontend areas expected to evolve

- `lib/features/player/application/`
- `lib/features/player/data/`
- `lib/features/quests/application/`
- `lib/features/quests/data/`
- `lib/features/inventory/application/`
- `lib/features/inventory/data/`
- `lib/features/shadows/application/`
- `lib/features/shadows/data/`
- `lib/core/errors/`
- `lib/core/logging/`

### Backend areas expected to evolve

- `backend/app/modules/player/`
- `backend/app/modules/quests/`
- `backend/app/modules/inventory/`
- `backend/app/modules/shadows/`
- `backend/app/modules/system/`
- `backend/app/core/`

### Frontend tests expected

- `test/features/player/`
- `test/features/quests/`
- `test/features/inventory/`
- `test/features/shadows/`
- `test/core/errors/`

### Backend tests expected

- `backend/tests/test_player_bootstrap.py`
- `backend/tests/test_quests.py`
- `backend/tests/test_inventory.py`
- `backend/tests/test_shadows.py`
- `backend/tests/test_error_handling.py`
- integration-focused sync tests if needed

---

## Task 1: Lock down sync ownership for `player bootstrap`

**Files:**
- Modify: `lib/features/player/application/`
- Modify: `lib/features/player/data/`
- Modify: `lib/features/app_shell/`
- Modify: `backend/app/modules/player/`
- Modify: `backend/app/modules/system/` if bootstrap metadata needs cleanup

- [ ] **Step 1: Define the authoritative bootstrap contract**

Make the bootstrap contract explicit:

- what comes from remote
- what is allowed to come from local cache
- what fields are durable
- what fields are only UI convenience

- [ ] **Step 2: Centralize bootstrap reconciliation in the player feature**

The player feature should own:

- remote fetch
- local cache read/write
- source selection
- success/error/fallback state

Avoid pushing this logic back into `app_shell`.

- [ ] **Step 3: Make remote-vs-local source visible in logs**

Log at least:

- bootstrap started
- remote fetch succeeded
- remote fetch failed
- local fallback used
- final hydrated source

- [ ] **Step 4: Verify player bootstrap end-to-end**

Frontend tests should cover:

- remote success
- remote failure with local fallback
- no local cache and remote failure

Backend tests should ensure the player snapshot contract remains stable.

- [ ] **Step 5: Commit bootstrap sync ownership**

```powershell
git add lib/features/player lib/features/app_shell lib/core/logging backend/app/modules/player backend/app/modules/system test/features/player backend/tests/test_player_bootstrap.py
git commit -m "refactor: harden player bootstrap sync ownership"
```

## Task 2: Reconcile `quests` actions against backend truth

**Files:**
- Modify: `lib/features/quests/application/`
- Modify: `lib/features/quests/data/`
- Modify: `lib/features/quests/presentation/`
- Modify: `backend/app/modules/quests/`
- Modify if needed: `lib/features/system/` for error presentation

- [ ] **Step 1: Define quest action lifecycle**

Each quest action should clearly pass through:

- optimistic UI change if applicable
- backend call
- reconciliation
- rollback on failure
- local cache persistence

Do this for:

- advance quest
- complete quest
- special quest decision

- [ ] **Step 2: Make the quests feature own its sync state**

The feature should expose explicit states such as:

- idle
- submitting action
- reconciled
- rollback/error

Avoid hidden coupling with global controllers.

- [ ] **Step 3: Normalize backend error contracts for quest mutations**

The backend should return stable and safe error responses for:

- missing quest
- invalid transition
- persistence failure

- [ ] **Step 4: Improve quest logging**

Frontend logs:

- action started
- action succeeded
- action failed
- rollback applied

Backend logs:

- endpoint
- quest id
- action type
- failure reason

- [ ] **Step 5: Verify quest reconciliation**

Frontend tests should cover:

- optimistic transition succeeds
- optimistic transition rolls back on backend failure
- special quest decision persists correctly

Backend tests should cover:

- advance and complete remain consistent
- invalid quest mutation returns structured error

- [ ] **Step 6: Commit quest sync hardening**

```powershell
git add lib/features/quests lib/features/system lib/core/errors backend/app/modules/quests test/features/quests backend/tests/test_quests.py backend/tests/test_error_handling.py
git commit -m "refactor: reconcile quest actions with backend truth"
```

## Task 3: Align `inventory` and `shadows` with durable backend state

**Files:**
- Modify: `lib/features/inventory/application/`
- Modify: `lib/features/inventory/data/`
- Modify: `lib/features/shadows/application/`
- Modify: `lib/features/shadows/data/`
- Modify: `backend/app/modules/inventory/`
- Modify: `backend/app/modules/shadows/`

- [ ] **Step 1: Define inventory and shadows sync boundaries**

Explicitly define:

- what inventory state is durable
- what shadow state is durable
- what can remain cached locally for UX

- [ ] **Step 2: Add or harden read-side refresh flows**

Both features should support:

- initial read from cache if useful
- remote refresh
- reconciliation into a stable feature state

- [ ] **Step 3: Remove implicit local truth**

The frontend must stop behaving as if:

- inventory is durable locally
- shadow unlock state can be considered final without backend confirmation

- [ ] **Step 4: Improve logging for these features**

Log at least:

- feature bootstrap/refresh started
- remote read succeeded
- remote read failed
- local fallback used if any

- [ ] **Step 5: Verify inventory/shadows consistency**

Frontend tests should cover:

- inventory refresh from remote
- shadow progression refresh from remote
- cache fallback when remote fails

Backend tests should cover:

- inventory read contract
- shadow progression read contract

- [ ] **Step 6: Commit inventory and shadows sync alignment**

```powershell
git add lib/features/inventory lib/features/shadows backend/app/modules/inventory backend/app/modules/shadows test/features/inventory test/features/shadows backend/tests/test_inventory.py backend/tests/test_shadows.py
git commit -m "refactor: align inventory and shadows sync state"
```

## Task 4: Establish observability baseline across frontend and backend

**Files:**
- Modify: `lib/core/logging/`
- Modify: `lib/core/errors/`
- Modify: feature-level application layers as needed
- Modify: `backend/app/core/logging.py`
- Modify: `backend/app/core/errors.py`
- Modify: `backend/app/core/request_context.py`
- Modify: backend modules as needed

- [ ] **Step 1: Normalize frontend logging shape**

All sync-critical features should emit structured logs with consistent fields:

- feature
- action
- source
- entity id
- outcome

- [ ] **Step 2: Normalize backend logging shape**

Ensure request/module logs expose enough context for diagnosis:

- module
- route
- action
- player identifier when relevant
- result

- [ ] **Step 3: Harden error mapping**

Frontend:

- user-facing message
- retry semantics
- internal logging context

Backend:

- safe API error payload
- internal trace in logs

- [ ] **Step 4: Make request context visible**

Add simple correlation-friendly context where feasible so a request failure can be tracked through logs.

- [ ] **Step 5: Verify observability behavior**

Tests or focused checks should prove:

- structured error responses still serialize correctly
- frontend error mapper behaves predictably
- request logging path still compiles and runs

- [ ] **Step 6: Commit observability baseline**

```powershell
git add lib/core/logging lib/core/errors backend/app/core lib/features/player lib/features/quests lib/features/inventory lib/features/shadows test/core backend/tests/test_error_handling.py
git commit -m "refactor: establish sync observability baseline"
```

## Task 5: Integration verification and production-readiness pass

**Files:**
- Modify: `README.md`
- Modify: `backend/README.md`
- Add tests or fixtures if needed

- [ ] **Step 1: Run focused frontend verification**

At minimum verify:

- bootstrap hydration
- quest action reconciliation
- special quest decision persistence
- inventory read
- shadow progression read

- [ ] **Step 2: Run focused backend verification**

Run:

```powershell
Set-Location backend
py -3 -m pytest tests -q
py -3 -m compileall app tests
```

- [ ] **Step 3: Verify the integrated app story**

Confirm that the app now has:

- one clear bootstrap path
- one clear mutation/reconcile path
- predictable fallback behavior
- useful logs for real failures

- [ ] **Step 4: Update docs**

Document in:

- `README.md`
- `backend/README.md`

What changed in `Phase 4`:

- sync authority rules
- fallback policy
- observability baseline
- expected future work (`auth`, `sharing`)

- [ ] **Step 5: Final commit for Phase 4 baseline**

```powershell
git add README.md backend/README.md test backend/tests
git commit -m "docs: document phase 4 sync and observability baseline"
```

---

## Execution Rules

- Do not run parallel subtasks that edit the same feature state owners at the same time.
- Prefer one subagent per vertical:
  - `player bootstrap`
  - `quests sync`
  - `inventory and shadows sync`
  - `observability`
- Integrate and verify each block before opening the next one if shared files overlap.
- Keep `DEVELOPMENT_PLAN.md`, `.codex-worktrees/` internals and temporary run logs out of commits.

## Success Criteria

`Phase 4` is successful if:

- `player`, `quests`, `inventory` and `shadows` have explicit sync ownership
- backend truth vs local cache is no longer ambiguous
- quest mutations reconcile correctly instead of relying on hopeful local state
- logs in frontend and backend are useful for real diagnosis
- errors are normalized and user feedback is consistent
- the system is ready for `auth`, `sharing` and more serious production usage
