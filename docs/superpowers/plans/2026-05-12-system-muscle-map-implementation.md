# System Muscle Map Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `MAPA MUSCULAR DEL DIA` as a premium `System anime` block with dual silhouettes, System-energy highlights, and exercise cards that explain the muscles worked today.

**Architecture:** Keep all ownership inside `features/system`. Split the block into focused units: mapping data, silhouette rendering, exercise-card rendering, and `SystemTab` composition. Preserve the current workout-to-summary derivation path, but replace the low-quality body schematic with a stylized, System-aligned visual model.

**Tech Stack:** Flutter, CustomPainter, existing `HolographicPanel`/`SectionPalette` system widgets, Flutter widget tests, `flutter analyze`, `flutter test`

---

### Task 1: Extract muscle map view-models

**Files:**
- Create: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_muscle_map_models.dart`
- Modify: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart`
- Test: `C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_map_models_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_map_models.dart';

void main() {
  test('maps push workout to front emphasis and exercise cards', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Empuje + hombro',
      stageTitle: 'Beginner',
    );

    expect(model.primaryFocus, 'Pecho, hombro y triceps');
    expect(model.highlightZonesFront, isNotEmpty);
    expect(model.exerciseCards.first.category, 'Empuje');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_map_models_test.dart`
Expected: FAIL because `SystemMuscleMapModel` does not exist yet

- [ ] **Step 3: Write minimal implementation**

```dart
enum SystemMuscleZone {
  chest,
  shoulders,
  triceps,
  back,
  biceps,
  forearms,
  core,
  obliques,
  lowerBack,
  quadriceps,
  glutes,
  hamstrings,
  calves,
}

class SystemExerciseCardModel {
  const SystemExerciseCardModel({
    required this.name,
    required this.category,
    required this.muscles,
  });

  final String name;
  final String category;
  final List<String> muscles;
}

class SystemMuscleMapModel {
  const SystemMuscleMapModel({
    required this.primaryFocus,
    required this.recoveryHint,
    required this.highlightZonesFront,
    required this.highlightZonesBack,
    required this.exerciseCards,
  });

  final String primaryFocus;
  final String recoveryHint;
  final List<SystemMuscleZone> highlightZonesFront;
  final List<SystemMuscleZone> highlightZonesBack;
  final List<SystemExerciseCardModel> exerciseCards;

  factory SystemMuscleMapModel.fromWorkoutFocus({
    required String focus,
    required String stageTitle,
  }) {
    final normalized = focus.toLowerCase();
    if (normalized.contains('empuje')) {
      return const SystemMuscleMapModel(
        primaryFocus: 'Pecho, hombro y triceps',
        recoveryHint: 'Movilidad de hombro y pectoral',
        highlightZonesFront: [
          SystemMuscleZone.chest,
          SystemMuscleZone.shoulders,
          SystemMuscleZone.triceps,
          SystemMuscleZone.core,
        ],
        highlightZonesBack: [
          SystemMuscleZone.shoulders,
          SystemMuscleZone.triceps,
        ],
        exerciseCards: [
          SystemExerciseCardModel(
            name: 'Flexiones',
            category: 'Empuje',
            muscles: ['Pecho', 'Hombro', 'Triceps'],
          ),
          SystemExerciseCardModel(
            name: 'Pike push-ups',
            category: 'Empuje',
            muscles: ['Hombro', 'Triceps', 'Core'],
          ),
        ],
      );
    }
    return SystemMuscleMapModel(
      primaryFocus: 'Activacion general',
      recoveryHint: 'Movilidad y chequeo tecnico',
      highlightZonesFront: const [SystemMuscleZone.core],
      highlightZonesBack: const [SystemMuscleZone.lowerBack],
      exerciseCards: const [
        SystemExerciseCardModel(
          name: 'Activacion',
          category: 'General',
          muscles: ['Core'],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_map_models_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_muscle_map_models.dart C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_map_models_test.dart C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart
git commit -m "feat: extract system muscle map models"
```

### Task 2: Build premium dual-silhouette renderer

