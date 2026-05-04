# Phase 2 Flutter Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` for execution. This phase deliberately touches broad Flutter structure, so each block should have a narrow write scope and a verification step before merge-back.

**Goal:** Ejecutar la migracion del frontend hacia `feature + layers + Riverpod`, creando `app_shell` como frontera real, moviendo ownership de `system`, `quests` e `inventory`, y dejando `home` reducido a compatibilidad temporal o wiring minimo.

**Architecture:** La migracion se hace por bloques funcionales, no por carpetas vacias. Cada bloque debe dejar la app corriendo y con responsabilidades mas claras que antes. `Phase 2` no cambia backend salvo wiring menor inevitable; el foco es Flutter.

**Tech Stack:** Flutter, Riverpod, flutter_test

---

## File Structure Lock-In

### New frontend directories to create

- `lib/features/app_shell/`
- `lib/features/app_shell/application/`
- `lib/features/app_shell/presentation/`
- `lib/features/system/`
- `lib/features/system/application/`
- `lib/features/system/presentation/`
- `lib/features/quests/`
- `lib/features/quests/application/`
- `lib/features/quests/presentation/`
- `lib/features/inventory/`
- `lib/features/inventory/application/`
- `lib/features/inventory/presentation/`

### Files expected to move or be replaced

- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/presentation/controllers/home_controller.dart`
- `lib/features/home/presentation/pages/system_tab.dart`
- `lib/features/home/presentation/pages/quest_tab.dart`
- `lib/features/home/presentation/pages/hunter_tab.dart`
- `lib/features/home/presentation/widgets/chest_reward_overlay.dart`
- `lib/features/home/presentation/widgets/class_evolution_overlay.dart`
- `lib/features/home/presentation/widgets/level_up_overlay.dart`
- `lib/features/home/presentation/widgets/reward_notice_banner.dart`
- `lib/features/home/presentation/widgets/system_backdrop.dart`
- `lib/features/home/presentation/widgets/hud_navigation_bar.dart`

### New tests expected

- `test/features/app_shell/`
- `test/features/system/`
- `test/features/quests/`
- `test/features/inventory/`

---

## Task 1: Create `app_shell` as the new top-level frontend boundary

**Files:**
- Create: `lib/features/app_shell/application/app_shell_state.dart`
- Create: `lib/features/app_shell/application/app_shell_controller.dart`
- Create: `lib/features/app_shell/presentation/pages/app_shell_page.dart`
- Create: `lib/features/app_shell/presentation/widgets/app_shell_frame.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`

- [ ] **Step 1: Define `AppShellState`**

Model the minimum shell concerns:

- selected tab
- previous tab
- startup phase
- top-level overlay priority
- startup error if any

- [ ] **Step 2: Create Riverpod controller for shell**

`app_shell_controller.dart` should own:

- selected tab changes
- retry bootstrap trigger
- visible overlay arbitration at shell level

It should not own quest progression or player reward rules.

- [ ] **Step 3: Create `AppShellPage`**

Move from `HomePage` into the new page:

- bootstrap gate UI
- frame/backdrop shell composition
- bottom navigation shell
- tab switching container
- top-level overlay stack

- [ ] **Step 4: Keep `HomePage` as compatibility wrapper or redirect**

`HomePage` should stop being the real owner of shell logic. It may temporarily forward to `AppShellPage`.

- [ ] **Step 5: Verify**

Run focused tests/analyze around the new shell files.

- [ ] **Step 6: Commit**

```powershell
git add lib/features/app_shell lib/app.dart lib/features/home/presentation/pages/home_page.dart
git commit -m "refactor: introduce app shell feature boundary"
```

## Task 2: Move System-level UI and logic out of `home`

**Files:**
- Create: `lib/features/system/application/system_overlay_state.dart`
- Create: `lib/features/system/application/system_overlay_controller.dart`
- Create: `lib/features/system/presentation/widgets/`
- Move/replace:
  - `class_evolution_overlay.dart`
  - `level_up_overlay.dart`
  - `reward_notice_banner.dart`
  - onboarding `NotificationPanel` ownership

- [ ] **Step 1: Define system overlay state**

This layer should own:

- onboarding visibility
- level-up visibility
- class evolution visibility
- reward notices

- [ ] **Step 2: Extract presentation widgets into `features/system/presentation`**

The widgets move physically and conceptually out of `home`.

- [ ] **Step 3: Connect shell to system overlays**

`app_shell` consumes `system` state instead of building those overlays ad hoc from `home`.

- [ ] **Step 4: Reduce `HomeController` responsibility**

If `HomeController` still produces these events, it should do so through a thinner interface or adapter, not by also deciding how they render.

- [ ] **Step 5: Verify**

Run focused tests for system overlays and shell integration.

- [ ] **Step 6: Commit**

```powershell
git add lib/features/system lib/features/app_shell
git commit -m "refactor: move system overlays out of home"
```

## Task 3: Give `quests` real feature ownership

**Files:**
- Create: `lib/features/quests/application/quest_actions_controller.dart`
- Create: `lib/features/quests/application/quest_actions_state.dart`
- Create: `lib/features/quests/presentation/pages/quests_page.dart`
- Create: `lib/features/quests/presentation/widgets/`
- Move/replace:
  - `quest_tab.dart`
  - `quest_card.dart`

- [ ] **Step 1: Create quest action layer**

Model and own:

- advance daily quest
- advance weekly special quest
- accept/reject special quest
- use reroll
- use XP boost if triggered from quest flow

- [ ] **Step 2: Move quest presentation out of `home`**

`QuestTab` becomes a proper `quests` page or screen-owned widget tree under the new feature.

- [ ] **Step 3: Keep game logic connected safely**

Do not rewrite all domain rules in this phase. The point is ownership migration, not feature reinvention.

- [ ] **Step 4: Verify**

Add focused tests on quest action controller/provider boundaries.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/quests
git commit -m "refactor: extract quests feature ownership"
```

