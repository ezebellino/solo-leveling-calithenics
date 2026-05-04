# System Evolution Popups Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar el `LevelUpOverlay` simple y el aviso textual de cambio de clase por popups ceremoniales del Sistema, con cierre manual y conexion al flujo real del controller.

**Architecture:** La implementacion separa los nuevos overlays ceremoniales en widgets propios, mueve el estado transitorio de `level up` y `class change` al controller con colas/manual dismiss, y conecta todo en `HomePage` sin volver a cargarle logica de dominio. Se preserva la legibilidad del HUD y se mantiene compatibilidad con `Sombras` y `Cofres`.

**Tech Stack:** Flutter, widgets stateful/stateless existentes del proyecto, `HomeController`, `PlayerSystemService`, `flutter_test`

---

### Task 1: Modelar los eventos ceremoniales en el flujo de estado

**Files:**
- Modify: `lib/features/home/domain/player_system_service.dart`
- Modify: `lib/features/home/presentation/controllers/home_controller.dart`
- Modify: `test/features/shadows/shadow_unlock_evaluator_test.dart`

- [ ] **Step 1: Agregar estructura de cambio de clase en dominio**

Agregar un value object simple en `player_system_service.dart`:

```dart
class ClassEvolutionNotice {
  const ClassEvolutionNotice({
    required this.previousClass,
    required this.nextClass,
  });

  final String previousClass;
  final String nextClass;
}
```

Y actualizar `PlayerSystemUpdate`:

```dart
class PlayerSystemUpdate {
  const PlayerSystemUpdate({
    required this.state,
    this.levelUp,
    this.classEvolution,
    this.notices = const [],
  });

  final PlayerState state;
  final int? levelUp;
  final ClassEvolutionNotice? classEvolution;
  final List<String> notices;
}
```

- [ ] **Step 2: Emitir el cambio de clase correcto desde el servicio**

Reemplazar el string plano por el objeto en `advanceQuest` y `advanceSpecialQuest`:

```dart
classEvolution: profile.title != previousClass
    ? ClassEvolutionNotice(
        previousClass: previousClass,
        nextClass: profile.title,
      )
    : null,
```

- [ ] **Step 3: Pasar el controller a overlays manuales**

En `home_controller.dart`, reemplazar el `Timer` de `levelUpNotice` por estado persistente en memoria:

```dart
int? _pendingLevelUp;
ClassEvolutionNotice? _pendingClassEvolution;

int? get pendingLevelUp => _pendingLevelUp;
ClassEvolutionNotice? get pendingClassEvolution => _pendingClassEvolution;
```

Y en `_applyUpdate`:

```dart
if (update.levelUp != null) {
  _pendingLevelUp = update.levelUp;
}
if (update.classEvolution != null) {
  _pendingClassEvolution = update.classEvolution;
}
notifyListeners();
```

- [ ] **Step 4: Agregar clears manuales**

En `home_controller.dart`:

```dart
void clearLevelUpNotice() {
  if (_pendingLevelUp == null) return;
  _pendingLevelUp = null;
  notifyListeners();
}

void clearClassEvolutionNotice() {
  if (_pendingClassEvolution == null) return;
  _pendingClassEvolution = null;
  notifyListeners();
}
```

Y actualizar `resetProgress()` para limpiar ambos:

```dart
_pendingLevelUp = null;
_pendingClassEvolution = null;
```

- [ ] **Step 5: Actualizar regresiones del controller**

Agregar/asserts en `test/features/shadows/shadow_unlock_evaluator_test.dart` para verificar que el controller ya no depende de auto-dismiss:

```dart
expect(controller.pendingLevelUp, isNotNull);
controller.clearLevelUpNotice();
expect(controller.pendingLevelUp, isNull);
```

Y un caso de cambio de clase:

```dart
expect(controller.pendingClassEvolution?.previousClass, 'Humano novato');
expect(controller.pendingClassEvolution?.nextClass, 'Despierto');
```

- [ ] **Step 6: Run tests de regresion**

Run:

