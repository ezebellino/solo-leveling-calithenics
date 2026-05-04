# System Evolution Popups Design

Fecha: 2026-05-04
Proyecto: `ASH LEVEL UP`
Estado: Mini-spec validada en conversacion

## Objetivo

Definir la direccion visual y de interaccion para dos eventos clave del
`System`:

- `Level Up`
- `Cambio de clase`

Ambos deben sentirse como intervenciones ceremoniales del Sistema, no como
modales comunes ni celebraciones arcade.

## Alcance

Esta mini-spec cubre:

- tono emocional;
- estructura visual;
- contenido minimo;
- comportamiento de cierre;
- jerarquia entre texto, datos y simbolos;
- lineamientos de animacion.

No cubre todavia implementacion tecnica detallada, transiciones compartibles,
audio ni haptics.

## Principio rector

Los popups de evolucion deben sentirse como un veredicto del Sistema.

No son:

- banners de app;
- toasts de recompensa;
- pantallas de celebracion arcade.

Si son:

- ventanas centrales grandes;
- intrusiones solemnes sobre el flujo actual;
- momentos de reconocimiento ritual del progreso del jugador.

## Decision visual global

Los dos eventos usan:

- una gran ventana central;
- el fondo de la app visible detras;
- oscurecimiento parcial del resto de la interfaz;
- lenguaje holografico coherente con el `System`;
- cierre manual con boton `Continuar`.

Razones:

- mantiene la continuidad con la pantalla donde el jugador estaba;
- hace que el Sistema "irrumpa" en vez de cambiar de escena por completo;
- evita que el usuario pierda el contexto del progreso actual.

## Tono

El tono elegido es `solemne / mistico`.

Esto implica:

- ritmo visual mas lento;
- brillo medido;
- humo, glow y barridos controlados;
- lenguaje formal del Sistema;
- ausencia de rebotes o estallidos tipo arcade.

## Popup: Level Up

### Intencion

Transmitir que el Sistema reconoce un crecimiento real del jugador.

### Estructura

La ventana debe incluir:

- encabezado tipo `Notification` o equivalente del Sistema;
- titulo principal: `Subiste de nivel`;
- dato fuerte: `Lv. X`;
- linea ritual debajo del dato principal;
- boton `Continuar`.

### Linea ritual

Debe existir una linea breve que refuerce el tono ceremonial.

Ejemplo base:

- `El Sistema reconoce tu crecimiento.`

La implementacion puede usar esta frase exacta o una variante equivalente,
siempre manteniendo el mismo peso simbolico.

### Jerarquia visual

Orden de importancia:

1. `Subiste de nivel`
2. `Lv. X`
3. linea ritual
4. boton `Continuar`

### Animacion

La animacion debe sugerir ascenso ritual.

Lineamientos:

- entrada por `fade + aparicion gradual`;
- barrido de luz horizontal o diagonal;
- glow contenido alrededor del nivel;
- humo o energia suave en capas de fondo;
- sin sacudidas ni explosiones.

## Popup: Cambio de clase

### Intencion

Transmitir una evolucion de identidad, no un mero cambio de etiqueta.

### Estructura

La ventana debe incluir:

- encabezado del Sistema;
- clase anterior visible;
- un sello, runa o glifo central;
- transicion hacia la nueva clase;
- nueva clase con mas peso visual;
- boton `Continuar`.

### Transicion de mejora

La secuencia central debe representar mejora y reemplazo ritual:

1. aparece la clase anterior;
2. el Sistema activa el sello/runa/glifo;
3. la clase anterior se degrada o disuelve;
4. emerge la clase nueva con mas brillo y autoridad;
5. el usuario confirma con `Continuar`.

### Simbolo central

Debe existir un elemento visual del Sistema entre la clase anterior y la nueva.

Opciones validas:

- sello;
- runa;
- glifo.

En esta fase no hace falta decidir su forma exacta, pero si su rol:

- actuar como catalizador visual de la evolucion;
- dar centro compositivo a la transicion.

### Jerarquia visual

Orden de importancia:

1. nueva clase
2. sello / runa / glifo
3. clase anterior
4. texto auxiliar si existiera
5. boton `Continuar`

### Animacion

La animacion debe sentirse como una mejora concedida por el Sistema.

Lineamientos:

- la clase anterior debe aparecer primero;
- el simbolo central se activa en segundo plano;
- la nueva clase emerge con mayor glow y definicion;
- la transicion debe ser limpia, no agresiva;
- evitar cualquier efecto que parezca celebracion arcade o loot flash.

## Interaccion

Ambos popups cierran solo con accion del usuario.

Decision tomada:

- siempre debe haber boton `Continuar`;
- no deben cerrarse automaticamente.

Razon:

- el jugador puede contemplar el momento todo el tiempo que quiera;
- refuerza el valor simbolico del evento;
- evita perder un hito importante por duracion automatica insuficiente.

## Lineamientos de copy

El texto del Sistema debe ser:

- breve;
- ceremonial;
- claro;
- sin exceso de explicacion;
- sin tono infantil o gamer generico.

El Sistema habla como una autoridad que constata un hecho.

## Relacion con overlays existentes

Este bloque reemplaza visualmente el tratamiento actual mas simple de:

- `LevelUpOverlay`
- aviso de `classChange`

La nueva implementacion debe mantener la arquitectura desacoplada:

- popup reutilizable si conviene;
- configuracion distinta para `level up` y `class change`;
- sin volver a cargar logica en `home_page.dart`.

## Restricciones de UX

- debe seguir viendose bien en mobile angosto;
- el texto no puede perder legibilidad por exceso de decoracion;
- el boton `Continuar` debe ser claro y facil de tocar;
- el fondo visible no debe competir con la ventana central.

## Testing esperado

Minimo:

- render del popup de `Level Up`;
- render del popup de `Cambio de clase`;
- presencia del boton `Continuar`;
- transicion visible entre clase anterior y nueva;
- comportamiento estable en layouts angostos.

## Decision final

La direccion elegida para los popups de evolucion es:

- gran ventana central;
- tono solemne / mistico;
- `Level Up` con linea ritual;
- `Cambio de clase` como transicion de mejora;
- sello / runa / glifo del Sistema como centro visual;
- cierre siempre manual con `Continuar`.

Es la opcion mas coherente con el universo de Solo Leveling y con la identidad
actual de `ASH LEVEL UP`.