## Task 4: Separate inventory/cofre responsibility from `home`

**Files:**
- Create: `lib/features/inventory/application/inventory_controller.dart`
- Create: `lib/features/inventory/application/inventory_state.dart`
- Create: `lib/features/inventory/presentation/widgets/chest_reward_overlay.dart`
- Move/replace:
  - `inventory_tile.dart`
  - `chest_reward_overlay.dart`

- [ ] **Step 1: Extract inventory state concerns**

This includes:

- visible inventory snapshot
- chest reward payload
- item-focused overlay behavior

- [ ] **Step 2: Move inventory presentation**

Anything whose meaning is “items/rewards/cofres” should stop living in `home`.

- [ ] **Step 3: Wire inventory overlay into shell**

`app_shell` should consume chest overlay visibility from inventory/system boundaries, not from a monolithic home page.

- [ ] **Step 4: Verify**

Add focused tests for chest reward state and presentation wiring.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/inventory
git commit -m "refactor: extract inventory reward flow"
```

## Task 5: Reduce `home` to compatibility/minimal orchestration

**Files:**
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Possibly move:
  - remaining tabs/pages
  - training widgets still living under `home`

- [ ] **Step 1: Remove ownership that now lives elsewhere**

After tasks 1-4, `home` should not remain the owner of:

- app shell
- system overlays
- quest actions
- chest reward flow

- [ ] **Step 2: Keep only what truly still belongs**

If any domain/service remains under `home`, document why it stays temporarily.

- [ ] **Step 3: Decide compatibility outcome**

Choose one:

- `HomePage` becomes thin wrapper to `AppShellPage`
- or `HomePage` is fully retired if routing is already moved

- [ ] **Step 4: Verify**

Run focused app startup/navigation verification.

- [ ] **Step 5: Commit**

```powershell
git add lib/features/home
git commit -m "refactor: reduce home to compatibility layer"
```

## Task 6: Frontend verification and architecture docs update

**Files:**
- Modify: `README.md`
- Optionally add a frontend architecture section doc under `docs/superpowers/specs/` or `docs/`

- [ ] **Step 1: Run focused verification**

Expected minimum:

- `flutter test` for new feature tests
- `flutter analyze` on touched frontend scope
- local app startup on `web-server`

- [ ] **Step 2: Document the new feature boundaries**

Update docs to reflect:

- `app_shell`
- `system`
- `quests`
- `inventory`
- remaining temporary role of `home`

- [ ] **Step 3: Final commit**

```powershell
git add README.md
git commit -m "docs: document phase 2 flutter architecture baseline"
```

---

## Execution Rules

- Do not open multiple parallel subtasks writing the same `home` files.
- Prefer one subagent per ownership slice:
  - `app_shell`
  - `system`
  - `quests`
  - `inventory`
- Review and integrate each slice before opening the next one if write scopes overlap.
- Keep `DEVELOPMENT_PLAN.md` and temporary runtime logs out of commits.

## Success Criteria

`Phase 2` is successful if:

- `app_shell` exists and is the visible top-level boundary
- `system`, `quests`, and `inventory` own their UI/logic slices clearly
- `home` is no longer the main feature bucket
- Riverpod owns more of the real frontend flow
- the app still boots and navigates cleanly
- the resulting structure is legible and professionally defensible
