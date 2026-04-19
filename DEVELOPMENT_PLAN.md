# Development Plan

Este archivo mantiene el hilo de desarrollo activo del proyecto. Cuando estas
funcionalidades esten terminadas, se elimina o se integra al README final.

## Estado actual

- Base Flutter creada y conectada al repo.
- UI principal inspirada en Solo Leveling ya implementada.
- Progresion visual de entrenamiento desde `Pre Beginner` hasta `Expert / Pro`.
- Seleccion de etapa inicial dentro de la app.

## Objetivos pendientes

### 1. HUD general animado

Objetivo:
- Hacer que el frame general tenga vida sin afectar legibilidad.

Alcance:
- Pulso suave de energia en el marco exterior.
- Barrido horizontal tenue en la barra superior del HUD.
- Variacion sutil de brillo en esquinas activas.

Criterio de terminado:
- El marco se siente vivo aun cuando la pantalla esta quieta.
- No tapa texto ni compite con cards y paneles.
- La animacion mantiene buen rendimiento en mobile.

Orden sugerido:
1. Añadir `AnimationController` para el frame general.
2. Animar barra superior y bordes laterales.
3. Ajustar intensidad por pantalla (`Sistema`, `Misiones`, `Atributos`, `Jugador`).

### 2. Barra inferior estilo System HUD

Objetivo:
- Reemplazar el look actual del `BottomNavigationBar` por una barra mas fiel al
  sistema del anime.

Alcance:
- Fondo propio con borde tecnico y glow.
- Indicador activo mas holografico.
- Iconos y labels con jerarquia mas marcada.
- Mejor integracion visual con el frame general.

Criterio de terminado:
- La barra se lee como parte del mismo HUD y no como componente Flutter
  default.
- El tab activo destaca con claridad sin perder sobriedad.
- La UI funciona bien en anchos chicos.

Orden sugerido:
1. Crear widget custom para la barra.
2. Integrar estados activo/inactivo y feedback al toque.
3. Afinar padding, altura y contraste en mobile.

### 3. Capa funcional real

Objetivo:
- Pasar del MVP visual a un MVP usable con progreso persistente.

Subfases:

#### 3.1 Quests por nivel

Objetivo:
- Generar misiones distintas segun la etapa elegida por el usuario.

Alcance:
- `Pre Beginner`: ejercicios asistidos y volumen bajo.
- `Beginner`: base full body 3 dias.
- `Intermediate`: aumento de dificultad y frecuencia.
- `Advanced` / `Expert`: bloques de fuerza, skill y resistencia.

Criterio de terminado:
- Cambiar de etapa cambia las quests visibles.
- Las quests tienen metas, progreso y recompensa coherentes.

#### 3.2 XP dinamico y progreso de fase

Objetivo:
- Hacer que el sistema de nivel deje de ser estatico.

Alcance:
- Completar quests suma XP.
- El XP alimenta barra de progreso y nivel.
- La app puede sugerir subida de fase cuando se cumplen criterios.

Criterio de terminado:
- El progreso cambia en tiempo real dentro de la UI.
- Hay una relacion clara entre entrenamiento, XP y ascenso.

#### 3.3 Persistencia local

Objetivo:
- Guardar estado del jugador entre sesiones.

Alcance:
- Etapa seleccionada.
- XP actual y nivel.
- Estado de quests.
- Racha y metricas basicas.

Criterio de terminado:
- Cerrar y reabrir la app conserva el estado.
- La estructura permite luego migrar a backend sin rehacer el dominio.

Orden sugerido:
1. Definir modelos serializables de jugador, quests y progreso.
2. Implementar repositorio local simple.
3. Conectar estado persistido a la UI.
4. Recalcular XP, nivel y quests desde el estado guardado.

## Orden recomendado de implementacion

Para maximizar valor y no perder foco:

1. Barra inferior estilo HUD.
2. Animacion del frame general.
3. Quests por nivel.
4. XP dinamico.
5. Persistencia local.

Razon:
- Los dos primeros cierran el lenguaje visual del producto.
- Los tres ultimos convierten la app en una experiencia real y acumulativa.

## Checklist de seguimiento

- [ ] HUD general con pulso o barrido suave
- [ ] Barra inferior rediseñada como System HUD
- [ ] Quests distintas por etapa
- [ ] XP dinamico conectado a acciones reales
- [ ] Persistencia local del jugador
- [ ] Evento de subida de nivel / fase

## Notas de implementacion

- Mantener legibilidad por encima del detalle visual.
- Evitar que animaciones del HUD compitan con contenido.
- Diseñar la persistencia de forma compatible con una futura API en FastAPI.
- Cuando toda esta hoja quede terminada, borrar este archivo o resumirlo dentro
  del README como historial cerrado.