```powershell
.\flutterw.ps1 test test\features\shadows\shadow_unlock_evaluator_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 7: Commit**

```powershell
git add lib/features/home/domain/player_system_service.dart lib/features/home/presentation/controllers/home_controller.dart test/features/shadows/shadow_unlock_evaluator_test.dart
git commit -m "feat: queue system evolution notices in controller"
```

### Task 2: Rediseñar el popup ceremonial de Level Up

**Files:**
- Modify: `lib/features/home/presentation/widgets/level_up_overlay.dart`
- Create or Modify Test: `test/features/home/level_up_overlay_test.dart`

- [ ] **Step 1: Escribir test de render ceremonial**

Crear `test/features/home/level_up_overlay_test.dart` con assertions de:

```dart
expect(find.text('Subiste de nivel'), findsOneWidget);
expect(find.text('Lv. 8'), findsOneWidget);
expect(find.text('El Sistema reconoce tu crecimiento.'), findsOneWidget);
expect(find.text('CONTINUAR'), findsOneWidget);
```

Usar widget:

```dart
LevelUpOverlay(
  level: 8,
  primary: palette.primary,
  secondary: palette.secondary,
  onDismiss: () {},
)
```

- [ ] **Step 2: Correr el test para verlo fallar**

Run:

```powershell
.\flutterw.ps1 test test\features\home\level_up_overlay_test.dart
```

Expected: FAIL porque el widget actual no tiene linea ritual ni CTA.

- [ ] **Step 3: Implementar la nueva ventana central**

Rediseñar `level_up_overlay.dart` para que incluya:

```dart
final VoidCallback? onDismiss;
```

Y estructura visual:

```dart
HolographicPanel(
  ...
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('NOTIFICACION'),
      Text('Subiste de nivel'),
      Text('Lv. $level'),
      Text('El Sistema reconoce tu crecimiento.'),
      FilledButton(
        onPressed: onDismiss,
        child: const Text('CONTINUAR'),
      ),
    ],
  ),
)
```

Agregar tratamiento visual mas ritual:

- glow mas suave;
- barrido de luz;
- humo de fondo contenido;
- jerarquia tipografica mas fuerte.

- [ ] **Step 4: Correr test del overlay**

Run:

```powershell
.\flutterw.ps1 test test\features\home\level_up_overlay_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```powershell
git add lib/features/home/presentation/widgets/level_up_overlay.dart test/features/home/level_up_overlay_test.dart
git commit -m "feat: redesign ceremonial level up overlay"
```

### Task 3: Crear popup ceremonial de Cambio de clase

**Files:**
- Create: `lib/features/home/presentation/widgets/class_evolution_overlay.dart`
- Create Test: `test/features/home/class_evolution_overlay_test.dart`

- [ ] **Step 1: Escribir test del popup de evolucion**

Crear `test/features/home/class_evolution_overlay_test.dart` con expectations:

```dart
expect(find.text('Asignacion de clase'), findsOneWidget);
expect(find.text('Humano novato'), findsOneWidget);
expect(find.text('Despierto'), findsOneWidget);
expect(find.text('CONTINUAR'), findsOneWidget);
```

Y validar presencia del glifo con:

```dart
expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
```

- [ ] **Step 2: Correr test para verlo fallar**

Run:

```powershell
.\flutterw.ps1 test test\features\home\class_evolution_overlay_test.dart
```

Expected: FAIL porque el archivo/widget aun no existe.

- [ ] **Step 3: Implementar el overlay ceremonial**

Crear `class_evolution_overlay.dart` con API:

```dart
class ClassEvolutionOverlay extends StatefulWidget {
  const ClassEvolutionOverlay({
    required this.previousClass,
    required this.nextClass,
    required this.palette,
    this.onDismiss,
    super.key,
  });
```

Contenido minimo:

```dart
Text('Asignacion de clase')
Text(previousClass)
Icon(Icons.auto_awesome_rounded)
Text(nextClass)
FilledButton(
  onPressed: onDismiss,
  child: const Text('CONTINUAR'),
)
```

Agregar animacion interna:

- aparicion de clase antigua;
- glow del glifo central;
- nueva clase con mas peso visual;
- sin auto-dismiss.

