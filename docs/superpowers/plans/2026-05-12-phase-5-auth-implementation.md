# Phase 5 Auth Implementation Plan

> **Goal:** Implementar autenticacion real con `Google Sign-In` y `email magic link`, dejando una sesion durable y una integracion limpia con el bootstrap del jugador.

## Execution Mode

Recommended: `subagent-driven`

Razon:

- backend y frontend tienen ownership distintos
- hay cortes claros por feature
- conviene validar cada contrato antes de seguir

## Task 1 - Backend Auth Foundation

### Objective

Crear el modulo `auth` en backend con modelos, errores, servicios base y migraciones.

### Scope

- `backend/app/modules/auth/`
  - `api/`
  - `application/`
  - `domain/`
  - `infrastructure/`
- entidades iniciales:
  - `AuthUser`
  - `AuthIdentity`
  - `AuthSession` si se persiste
- errores de dominio auth
- migracion `Alembic`
- registro del modulo en `main.py`

### Verification

- `pytest` de modulo `auth`
- `compileall`
- smoke test de import/composition

## Task 2 - Session Contracts And Protected Endpoints

### Objective

Dejar contratos reales de sesion y middleware/dependency de autorizacion.

### Scope

- endpoints:
  - `POST /api/v1/auth/google`
  - `POST /api/v1/auth/magic-link/request`
  - `POST /api/v1/auth/magic-link/verify`
  - `GET /api/v1/auth/session`
  - `POST /api/v1/auth/logout`
- emision y validacion de token
- dependency `current_user`
- proteccion gradual de endpoints relevantes

### Verification

- tests de sesion
- tests de unauthorized/forbidden
- tests de logout / expired session

## Task 3 - Flutter Auth Feature

### Objective

Introducir feature `auth` real en Flutter con estado de sesion y proveedores.

### Scope

- `lib/features/auth/`
  - `application/`
  - `data/`
  - `domain/`
  - `presentation/`
- auth session controller con `Riverpod`
- secure local token storage
- `auth api client`
- adaptador Google Sign-In
- flujo de magic link

### Verification

- tests de controller/session state
- analyze de `auth`

## Task 4 - Session Gate In App Shell

### Objective

Integrar auth al arranque de la app sin ensuciar otra vez `app_shell`.

### Scope

- `restoring session`
- `unauthenticated`
- `authenticated`
- pantalla/login gate
- conexion entre auth session y `player bootstrap`

### Verification

- tests de `app_shell` para gate de sesion
- smoke de flujo restoring -> login -> bootstrap

## Task 5 - Identity To Player Ownership

### Objective

Vincular cuenta autenticada con progreso del jugador y definir politica inicial de migracion.

### Scope

- asociacion `user -> player progress`
- politica inicial:
  - usar progreso remoto si existe
  - adjuntar progreso local si la cuenta es nueva y el backend no tiene uno mas fuerte
- endurecer bootstrap autenticado

### Verification

- tests backend de vinculo user/player
- tests frontend de bootstrap autenticado

## Task 6 - Integrated Verification And Docs

### Objective

Cerrar la fase con verificacion integrada y documentacion.

### Scope

- `README.md`
- `backend/README.md`
- reglas de sesion
- flujo de restore/login/logout
- providers activos
- deuda conocida

### Verification

- `flutter test` focalizado
- `flutter analyze`
- `pytest backend/tests -q`
- `compileall`

## Risks To Watch

- acoplar demasiado auth con `home` o `app_shell`
- no separar bien `provider identity` de `app session`
- dejar tokens inseguros
- mezclar progreso anonimo y autenticado sin regla clara

## Notes

- `special quest decision` y sharing no se mezclan en esta fase
- si Google Sign-In mobile exige setup largo, se puede cerrar primero el backend + magic link + session gate, y luego sumar Google en el mismo Phase 5
