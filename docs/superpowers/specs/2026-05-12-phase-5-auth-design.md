# Phase 5 Auth Design

> **Goal:** Incorporar identidad real de usuario con una arquitectura de autenticacion limpia, segura y escalable, que permita guardar historial, sincronizar entre dispositivos y preparar futuras features como `sharing`, progreso multi-device y account recovery.

## Why This Phase Exists

`Phase 1` dejo una base transversal seria:

- `core` en frontend y backend
- `Riverpod`
- `Alembic`
- logging y errores iniciales

`Phase 2` separo el frontend por features reales:

- `app_shell`
- `player`
- `system`
- `quests`
- `inventory`
- `shadows`

`Phase 3` modularizo el backend:

- `player`
- `quests`
- `inventory`
- `shadows`
- `system`

`Phase 4` endurecio sync y observabilidad:

- backend como fuente de verdad durable
- fallback policy explicita
- trazabilidad con `requestId`

La deuda principal ahora ya no es estructura ni sync basico.

La deuda principal es identidad.

Hoy el producto todavia se apoya en un jugador base local/remoto sin cuenta real. Eso limita:

- historial persistente por persona
- uso en multiples dispositivos
- recuperacion de cuenta
- ownership claro del progreso
- sharing con identidad
- features sociales futuras

`Phase 5` existe para cerrar esa brecha.

## Phase Goal

Esta fase no busca sumar diez proveedores de login.

Busca dejar un sistema de autenticacion defendible que permita:

- login simple para el usuario
- identidad durable en backend
- sesion clara en frontend
- vinculo estable entre usuario y progreso
- posibilidad de reingreso desde otro dispositivo

Al cerrar la fase, el proyecto debe poder defender esto:

- un usuario puede iniciar sesion
- su cuenta queda asociada a su progreso
- la app sabe cuando hay sesion valida o expirada
- el backend autoriza requests en funcion de la identidad
- el producto sigue siendo usable y entendible

## Product Decision

La recomendacion para esta fase es:

- `Google Sign-In`
- `email magic link`

No se recomienda arrancar con `email + password` tradicional.

### Why

`Google Sign-In` aporta:

- menos friccion
- onboarding rapido
- muy buena UX en mobile

`Magic link` aporta:

- alternativa para usuarios sin login Google
- menos superficie de seguridad que password clasico
- recuperacion de cuenta mas simple

`Password` clasico se deja fuera por ahora porque agrega:

- hashing y politicas de password
- reset de password
- mas soporte
- mas errores de UX

## Out Of Scope

Esta fase no incluye:

- login con Apple
- Facebook login
- password tradicional
- MFA
- sharing final
- perfiles publicos
- ranking social
- migracion de datos entre multiples cuentas

Tampoco incluye observabilidad externa enterprise del auth. La prioridad es dejar el circuito base bien hecho.

## Core Problem To Solve

El sistema necesita responder de forma explicita:

- quien es el usuario
- donde vive la sesion
- como se restaura la sesion al abrir la app
- que pasa si el token expira
- como se asocia el progreso existente a una cuenta real
- que endpoints requieren autenticacion
- como se identifican los providers externos

Hoy ninguna de esas respuestas es formal. `Phase 5` las vuelve explicitas.

## Architectural Decision

La estrategia recomendada para esta fase es:

- `backend` como owner de identidad y sesion
- `frontend` como consumidor de sesion autenticada
- `Riverpod` como owner del estado de auth en Flutter
- `Google` y `magic link` como providers iniciales
- `JWT` o session token firmado como contrato de sesion

No vamos a acoplar la app directamente a la identidad de Google para todo.

Google o email sirven para probar identidad.

La sesion oficial del producto la emite el backend.

## Auth Model

### User

Entidad durable del producto.

Debe contener al menos:

- `id`
- `email`
- `display_name`
- `avatar_url`
- `is_active`
- `created_at`
- `updated_at`

### Identity

Relaciona usuario interno con proveedor externo.

Debe contemplar:

- `user_id`
- `provider`
- `provider_subject`
- `email_at_provider`
- `created_at`

Providers iniciales:

- `google`
- `magic_link`

### Session

Representa una sesion valida del producto.

Debe contemplar:

- `user_id`
- `session_id`
- `issued_at`
- `expires_at`
- `revoked_at` si se modela persistencia de sesiones

La decision exacta entre JWT puro o JWT + session store se puede bajar en implementacion, pero el backend debe poder:

- emitir sesion
- validar sesion
- invalidar sesion

## Session Contract

El frontend necesita un contrato simple y consistente:

- `accessToken`
- `expiresAt`
- `user`

Y una forma clara de saber:

- `authenticated`
- `unauthenticated`
- `restoring`
- `authFailure`

No debe quedar auth disperso entre widgets o servicios sueltos.