- [ ] **Step 4: Correr test del overlay**

Run:

```powershell
.\flutterw.ps1 test test\features\home\class_evolution_overlay_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: Commit**

```powershell
git add lib/features/home/presentation/widgets/class_evolution_overlay.dart test/features/home/class_evolution_overlay_test.dart
git commit -m "feat: add ceremonial class evolution overlay"
```

### Task 4: Integrar overlays ceremoniales en HomePage con prioridad correcta

**Files:**
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `test/features/home/chest_reward_overlay_test.dart` (only if needed)

- [ ] **Step 1: Importar y conectar nuevos getters**

En `home_page.dart`, leer:

```dart
final pendingLevelUp = _controller.pendingLevelUp;
final pendingClassEvolution = _controller.pendingClassEvolution;
```

- [ ] **Step 2: Reemplazar la UI vieja de level up**

Cambiar el bloque actual:

```dart
LevelUpOverlay(
  level: pendingLevelUp!,
  primary: ...,
  secondary: ...,
  onDismiss: _controller.clearLevelUpNotice,
)
```

Y quitar `IgnorePointer`, porque ahora necesita boton.

- [ ] **Step 3: Mostrar el popup ceremonial de clase**

Agregar bloque:

```dart
if (pendingClassEvolution != null && _playerAccepted && _jobChanged)
  Positioned.fill(
    child: Center(
      child: ClassEvolutionOverlay(
        previousClass: pendingClassEvolution.previousClass,
        nextClass: pendingClassEvolution.nextClass,
        palette: _paletteForIndex(selectedIndex),
        onDismiss: _controller.clearClassEvolutionNotice,
      ),
    ),
  ),
```

- [ ] **Step 4: Definir prioridad de overlays**

Orden recomendado de prioridad visual en `HomePage`:

1. onboarding / aceptacion del sistema
2. `ClassEvolutionOverlay`
3. `ShadowUnlockOverlay`
4. `ChestRewardOverlay`
5. `LevelUpOverlay`
6. `RewardNoticeBanner`

Asegurar condiciones para que `RewardNoticeBanner` no se muestre si hay cualquiera de los overlays ceremoniales activos.

- [ ] **Step 5: Run analyze**

Run:

```powershell
.\flutterw.ps1 analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Run focused widget tests**

Run:

```powershell
.\flutterw.ps1 test test\features\home\level_up_overlay_test.dart
.\flutterw.ps1 test test\features\home\class_evolution_overlay_test.dart
.\flutterw.ps1 test test\features\shadows\shadow_unlock_evaluator_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 7: Commit**

```powershell
git add lib/features/home/presentation/pages/home_page.dart
git commit -m "feat: integrate ceremonial system evolution popups"
```

### Task 5: Verificacion visual en web server y cierre

**Files:**
- Modify if needed: `lib/features/home/presentation/widgets/level_up_overlay.dart`
- Modify if needed: `lib/features/home/presentation/widgets/class_evolution_overlay.dart`

- [ ] **Step 1: Levantar app en web server**

Run:

```powershell
.\flutterw.ps1 run -d web-server --web-port 7359 --web-hostname 127.0.0.1
```

Expected:

```text
lib\main.dart is being served at http://127.0.0.1:7359
```

- [ ] **Step 2: Revisar visualmente**

Validar:

- la ventana central ocupa bien el foco;
- el fondo no compite;
- `CONTINUAR` se ve claro;
- la clase nueva tiene mas peso que la anterior;
- `Lv. X` tiene jerarquia ritual y no se ve arcade.

- [ ] **Step 3: Ajustar si hace falta**

Hacer solo ajustes menores de spacing, glow y copy si la revision visual lo pide.

- [ ] **Step 4: Commit final del bloque**

```powershell
git add lib/features/home/presentation/widgets/level_up_overlay.dart lib/features/home/presentation/widgets/class_evolution_overlay.dart lib/features/home/presentation/pages/home_page.dart test/features/home/level_up_overlay_test.dart test/features/home/class_evolution_overlay_test.dart
git commit -m "feat: complete system evolution popup experience"
```
