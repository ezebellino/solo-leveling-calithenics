# Shadows MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first real `Sombras` system end-to-end: unlock rules, inventory count, compact gallery, expanded full-card modal, and `System` popup for newly obtained shadows.

**Architecture:** Implement `Sombras` as a dedicated Flutter feature under `lib/features/shadows/`, while keeping temporary integration points in `home` through `PlayerState`, `PlayerSystemService`, and `HomeController`. On the backend, add a first `shadows` module under `backend/app/modules/shadows/` and expose a small API surface for reading and syncing unlocked shadows.

**Tech Stack:** Flutter, Dart, FastAPI, SQLAlchemy, PostgreSQL, widget tests, Python compile checks.

---

## File Structure

### Flutter

**Create**
- `lib/features/shadows/domain/shadow_entity.dart`
- `lib/features/shadows/domain/shadow_unlock_rule.dart`
- `lib/features/shadows/domain/shadow_catalog.dart`
- `lib/features/shadows/domain/shadow_progress_snapshot.dart`
- `lib/features/shadows/application/shadow_unlock_evaluator.dart`
- `lib/features/shadows/presentation/widgets/shadow_compact_card.dart`
- `lib/features/shadows/presentation/widgets/shadow_fullscreen_card.dart`
- `lib/features/shadows/presentation/widgets/shadow_unlock_overlay.dart`
- `lib/features/shadows/presentation/widgets/shadows_gallery_panel.dart`
- `test/features/shadows/shadow_unlock_evaluator_test.dart`
- `test/features/shadows/shadows_gallery_panel_test.dart`

**Modify**
- `lib/features/home/domain/player_state.dart`
- `lib/features/home/domain/player_system_service.dart`
- `lib/features/home/presentation/controllers/home_controller.dart`
- `lib/features/home/presentation/pages/stats_tab.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/data/home_api_client.dart`
- `lib/features/home/data/local_player_state_repository.dart`
- `pubspec.yaml`

### Backend

**Create**
- `backend/app/modules/shadows/__init__.py`
- `backend/app/modules/shadows/models.py`
- `backend/app/modules/shadows/schemas.py`
- `backend/app/modules/shadows/service.py`
- `backend/app/modules/shadows/router.py`
- `backend/tests/modules/shadows/test_shadow_service.py`

**Modify**
- `backend/app/models.py`
- `backend/app/schemas.py`
- `backend/app/services.py`
- `backend/app/main.py`
- `backend/app/database.py` (only if imports/base wiring require it)

---

### Task 1: Define the Shadows Domain Model

**Files:**
- Create: `lib/features/shadows/domain/shadow_entity.dart`
- Create: `lib/features/shadows/domain/shadow_unlock_rule.dart`
- Create: `lib/features/shadows/domain/shadow_catalog.dart`
- Create: `lib/features/shadows/domain/shadow_progress_snapshot.dart`
- Test: `test/features/shadows/shadow_unlock_evaluator_test.dart`

- [ ] **Step 1: Write the failing domain test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/shadows/application/shadow_unlock_evaluator.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_catalog.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_progress_snapshot.dart';

