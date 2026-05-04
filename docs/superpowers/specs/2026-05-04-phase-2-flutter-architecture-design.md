# Phase 2 Flutter Architecture Design

> **Goal:** Migrar el frontend a una arquitectura Flutter reconocible y escalable basada en `feature + layers + Riverpod`, desarmando el `super-feature` `home` y moviendo la logica real de UI/estado/casos de uso a features coherentes sin romper la experiencia actual.

## Why This Phase Exists

`Phase 1` resolvio la infraestructura comun:

- `Riverpod`
- logging
- manejo de errores
- bootstrap del jugador
- primer vertical real end-to-end

Eso deja al frontend en una situacion mucho mejor, pero no suficiente.

La deuda principal ahora no es tecnica transversal, sino estructural dentro de Flutter:

- `home` sigue concentrando demasiadas responsabilidades
- `HomePage` todavia compone demasiada logica de arranque, navegacion, overlays y tabs
- `HomeController` sigue siendo un agregador grande de comportamiento
- `quests`, `inventory`, `system`, `hunter` y parte de `stats` viven demasiado mezclados
- el estado del juego todavia no esta expresado como providers/casos de uso modulares

Si dejamos crecer la app asi, cada feature nueva va a entrar en conflicto con `home` aunque el proyecto ya tenga buen `core`.

## Phase Goal

`Phase 2` no busca cambiar la fantasia del producto ni rediseñar pantallas.

Busca que el frontend quede defendible ante otros tecnicos como una app Flutter organizada por verticales reales:

- `player`
- `system`
- `quests`
- `inventory`
- `shadows`
- `app shell`

Al cerrar la fase, el frontend debe seguir funcionando igual o mejor, pero con una estructura donde:

- los casos de uso sean identificables
- los providers sean explicitos
- los widgets no carguen logica de dominio
- `home` deje de ser el centro del crecimiento

## Out Of Scope

Esta fase no incluye:

- cambios profundos del backend
- nuevos endpoints
- auth / Google login
- share cards
- observabilidad externa
- rediseño completo del HUD
- migracion total de todas las features del producto

Tampoco busca rehacer la UI desde cero. La prioridad es arquitectura, no cosmética.

## Architecture Target

## Frontend Top-Level Shape

La forma objetivo del frontend pasa a ser:

```text
lib/
  core/
  features/
    app_shell/
    player/
    system/
    quests/
    inventory/
    shadows/
```

### `app_shell`

Nueva feature responsable de:

- bootstrap visible de la aplicacion
- coordinacion de navegacion principal
- frame general
- overlays de alto nivel del Sistema
- composicion de tabs

`HomePage` deja de ser la pagina totalizadora y pasa a ser reemplazada o reducida a una pieza de compatibilidad si todavia hace falta durante la migracion.

### `player`

Ya existe como primer vertical y se consolida como owner de:

- bootstrap del jugador
- snapshot base
- identidad del jugador
- progreso base persistido

### `system`

Debe concentrar:

- estado general del Sistema
- onboarding del Sistema
- level up
- cambio de clase
- reward notices globales
- reglas que pertenecen a la “capa Sistema” y no a una tab puntual

### `quests`

Debe pasar a tener ownership real de:

- misiones diarias
- quest especial semanal
- avance remoto/local de quests
- uso de `reroll`
- uso de `xp boost` cuando corresponda al flujo de misiones

### `inventory`

Debe aislar:

- cofre y recompensas
- items como `freeze`, `reroll`, `xp boost`
- lectura del inventario del jugador

### `shadows`

Ya tiene buena base propia, pero en esta fase debe dejar de depender de `home` para:

- overlays de desbloqueo
- datos visibles de la galeria
- integracion del unlock con el estado principal

## Layering Rules

Cada feature activa debe tender a esta estructura:

- `domain/`
  - entidades
  - value objects
  - contratos
  - reglas puras
- `application/`
  - casos de uso
  - controllers/notifiers/providers
  - orquestacion del flujo
- `data/`
  - api clients
  - local data sources
  - repository impl
- `presentation/`
  - pages
  - widgets
  - dialogs / overlays

No todas las features van a empezar con 100% de carpetas llenas, pero la direccion debe quedar clara.

## Riverpod Target

En `Phase 1`, Riverpod entro por `player bootstrap`.

En `Phase 2`, Riverpod debe convertirse en la forma preferida de:

- leer estado de features
- componer dependencias
- disparar casos de uso
- separar estado de UI de widgets grandes

Objetivo concreto:

- `HomeController` no debe seguir creciendo
- parte de su comportamiento debe migrar a notifiers/providers por feature
- la capa shell solo observa y compone

## Migration Target In This Phase

No conviene migrar todo el frontend en un solo corte.

Los cortes recomendados para `Phase 2` son:

### Step 1: `app_shell`

Extraer desde `home`:

- layout principal
- bootstrap visual
- navegacion inferior
- frame/backdrop global
- arbitraje de overlays de primer nivel

### Step 2: `system`

Mover:

- onboarding
- level up overlay
- class evolution overlay
- reward banner global

### Step 3: `quests` + `inventory`

Separar desde `home`:

- estado y acciones de quests
- popup de cofre
- consumo de items relacionados

### Step 4: adelgazar `home`

El resultado esperado no es “borrar home” a la fuerza, sino dejarlo reducido a:

- compatibilidad temporal
- wiring mínimo
- o incluso eliminarlo si el shell nuevo ya cubre todo

## Design Constraints

La migracion debe respetar estas reglas:

- mantener la app funcional en cada commit importante
- no romper el look & feel de Solo Leveling
- no duplicar logica entre controller viejo y providers nuevos por mucho tiempo
- evitar archivos nuevos gigantes
- preferir casos de uso chicos sobre servicios gigantes
- no introducir otro framework adicional de estado

## Testing Strategy

La fase debe aumentar cobertura del frontend alrededor de arquitectura, no solo widgets bonitos.

Minimo esperado:

- tests de providers/notifiers nuevos por feature
- tests de wiring del shell principal
- tests de overlays si cambian de ownership
- tests de migracion de estado cuando se muevan responsabilidades desde `home`

## Success Criteria

`Phase 2` se considera exitosa si:

- existe `app_shell` como frontera real del frontend
- `home` deja de ser la unidad principal de crecimiento
- `system`, `quests` e `inventory` ya tienen ownership propio claro
- Riverpod gana terreno sobre estado artesanal en UI
- los archivos mas riesgosos bajan en responsabilidad
- la app sigue arrancando y navegando con el mismo comportamiento visible
- un tecnico externo puede reconocer el patron de diseño sin tener que “inferirlo”

## Dependency On Phase 3

Si `Phase 2` sale bien:

- `Phase 3` puede modularizar backend con simetria real respecto del frontend
- `quests`, `inventory`, `shadows` y `system` del backend ya tendran un espejo natural del lado Flutter
- la integracion y observabilidad de `Phase 4` va a ser mucho mas limpia