## Frontend Target

Nueva feature real:

```text
lib/features/auth/
  application/
  data/
  domain/
  presentation/
```

### Responsibilities

`application`

- auth session controller
- sign-in use cases
- restore session use case
- sign-out use case

`data`

- auth api client
- secure token storage
- provider integrations (`google`, `magic_link`)

`domain`

- `auth_user`
- `auth_session`
- auth failure/value objects

`presentation`

- login screen
- session gate
- auth status UI

### App Shell Integration

`app_shell` debe dejar de asumir siempre un jugador listo.

Debe poder pasar por estas etapas:

1. restoring session
2. unauthenticated gate
3. authenticated bootstrap

## Backend Target

Nuevo modulo real:

```text
backend/app/modules/auth/
  api/
  application/
  domain/
  infrastructure/
```

### Responsibilities

`api`

- start Google auth exchange
- request magic link
- consume magic link
- session introspection
- sign out

`application`

- verify provider token / link
- create or resolve local user
- issue app session
- revoke session

`domain`

- auth entities
- auth errors
- auth policies

`infrastructure`

- models
- repositories
- token utilities
- provider adapters

## Ownership Migration

El sistema actual tiene un jugador base y progreso sin identidad fuerte.

La fase debe dejar una estrategia clara:

- cuando un usuario inicia sesion por primera vez
- el backend crea o recupera su cuenta
- se asocia un `player` durable a ese `user`
- el frontend deja de operar como jugador anonimo principal

No es necesario resolver migraciones complejas entre multiples identidades en esta fase.

Pero si es necesario decidir que pasa con el progreso existente del jugador actual.

### Recommended Policy

- si el usuario inicia sesion por primera vez en este dispositivo:
  - se intenta adjuntar el progreso local actual a su cuenta si no existe progreso remoto previo fuerte
- si ya existe progreso remoto de esa cuenta:
  - el backend manda como verdad durable
- cualquier conflicto visible se deja para una fase posterior de conflict resolution avanzada

## Security Baseline

Minimo esperado:

- tokens no persistidos en texto plano inseguro
- almacenamiento seguro del token en cliente
- validacion backend de sesion en endpoints protegidos
- expiracion de sesion
- sign-out real
- errores seguros sin filtrar detalles sensibles

No es aceptable dejar auth como un boolean local o mock invisible.

## API Surface Target

Minimo recomendado:

- `POST /api/v1/auth/google`
- `POST /api/v1/auth/magic-link/request`
- `POST /api/v1/auth/magic-link/verify`
- `GET /api/v1/auth/session`
- `POST /api/v1/auth/logout`

Y un mecanismo de autorizacion para endpoints protegidos, por ejemplo:

- `Authorization: Bearer <token>`

## Error Handling Target

Errores minimos esperados:

- `auth_invalid_credentials`
- `auth_session_expired`
- `auth_provider_verification_failed`
- `auth_magic_link_invalid`
- `auth_magic_link_expired`
- `auth_forbidden`
- `auth_unauthorized`

Frontend y backend deben mapear estos codigos de forma consistente.

## Observability Target

La observabilidad minima de esta fase:

- eventos de sign-in started/succeeded/failed
- eventos de restore session
- eventos de sign-out
- errores de provider verification
- request tracing en endpoints auth

Sin loguear secretos, tokens crudos ni datos sensibles innecesarios.

## UX Target

La experiencia ideal de esta fase:

1. la app abre
2. intenta restaurar sesion
3. si no hay sesion:
   - muestra pantalla clara de login
   - `Continuar con Google`
   - `Recibir link por email`
4. si hay sesion:
   - bootstrap normal del jugador
5. si expira la sesion:
   - la app lo informa y vuelve a gate de autenticacion

La UX debe ser limpia y sobria, no un formulario pesado de signup tradicional.

## Risks

Los riesgos reales de esta fase son:

- mezclar auth con bootstrap sin una frontera clara
- acoplar demasiado Flutter a Google SDK
- no definir bien que pasa con el progreso previo
- guardar tokens de forma insegura
- romper sync por no distinguir usuario anonimo de usuario autenticado

Por eso esta fase debe ejecutarse por tareas pequenas y con tests serios.

## Success Criteria

La fase se considera lograda si:

- existe feature `auth` real en Flutter
- existe modulo `auth` real en FastAPI
- un usuario puede iniciar sesion con Google o magic link
- la sesion puede restaurarse
- el backend protege endpoints autenticados
- el progreso queda asociado a la cuenta
- el sistema sigue siendo entendible, testeable y mergeable

## Recommended Execution Order

1. modelo y modulo backend de `auth`
2. contratos de sesion y endpoints base
3. feature `auth` en Flutter
4. session gate en `app_shell`
5. vinculacion `auth -> player bootstrap`
6. verificacion integrada y documentacion
