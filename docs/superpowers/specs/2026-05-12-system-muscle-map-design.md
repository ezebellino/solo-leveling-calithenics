# System Muscle Map Design

## Goal

Replace the current `MAPA MUSCULAR DEL DIA` block with a more premium, anime-aligned experience that supports training clarity without looking clinical or cheap.

The block should feel like part of the `System`, not like a generic anatomy widget.

## Visual Direction

- `System anime` tone, not medical illustration
- dual silhouette:
  - frontal
  - dorsal
- stylized human figure with clean holographic linework
- active zones marked by `System` energy
- same cyan/turquoise palette already used across the app
- mostly static composition
- only small pulse/reveal behavior on initial load

## UX Goals

- quickly show what body zones matter today
- preserve premium presentation
- explain the session in a way that feels useful, not decorative
- avoid long text blocks or low-value repeated roadmap content

## Block Structure

### 1. Header

- `ETAPA ACTIVA`
- short System line explaining that the active body zones are being highlighted

### 2. Visual Core

- side-by-side body silhouettes:
  - `Vista frontal`
  - `Vista dorsal`
- inactive areas stay dim
- active areas receive System energy emphasis
- no photo-real anatomy
- no imported static sketch as the main visual base

### 3. Training Summary

- `Foco principal`
- `Recuperacion sugerida`

### 4. Exercise Cards

Premium cards below the body map.

Each card shows:

- exercise name
- category
- muscles involved

These cards should feel more like collectible System panels than plain list rows.

## Mapping Rules

The same System energy color is always used.

What changes per day is:

- active front zones
- active back zones
- exercise cards
- summary text

Expected mappings:

- `empuje`
  - pecho
  - hombro
  - triceps
  - core support
- `tiron`
  - espalda
  - biceps
  - antebrazo
  - core support
- `pierna`
  - cuadriceps
  - gluteo
  - femoral
  - gemelos
- `core`
  - abdominales
  - oblicuos
  - lumbar
- `skill / handstand`
  - hombro
  - triceps
  - core
  - antebrazo / muñeca
- `full body / fuerza maxima / bloque tecnico`
  - activacion amplia

## Explicit Non-Goals

- no clinical anatomy diagram
- no generic fitness infographic style
- no passive static PNG as the final experience
- no over-animated scene

## Implementation Shape

The final implementation should keep the logic inside `features/system` and avoid pushing visual ownership back into `home`.

Expected pieces:

- body map data model
- silhouette widget(s)
- zone highlight painter/layer
- exercise card widget
- summary formatter from current workout focus

## Acceptance Criteria

- the user immediately understands which body zones are involved today
- the block looks more premium than the current schematic
- it feels visually aligned with the rest of the Solo Leveling System UI
- the user can relate today’s exercises to the highlighted muscles