**Files:**
- Create: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_muscle_silhouette.dart`
- Modify: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart`
- Test: `C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_silhouette_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_map_models.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_silhouette.dart';

void main() {
  testWidgets('renders front and back silhouettes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SystemMuscleSilhouettePanel(
            palette: SectionPalette(
              primary: Color(0xFF79E7FF),
              secondary: Color(0xFF25F3B4),
              highlight: Color(0xFFF2FFFF),
            ),
            frontZones: [SystemMuscleZone.chest],
            backZones: [SystemMuscleZone.back],
          ),
        ),
      ),
    );

    expect(find.text('Vista frontal'), findsOneWidget);
    expect(find.text('Vista dorsal'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_silhouette_test.dart`
Expected: FAIL because `SystemMuscleSilhouettePanel` does not exist yet

- [ ] **Step 3: Write minimal implementation**

```dart
class SystemMuscleSilhouettePanel extends StatelessWidget {
  const SystemMuscleSilhouettePanel({
    required this.palette,
    required this.frontZones,
    required this.backZones,
    super.key,
  });

  final SectionPalette palette;
  final List<SystemMuscleZone> frontZones;
  final List<SystemMuscleZone> backZones;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SingleSilhouette(title: 'Vista frontal', zones: frontZones, palette: palette, isFront: true)),
        const SizedBox(width: 18),
        Expanded(child: _SingleSilhouette(title: 'Vista dorsal', zones: backZones, palette: palette, isFront: false)),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_silhouette_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_muscle_silhouette.dart C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_muscle_silhouette_test.dart C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart
git commit -m "feat: add premium system muscle silhouettes"
```

### Task 3: Add premium exercise cards and integrate into SystemTab

**Files:**
- Create: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_exercise_focus_card.dart`
- Modify: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart`
- Modify: `C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
expect(find.text('Flexiones'), findsOneWidget);
expect(find.text('Empuje'), findsOneWidget);
expect(find.textContaining('Pecho'), findsOneWidget);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart`
Expected: FAIL because the exercise cards are not rendered yet

- [ ] **Step 3: Write minimal implementation**

```dart
class SystemExerciseFocusCard extends StatelessWidget {
  const SystemExerciseFocusCard({
    required this.exercise,
    required this.palette,
    super.key,
  });

  final SystemExerciseCardModel exercise;
  final SectionPalette palette;

  @override
  Widget build(BuildContext context) {
    return HolographicPanel(
      glowColor: palette.secondary,
      padding: const EdgeInsets.all(16),
      showCorners: false,
      decorate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.category.toUpperCase()),
          const SizedBox(height: 8),
          Text(exercise.name),
          const SizedBox(height: 8),
          Text(exercise.muscles.join(' · ')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\widgets\system_exercise_focus_card.dart C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart
git commit -m "feat: add exercise focus cards to system muscle map"
```

### Task 4: Remove discarded visual path and verify full block

**Files:**
- Modify: `C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart`
- Modify: `C:\ProjectsZeqe\Solo_Leveling\pubspec.yaml`
- Test: `C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart`

- [ ] **Step 1: Tighten the final test expectations**

```dart
expect(find.text('Vista frontal'), findsOneWidget);
expect(find.text('Vista dorsal'), findsOneWidget);
expect(find.textContaining('Foco principal:'), findsOneWidget);
expect(find.textContaining('Recuperacion sugerida:'), findsOneWidget);
expect(find.text('Boceto muscular del protocolo'), findsNothing);
```

- [ ] **Step 2: Run the focused tests**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart C:\ProjectsZeqe\Solo_Leveling\test\features\shadows\shadow_unlock_evaluator_test.dart`
Expected: PASS

- [ ] **Step 3: Remove the unused asset wiring from the block**

```yaml
flutter:
  assets:
    - assets/shadows/
```

This step only removes `assets/muscule/` from `pubspec.yaml` if it is no longer used anywhere in the app after the feature swap.

- [ ] **Step 4: Run final verification**

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 analyze C:\ProjectsZeqe\Solo_Leveling\lib\features\system C:\ProjectsZeqe\Solo_Leveling\test\features\system`
Expected: `No issues found!`

Run: `C:\ProjectsZeqe\Solo_Leveling\flutterw.ps1 test C:\ProjectsZeqe\Solo_Leveling\test\features\system`
Expected: all tests PASS

- [ ] **Step 5: Commit**

```bash
git add C:\ProjectsZeqe\Solo_Leveling\lib\features\system\presentation\pages\system_tab.dart C:\ProjectsZeqe\Solo_Leveling\pubspec.yaml C:\ProjectsZeqe\Solo_Leveling\test\features\system\system_tab_test.dart
git commit -m "refactor: finalize premium system muscle map"
```
