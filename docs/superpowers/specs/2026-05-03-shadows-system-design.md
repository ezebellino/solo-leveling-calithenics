# Shadows System Design

Fecha: 2026-05-03
Proyecto: `ASH LEVEL UP`
Estado: Draft validado en conversación, pendiente de revisión final del usuario

## Objetivo

Convertir `Sombras` en un sistema real de prestigio, lore y colección permanente,
alineado con la fantasía de Solo Leveling, sin introducir buffs jugables todavía.

El sistema debe:

- reemplazar el bloque decorativo actual por una métrica significativa;
- dar momentos de premio memorables mediante popups del `System`;
- dejar las sombras guardadas en el inventario del usuario;
- sostener una futura capa de marketing y share cards sin depender de ella hoy.

## Alcance de esta fase

Esta spec cubre:

- modelo de dominio de `Sombras`;
- roster inicial y jerarquía visual;
- reglas de desbloqueo;
- galería compacta y carta expandida;
- popup de obtención;
- relación con `Inventario`, `Jugador` y `System UI`;
- implicancias arquitectónicas inmediatas.

No cubre implementación de beneficios comerciales, buffs de gameplay ni storage
de assets remoto.

## Principios de diseño

1. `Sombras` es prestigio, no poder.
Cada sombra representa una conquista real del usuario, no un multiplicador de
stats o XP.

2. El premio debe sentirse ceremonial.
La emoción principal ocurre cuando el `System` concede una nueva sombra, no
solamente cuando la galería incrementa un contador.

3. La colección debe ser permanente.
Las sombras se desbloquean una sola vez y luego quedan en el inventario para
consulta futura.

4. La UI debe mantener prioridad por legibilidad.
Los efectos de humo, fuego, glow y bordes animados no deben competir con la
lectura ni con la interacción.

5. El sistema debe nacer modular.
`Sombras` no debe incrustarse dentro de `home_page.dart` ni depender de lógica
mezclada con quests, avatar o stats.

## Propuesta de producto

`Sombras` se implementa como una colección premium del jugador:

- el bloque visible en la app muestra `Sombras obtenidas / total`;
- cada sombra tiene una carta compacta dentro de una galería;
- al tocar una carta, se abre una versión completa expandida;
- cuando una sombra nueva se desbloquea, aparece un popup del `System`;
- luego esa sombra queda almacenada en `Inventario > Sombras`.

La combinación elegida es:

- `galería premium` como lugar de memoria;
- `eco de disciplina` como lógica de desbloqueo;
- `colección permanente` como forma de progresión aspiracional.

## Roster inicial

Para la primera versión se usará un roster corto y fuerte de 6 sombras:

1. `Igris`
2. `Tank`
3. `Iron`
4. `Tusk`
5. `Beru`
6. `Bellion`

Razones:

- cubren distintas identidades visuales;
- permiten una escalera de prestigio clara;
- dejan espacio para futuras expansiones con `Kaisel`, `Jima`, `Greed`,
  `Kamish` y otras sombras/eventos.

## Naturaleza de las sombras

Cada sombra es:

- un desbloqueo único;
- permanente;
- visible en inventario;
- sin bonus jugables en esta fase;
- con lore corto y visual premium.

Cada sombra tiene:

- `id`
- `name`
- `title`
- `rarity`
- `flavorText`
- `unlockHint`
- `unlockCondition`
- `artAsset`
- `thumbnailPalette`
- `fullCardAsset`
- `isUnlocked`
- `unlockedAt`

## Rarezas y dirección visual

Las sombras deben respirar distinto según categoría visual. Esto define glow,
borde, humo y velocidad de animación.

### Igris

- identidad: caballero / filo / disciplina temprana
- color principal: rojo oscuro
- animación: humo veloz, brillo cortante, barrido rápido

### Tank

- identidad: muro / defensa / constancia pesada
- color principal: violeta con oro
- animación: pulso denso, vibración pesada, glow lento

### Iron

- identidad: voluntad de acero / forja
- color principal: naranja hierro
- animación: brasa, chispas lentas, calor de forja