void main() {
  test('unlocks Igris after 7 completed main days', () {
    final evaluator = ShadowUnlockEvaluator();
    final snapshot = ShadowProgressSnapshot(
      completedMainDays: 7,
      streakDays: 7,
      totalCompletedQuests: 7,
      completedSpecialQuests: 0,
      perfectWeeks: 0,
      level: 4,
      unlockedShadowIds: const [],
    );

    final unlocked = evaluator.evaluate(
      catalog: ShadowCatalog.initialRoster,
      snapshot: snapshot,
    );

    expect(unlocked.map((item) => item.id), contains('igris'));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `.\flutterw.ps1 test test/features/shadows/shadow_unlock_evaluator_test.dart`
Expected: FAIL with missing `ShadowUnlockEvaluator`, `ShadowCatalog`, or related imports.

- [ ] **Step 3: Write the minimal domain model**

```dart
enum ShadowRarity { elite, commander, marshal }

class ShadowEntity {
  const ShadowEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.rarity,
    required this.flavorText,
    required this.unlockHint,
    required this.assetPath,
    required this.borderTheme,
  });

  final String id;
  final String name;
  final String title;
  final ShadowRarity rarity;
  final String flavorText;
  final String unlockHint;
  final String assetPath;
  final String borderTheme;
}

class ShadowProgressSnapshot {
  const ShadowProgressSnapshot({
    required this.completedMainDays,
    required this.streakDays,
    required this.totalCompletedQuests,
    required this.completedSpecialQuests,
    required this.perfectWeeks,
    required this.level,
    required this.unlockedShadowIds,
  });

  final int completedMainDays;
  final int streakDays;
  final int totalCompletedQuests;
  final int completedSpecialQuests;
  final int perfectWeeks;
  final int level;
  final List<String> unlockedShadowIds;
}
```

- [ ] **Step 4: Define the roster and unlock rules**

```dart
typedef ShadowRule = bool Function(ShadowProgressSnapshot snapshot);

class ShadowUnlockRule {
  const ShadowUnlockRule({
    required this.shadowId,
    required this.canUnlock,
  });

  final String shadowId;
  final ShadowRule canUnlock;
}

class ShadowCatalog {
  static const initialRoster = <ShadowEntity>[
    ShadowEntity(
      id: 'igris',
      name: 'Igris',
      title: 'Caballero Sombra',
      rarity: ShadowRarity.elite,
      flavorText: 'La disciplina temprana ha sido reconocida por el Sistema.',
      unlockHint: 'Completa 7 misiones principales.',
      assetPath: 'assets/shadows/Igris-Card.webp',
      borderTheme: 'crimson',
    ),
    ShadowEntity(
      id: 'tank',
      name: 'Tank',
      title: 'El Muro Inquebrantable',
      rarity: ShadowRarity.elite,
      flavorText: 'La constancia pesada levanta su propio escudo.',
      unlockHint: 'Alcanza una racha de 14 dias.',
      assetPath: 'assets/shadows/Tank-Card.webp',
      borderTheme: 'violet_gold',
    ),
    // Iron, Tusk, Beru, Bellion...
  ];

  static final rules = <ShadowUnlockRule>[
    ShadowUnlockRule(
      shadowId: 'igris',
      canUnlock: (snapshot) => snapshot.completedMainDays >= 7,
    ),
    ShadowUnlockRule(
      shadowId: 'tank',
      canUnlock: (snapshot) => snapshot.streakDays >= 14,
    ),
  ];
}
```

- [ ] **Step 5: Implement the evaluator**

```dart
import '../domain/shadow_catalog.dart';
import '../domain/shadow_entity.dart';
import '../domain/shadow_progress_snapshot.dart';

class ShadowUnlockEvaluator {
  const ShadowUnlockEvaluator();

  List<ShadowEntity> evaluate({
    required List<ShadowEntity> catalog,
    required ShadowProgressSnapshot snapshot,
  }) {
    final unlocked = <ShadowEntity>[];
    for (final shadow in catalog) {
      if (snapshot.unlockedShadowIds.contains(shadow.id)) {
        continue;
      }
      final rule = ShadowCatalog.rules.firstWhere((item) => item.shadowId == shadow.id);
      if (rule.canUnlock(snapshot)) {
        unlocked.add(shadow);
      }
    }
    return unlocked;
  }
}
```

- [ ] **Step 6: Run the domain test to verify it passes**

Run: `.\flutterw.ps1 test test/features/shadows/shadow_unlock_evaluator_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add test/features/shadows/shadow_unlock_evaluator_test.dart lib/features/shadows/domain lib/features/shadows/application/shadow_unlock_evaluator.dart
git commit -m "feat: define shadows domain model"
```

---

### Task 2: Persist Shadows in Player State and Unlock Them From Real Progress

**Files:**
- Modify: `lib/features/home/domain/player_state.dart`
- Modify: `lib/features/home/domain/player_system_service.dart`
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Test: `test/features/shadows/shadow_unlock_evaluator_test.dart`

- [ ] **Step 1: Extend the failing test for persistence-facing unlock behavior**

```dart
test('returns newly unlocked shadows when progress reaches a threshold', () {
  final service = PlayerSystemService(baseProfile: mockProfile);
  final state = service.initialState().copyWith(
    completedDays: 6,
    lastStreakCreditDate: '',
    unlockedShadowIds: const [],
  );

  final quest = state.quests.first.copyWith(progress: state.quests.first.target - 1);
  final updatedState = state.copyWith(quests: [quest, ...state.quests.skip(1)]);

  final result = service.advanceQuest(updatedState, quest);

  expect(result.state.unlockedShadowIds, contains('igris'));
  expect(result.notices.any((item) => item.contains('Igris')), isTrue);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `.\flutterw.ps1 test test/features/shadows/shadow_unlock_evaluator_test.dart`
Expected: FAIL because `PlayerState` has no `unlockedShadowIds` and the service does not evaluate shadows yet.

- [ ] **Step 3: Add shadow fields to player state**

```dart
class PlayerState {
  const PlayerState({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.inventory,
    required this.completedDays,
    required this.lastStreakCreditDate,
    this.unlockedShadowIds = const [],
    this.lastUnlockedShadowId = '',
    // existing fields...
  });

  final List<String> unlockedShadowIds;
  final String lastUnlockedShadowId;
}
```

- [ ] **Step 4: Evaluate unlocks inside the system service**

```dart
final snapshot = ShadowProgressSnapshot(
  completedMainDays: completedDays,
  streakDays: profile.streakDays,
  totalCompletedQuests: _countCompletedQuests(updatedQuests, state.completedDays),
  completedSpecialQuests: _countCompletedSpecialQuests(state),
  perfectWeeks: _estimatePerfectWeeks(state),
  level: profile.level,
  unlockedShadowIds: state.unlockedShadowIds,
);

final unlockedShadows = const ShadowUnlockEvaluator().evaluate(
  catalog: ShadowCatalog.initialRoster,
  snapshot: snapshot,
);

final unlockedIds = [...state.unlockedShadowIds, ...unlockedShadows.map((item) => item.id)];
```

- [ ] **Step 5: Surface popup-ready notices from the service**

```dart
return PlayerSystemUpdate(
  state: state.copyWith(
    profile: profile,
    quests: updatedQuests,
    inventory: inventory,
    completedDays: completedDays,
    xpBoostArmed: xpBoostArmed,
    lastStreakCreditDate: lastStreakCreditDate,
    unlockedShadowIds: unlockedIds,
    lastUnlockedShadowId: unlockedShadows.isEmpty ? state.lastUnlockedShadowId : unlockedShadows.last.id,
  ),
  notices: [
    ...notices,
    ...unlockedShadows.map((item) => 'Nueva sombra obtenida: ${item.name}'),
  ],
);
```

- [ ] **Step 6: Track pending unlocked shadow in the controller**

```dart
String? _pendingUnlockedShadowId;
String? get pendingUnlockedShadowId => _pendingUnlockedShadowId;

Future<void> _applyUpdate(PlayerSystemUpdate update) async {
  await _persist(update.state);
  if (update.state.lastUnlockedShadowId.isNotEmpty &&
      update.state.lastUnlockedShadowId != _pendingUnlockedShadowId) {
    _pendingUnlockedShadowId = update.state.lastUnlockedShadowId;
  }
  notifyListeners();
}

void clearUnlockedShadowNotice() {
  _pendingUnlockedShadowId = null;
  notifyListeners();
}
```

- [ ] **Step 7: Run the test to verify it passes**

Run: `.\flutterw.ps1 test test/features/shadows/shadow_unlock_evaluator_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/home/domain/player_state.dart lib/features/home/domain/player_system_service.dart lib/features/home/presentation/controllers/home_controller.dart test/features/shadows/shadow_unlock_evaluator_test.dart
git commit -m "feat: unlock shadows from player progress"
```

---

### Task 3: Build the Compact Gallery and Full-Card Modal

**Files:**
- Create: `lib/features/shadows/presentation/widgets/shadow_compact_card.dart`
- Create: `lib/features/shadows/presentation/widgets/shadow_fullscreen_card.dart`
- Create: `lib/features/shadows/presentation/widgets/shadows_gallery_panel.dart`
- Modify: `lib/features/home/presentation/pages/stats_tab.dart`
- Test: `test/features/shadows/shadows_gallery_panel_test.dart`

- [ ] **Step 1: Write the failing widget test**

```dart
testWidgets('opens full shadow card when a compact card is tapped', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShadowsGalleryPanel(
          unlockedShadowIds: const ['igris'],
          lastUnlockedShadowId: 'igris',
        ),
      ),
    ),
  );

  expect(find.text('Igris'), findsOneWidget);
  await tester.tap(find.text('Igris'));
  await tester.pumpAndSettle();

  expect(find.text('Caballero Sombra'), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test to verify it fails**

Run: `.\flutterw.ps1 test test/features/shadows/shadows_gallery_panel_test.dart`
Expected: FAIL because `ShadowsGalleryPanel` does not exist yet.

- [ ] **Step 3: Implement the compact card**

```dart
class ShadowCompactCard extends StatelessWidget {
  const ShadowCompactCard({
    required this.shadow,
    required this.isUnlocked,
    required this.onTap,
    super.key,
  });

  final ShadowEntity shadow;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: DecorationImage(
              image: AssetImage(shadow.assetPath),
              fit: BoxFit.cover,
              colorFilter: isUnlocked
                  ? null
                  : const ColorFilter.mode(Colors.black54, BlendMode.darken),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(shadow.name),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Implement the expanded full-card modal**

```dart
class ShadowFullscreenCard extends StatelessWidget {
  const ShadowFullscreenCard({
    required this.shadow,
    super.key,
  });

  final ShadowEntity shadow;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.asset(shadow.assetPath, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Implement the gallery panel**

```dart
class ShadowsGalleryPanel extends StatelessWidget {
  const ShadowsGalleryPanel({
    required this.unlockedShadowIds,
    required this.lastUnlockedShadowId,
    super.key,
  });

  final List<String> unlockedShadowIds;
  final String lastUnlockedShadowId;

  @override
  Widget build(BuildContext context) {
    final shadows = ShadowCatalog.initialRoster;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${unlockedShadowIds.length} / ${shadows.length} Sombras obtenidas'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shadows.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final shadow = shadows[index];
            return ShadowCompactCard(
              shadow: shadow,
              isUnlocked: unlockedShadowIds.contains(shadow.id),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => ShadowFullscreenCard(shadow: shadow),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: Mount the gallery in the current UI**

```dart
ShadowsGalleryPanel(
  unlockedShadowIds: profileState.unlockedShadowIds,
  lastUnlockedShadowId: profileState.lastUnlockedShadowId,
)
```

Place it inside `StatsTab` below the stats summary panel so the current `Sombras` area stops being decorative and becomes interactive.

- [ ] **Step 7: Run the widget test to verify it passes**

Run: `.\flutterw.ps1 test test/features/shadows/shadows_gallery_panel_test.dart`
Expected: PASS

- [ ] **Step 8: Commit**

```bash
git add lib/features/shadows/presentation/widgets lib/features/home/presentation/pages/stats_tab.dart test/features/shadows/shadows_gallery_panel_test.dart
git commit -m "feat: add shadows gallery and full-card modal"
```

---

### Task 4: Add the System Popup for Newly Obtained Shadows

**Files:**
- Create: `lib/features/shadows/presentation/widgets/shadow_unlock_overlay.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Test: `test/features/shadows/shadows_gallery_panel_test.dart`

- [ ] **Step 1: Extend the failing widget test with popup behavior**

```dart
testWidgets('shows the unlock overlay when a new shadow is pending', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ShadowUnlockOverlay(
        shadow: ShadowCatalog.initialRoster.first,
        onDismissed: () {},
      ),
    ),
  );

  expect(find.text('Nueva sombra obtenida'), findsOneWidget);
  expect(find.text('Igris'), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test to verify it fails**

Run: `.\flutterw.ps1 test test/features/shadows/shadows_gallery_panel_test.dart`
Expected: FAIL because `ShadowUnlockOverlay` does not exist.

- [ ] **Step 3: Implement the overlay widget**

```dart
class ShadowUnlockOverlay extends StatelessWidget {
  const ShadowUnlockOverlay({
    required this.shadow,
    required this.onDismissed,
    super.key,
  });

  final ShadowEntity shadow;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: HolographicPanel(
          glowColor: const Color(0xFF71E4FF),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nueva sombra obtenida'),
              const SizedBox(height: 12),
              Text(shadow.name),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: Image.asset(shadow.assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text(shadow.flavorText),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onDismissed,
                child: const Text('Añadida al inventario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Render the overlay from HomePage**

```dart
if (controller.pendingUnlockedShadowId case final shadowId?)
  Positioned.fill(
    child: ShadowUnlockOverlay(
      shadow: ShadowCatalog.byId(shadowId),
      onDismissed: controller.clearUnlockedShadowNotice,
    ),
  ),
```

- [ ] **Step 5: Run the widget test to verify it passes**

Run: `.\flutterw.ps1 test test/features/shadows/shadows_gallery_panel_test.dart`
Expected: PASS

- [ ] **Step 6: Verify the app still analyzes cleanly**

Run: `.\flutterw.ps1 analyze`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/shadows/presentation/widgets/shadow_unlock_overlay.dart lib/features/home/presentation/pages/home_page.dart lib/features/home/presentation/controllers/home_controller.dart test/features/shadows/shadows_gallery_panel_test.dart
git commit -m "feat: add system popup for unlocked shadows"
```

---

### Task 5: Back the Shadows Inventory With a Real API Module

**Files:**
- Create: `backend/app/modules/shadows/models.py`
- Create: `backend/app/modules/shadows/schemas.py`
- Create: `backend/app/modules/shadows/service.py`
- Create: `backend/app/modules/shadows/router.py`
- Modify: `backend/app/models.py`
- Modify: `backend/app/main.py`
- Test: `backend/tests/modules/shadows/test_shadow_service.py`

- [ ] **Step 1: Write the failing backend test**

```python
from app.modules.shadows.service import evaluate_shadow_unlocks


def test_unlocks_igris_after_seven_completed_main_days():
    unlocked = evaluate_shadow_unlocks(
        unlocked_shadow_ids=[],
        completed_main_days=7,
        streak_days=7,
        total_completed_quests=7,
        completed_special_quests=0,
        perfect_weeks=0,
        level=4,
    )

    assert "igris" in unlocked
```

- [ ] **Step 2: Run the backend test to verify it fails**

Run: `py -3 -m pytest backend/tests/modules/shadows/test_shadow_service.py -v`
Expected: FAIL because the module and function do not exist.

- [ ] **Step 3: Add the backend shadow inventory model**

```python
class PlayerShadow(Base):
    __tablename__ = "player_shadows"

    id = Column(Integer, primary_key=True)
    player_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    shadow_id = Column(String(64), nullable=False)
    unlocked_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
```

- [ ] **Step 4: Implement the unlock evaluator and inventory service**

```python
SHADOW_RULES = {
    "igris": lambda s: s["completed_main_days"] >= 7,
    "tank": lambda s: s["streak_days"] >= 14,
    "iron": lambda s: s["total_completed_quests"] >= 30,
    "tusk": lambda s: s["completed_special_quests"] >= 3,
    "beru": lambda s: s["perfect_weeks"] >= 2,
    "bellion": lambda s: s["level"] >= 50,
}


def evaluate_shadow_unlocks(**snapshot: int | list[str]) -> list[str]:
    unlocked = []
    existing = set(snapshot["unlocked_shadow_ids"])
    for shadow_id, rule in SHADOW_RULES.items():
        if shadow_id in existing:
            continue
        if rule(snapshot):
          unlocked.append(shadow_id)
    return unlocked
```

- [ ] **Step 5: Expose a read endpoint**

```python
router = APIRouter(prefix=f"{settings.api_prefix}/shadows", tags=["shadows"])


@router.get("", response_model=ShadowInventoryResponse)
def get_shadows(db: Session = Depends(get_db)) -> ShadowInventoryResponse:
    return build_shadow_inventory(db)
```

- [ ] **Step 6: Register the router**

```python
from app.modules.shadows.router import router as shadows_router

app.include_router(shadows_router)
```

- [ ] **Step 7: Run backend verification**

Run: `py -3 -m pytest backend/tests/modules/shadows/test_shadow_service.py -v`
Expected: PASS

Run: `py -3 -m compileall backend\\app`
Expected: compile completes without syntax errors

- [ ] **Step 8: Commit**

```bash
git add backend/app/models.py backend/app/main.py backend/app/modules/shadows backend/tests/modules/shadows/test_shadow_service.py
git commit -m "feat: add backend shadows inventory module"
```

---

### Task 6: Sync Flutter With the Shadows API and Finalize the MVP

**Files:**
- Modify: `lib/features/home/data/home_api_client.dart`
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Modify: `lib/features/home/data/local_player_state_repository.dart`
- Test: `test/features/shadows/shadows_gallery_panel_test.dart`

- [ ] **Step 1: Extend the failing test with synchronized inventory state**

```dart
testWidgets('shows unlocked count from synchronized player state', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShadowsGalleryPanel(
          unlockedShadowIds: const ['igris', 'tank'],
          lastUnlockedShadowId: 'tank',
        ),
      ),
    ),
  );

  expect(find.text('2 / 6 Sombras obtenidas'), findsOneWidget);
});
```

- [ ] **Step 2: Run the widget test to verify current integration behavior**

Run: `.\flutterw.ps1 test test/features/shadows/shadows_gallery_panel_test.dart`
Expected: PASS for local rendering, but API sync code still missing the shadow payload.

- [ ] **Step 3: Extend the API client response model**

```dart
class HomeSnapshot {
  const HomeSnapshot({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.inventory,
    required this.completedDays,
    required this.unlockedShadowIds,
    required this.lastUnlockedShadowId,
  });

  final List<String> unlockedShadowIds;
  final String lastUnlockedShadowId;
}
```

- [ ] **Step 4: Merge remote shadows into local player state**

```dart
return fallback.copyWith(
  profile: mergedProfile,
  selectedStageIndex: snapshot.selectedStageIndex,
  quests: snapshot.quests,
  inventory: snapshot.inventory,
  completedDays: snapshot.completedDays,
  unlockedShadowIds: snapshot.unlockedShadowIds,
  lastUnlockedShadowId: snapshot.lastUnlockedShadowId,
);
```

- [ ] **Step 5: Persist and restore the new fields locally**

```dart
'unlockedShadowIds': state.unlockedShadowIds,
'lastUnlockedShadowId': state.lastUnlockedShadowId,
```

```dart
unlockedShadowIds: List<String>.from(json['unlockedShadowIds'] ?? const []),
lastUnlockedShadowId: json['lastUnlockedShadowId'] as String? ?? '',
```

- [ ] **Step 6: Run full Flutter verification**

Run: `.\flutterw.ps1 test`
Expected: PASS

Run: `.\flutterw.ps1 analyze`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/features/home/data/home_api_client.dart lib/features/home/presentation/controllers/home_controller.dart lib/features/home/data/local_player_state_repository.dart lib/features/home/domain/player_state.dart test/features/shadows/shadows_gallery_panel_test.dart
git commit -m "feat: sync shadows inventory across local and remote state"
```

---

## Self-Review

### Spec coverage

- Roster inicial: covered in Task 1
- Reglas de desbloqueo: covered in Tasks 1, 2, and 5
- Bloque de Sombras con valor real: covered in Task 3
- Carta expandida: covered in Task 3
- Popup ceremonial: covered in Task 4
- Persistencia y sync: covered in Tasks 2, 5, and 6
- Arquitectura modular inicial: covered in Tasks 1 and 5

No gaps found for `Sombras MVP`.

### Placeholder scan

- No `TODO`, `TBD`, or “implement later” placeholders remain in task steps.
- Each code-changing step includes concrete file paths and example code.

### Type consistency

- `unlockedShadowIds` and `lastUnlockedShadowId` are used consistently across state, controller, API, and UI.
- `ShadowCatalog.initialRoster` is the shared source for gallery and evaluator.
- `ShadowUnlockEvaluator` is the single Dart evaluator; backend mirrors it with `evaluate_shadow_unlocks`.

---

Plan complete and saved to `docs/superpowers/plans/2026-05-03-shadows-mvp-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
