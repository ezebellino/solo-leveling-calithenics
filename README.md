# Solo Leveling Calisthenics

App mobile inspirada en la progresion de `Solo Leveling`, aplicada a entrenamiento de calistenia.

## Enfoque tecnico

Tu stack preferido sigue teniendo sentido:

- `Flutter` para la app mobile: una sola base para Android/iOS.
- `FastAPI` para backend futuro: autenticacion, rutinas, progreso, ranking, inventario y sincronizacion.
- `React + Tailwind` para panel web admin o landing.

La recomendacion de usar Flutter para mobile es buena si queres:

- velocidad de desarrollo;
- una UI visualmente fuerte sin duplicar Android/iOS;
- escalar luego hacia animaciones, gamificacion y dashboards.

No puedo evaluar los "puntos e instrucciones" de la otra IA porque no estan en el chat actual. Si me los pegas, los reviso uno por uno y te digo que conservar, que corregir y que descartar.

## Estado actual

Este repo arranca con una base manual de Flutter:

- estructura modular por features;
- tema oscuro con acento esmeralda;
- pantalla inicial con progreso, quests y rutina semanal mock;
- modelos semilla para evolucionar hacia backend real.

## Estructura

```text
lib/
  app.dart
  main.dart
  core/
    router/
    theme/
  features/
    home/
      domain/
      presentation/
```

## Estado del entorno

El proyecto ya fue inicializado con Flutter y se dejo un SDK local en `tools/flutter` para trabajo inmediato. Ese SDK esta ignorado en Git para no subir gigas innecesarios al repo.

## Ejecucion local

Desde la raiz del repo podes usar:

1. `.\flutterw.ps1 doctor -v`
2. `.\flutterw.ps1 pub get`
3. `.\flutterw.ps1 run -d windows`
4. `.\flutterw.ps1 run -d chrome`

Para correr en Android todavia falta instalar Android Studio o al menos Android SDK y luego configurar `flutter config --android-sdk`.

## Roadmap recomendado

1. `MVP mobile`
   - onboarding
   - login local/mock
   - dashboard
   - rutina diaria
   - progreso de stats
   - quests
2. `Backend FastAPI`
   - usuarios
   - rutinas
   - sesiones
   - progreso
   - logros
3. `Version online`
   - autenticacion
   - almacenamiento
   - sincronizacion cloud
   - ranking social