### Tusk

- identidad: ritual / magia / dominio oscuro
- color principal: violeta arcano
- animación: niebla ritual, sigilos suaves, deriva mágica

### Beru

- identidad: agresión elite / lealtad feroz
- color principal: violeta eléctrico
- animación: aura agresiva, pulsos nerviosos, destellos rápidos

### Bellion

- identidad: supremacía / imperio / autoridad final
- color principal: púrpura imperial
- animación: energía densa, fuego oscuro lento, reflejo ceremonial

## Reglas de desbloqueo

Las sombras no se eligen manualmente. El `System` las concede cuando el usuario
cumple una condición real de progreso.

### Principio

Cada desbloqueo debe sentirse:

- raro;
- comprensible;
- alineado con un tipo de conquista;
- alcanzable dentro de una progresión sana.

### Reglas iniciales propuestas

#### Igris

Primer gran hito de disciplina.

Condición propuesta:

- completar la misión principal durante `7 días` distintos.

#### Tank

Hito de resistencia y constancia.

Condición propuesta:

- alcanzar `racha de 14 días`.

#### Iron

Volumen sostenido de trabajo.

Condición propuesta:

- completar `30 quests` totales.

#### Tusk

Dominio de desafíos especiales.

Condición propuesta:

- completar `3 quests especiales` aceptadas.

#### Beru

Consistencia elite.

Condición propuesta:

- lograr `2 semanas perfectas` o equivalente definido por sistema semanal.

#### Bellion

Prestigio de largo plazo.

Condición propuesta:

- alcanzar `Lv. 50` y mantener constancia mínima reciente.

### Regla de seguridad

Las condiciones no deben requerir comportamientos compulsivos o anti-recuperación.
El sistema debe premiar frecuencia, disciplina y continuidad, no castigo físico.

## UX: bloque de Sombras en la app

El bloque actual de `Sombras` deja de ser un número decorativo y pasa a mostrar:

- `cantidad obtenida / total`;
- nombre de la última sombra obtenida o la más rara desbloqueada;
- CTA para abrir galería;
- hint de próxima sombra si el usuario todavía tiene pocas.

Ejemplo:

- `2 / 6 Sombras obtenidas`
- `Ultima: Igris`
- `Proximo eco: Tank`

## UX: galería compacta

La galería muestra `cards compactas` en grilla.

Cada card compacta incluye:

- retrato o crop principal del asset;
- nombre;
- rareza;
- estado `Obtenida` o `Bloqueada`;
- borde animado por identidad visual;
- overlay oscuro en bloqueadas;
- hint breve del desbloqueo si está bloqueada.

### Estados

#### Obtenida

- colores vivos;
- glow activo;
- humo o energía sutil según la sombra;
- respuesta táctil clara al toque.

#### Bloqueada

- oscurecida;
- menor saturación;
- nombre visible o parcialmente oculto según balance final;
- texto guía del tipo `Completa 7 misiones principales`.

## UX: carta expandida

Al tocar una card compacta, se abre una `ventana expandida` tipo `System popup`.

La versión expandida:

- muestra la `carta completa` del asset;
- usa entrada cinematográfica `fade + glow + barrido holográfico`;
- conserva gesto simple de cierre;
- puede incluir una capa superior ligera con:
  - nombre
  - rareza
  - fecha de obtención
  - lore corto

La carta completa no debe recortarse agresivamente. La prioridad es que el
usuario pueda disfrutar la pieza visual que obtuvo.

## UX: popup de obtención

Cuando una sombra se desbloquea, el `System` debe mostrar una ventana emergente.

Contenido mínimo:

- encabezado `Notification` o equivalente del `System`;
- mensaje `Nueva sombra obtenida`;
- nombre de la sombra;
- teaser visual premium;
- línea corta de lore;
- confirmación de que fue añadida al inventario.

Secuencia visual:

1. oscurecimiento de fondo;
2. barrido holográfico;
3. aparición del nombre;
4. glow del retrato;
5. CTA simple para cerrar o ver la carta.

El popup es la pieza emocional principal del sistema.

## Relación con cofres

Los cofres siguen siendo un sistema separado.

En esta fase:

- los cofres no entregan sombras de forma aleatoria;
- las sombras se desbloquean por hitos de progreso;
- la animación de cofres puede tomar inspiración visual del popup de sombras.

Esto evita mezclar prestigio de largo plazo con economía aleatoria demasiado
pronto.

## Relación con compartir logros

La futura capa de share cards debe construirse encima de `Sombras`, no al
revés.

La primera versión compartible debe usar:

- nombre del usuario;
- clase actual;
- nivel;
- sombra obtenida;
- branding `ASH LEVEL UP`.

Pero queda explícitamente fuera de esta fase.

## Logo y branding

El logo `logo-SoloLeveling.png` se incorpora como referencia principal del
producto `ASH LEVEL UP`.

Debe integrarse progresivamente en:

- splash/onboarding;
- popups del `System`;
- share cards futuras;
- branding del inventario o galería si encaja sin contaminar la lectura.

## Arquitectura objetivo en Flutter

`Sombras` debe nacer como feature separada:

`lib/features/shadows/`

Subcapas:

- `domain/`
- `application/`
- `data/`
- `presentation/`

### Domain

- entidad `Shadow`
- value objects de rareza y condición
- reglas de desbloqueo

### Application

- casos de uso:
  - evaluar desbloqueos
  - listar sombras
  - obtener detalle
  - marcar nueva sombra como vista

### Data

- datasource local/remoto
- mapeo desde backend

### Presentation

- galería
- card compacta
- modal expandido
- popup de obtención

## Arquitectura objetivo en backend

Agregar módulo `shadows` con:

- modelos/schemas dedicados;
- reglas de desbloqueo o evaluación;
- snapshot del inventario de sombras del jugador;
- soporte futuro para share cards.

Estructura mínima deseada:

- `backend/app/modules/shadows/models.py`
- `backend/app/modules/shadows/schemas.py`
- `backend/app/modules/shadows/service.py`
- `backend/app/modules/shadows/router.py`

## Errores y casos borde

- una sombra no debe desbloquearse dos veces;
- si el backend está fuera de línea, el estado local no debe corromperse;
- si un usuario ve una carta bloqueada, siempre debe entender cuál es el próximo
  requisito;
- la UI debe seguir siendo usable en mobile angosto;
- las animaciones deben degradar con elegancia si el dispositivo no rinde bien.

## Testing

### Flutter

- test de render de galería compacta;
- test de estado bloqueada/obtenida;
- test de apertura de carta expandida;
- test de popup al desbloquear;
- test de contador `obtenidas / total`.

### Backend

- test de reglas de desbloqueo;
- test de idempotencia;
- test de serialización de estado de sombras;
- test de integración con progreso del jugador.

## Roadmap inmediato

### Fase 1: Sombras MVP

1. modelo y data de sombras
2. reglas de desbloqueo
3. bloque `Sombras` con valor real
4. galería compacta
5. modal/carta expandida
6. popup de obtención

### Fase 2: Popups del System

- `Nueva sombra obtenida`
- `Cambio de clase`
- `Level Up`
- `Cofre recibido`

### Fase 3: Reestructuración

- separar Flutter por features y capas
- separar backend por módulos

### Fase 4: Share Cards

- render compartible
- share sheet nativo
- primeras variantes:
  - `Nueva sombra`
  - `Level Up`

## Fuera de alcance explícito

- descuentos o free pass comerciales;
- buffs o pasivas otorgadas por sombras;
- integración exclusiva con WhatsApp;
- marketplace o tienda;
- upload binario de assets al backend en esta fase.

## Decisión final

La dirección elegida para `Sombras` es:

- prestigio puro;
- lore corto;
- colección permanente;
- popup ceremonial del `System`;
- galería premium con carta expandida;
- arquitectura modular lista para crecer.

Es la opción más consistente con el universo de Solo Leveling, con el tono de
la app y con una base técnica profesional para escalar el producto.
