enum SystemMuscleZone {
  chest,
  shoulders,
  triceps,
  back,
  biceps,
  forearms,
  wrists,
  quadriceps,
  glutes,
  hamstrings,
  calves,
  core,
  obliques,
  lowerBack,
  hips,
}

enum _SystemWorkoutPresetId {
  push,
  pull,
  legs,
  core,
  skill,
  recovery,
  fullBody,
  defaultActivation,
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
    required this.secondaryFocus,
    required this.recoveryHint,
    required this.highlightTags,
    required this.highlightZonesFront,
    required this.highlightZonesBack,
    required this.exerciseCards,
  });

  final String primaryFocus;
  final String secondaryFocus;
  final String recoveryHint;
  final List<String> highlightTags;
  final List<SystemMuscleZone> highlightZonesFront;
  final List<SystemMuscleZone> highlightZonesBack;
  final List<SystemExerciseCardModel> exerciseCards;

  factory SystemMuscleMapModel.fromWorkoutFocus({
    required String focus,
    required String stageTitle,
  }) {
    final presetId = _classifyWorkoutFocus(focus);
    return _presetFor(presetId, stageTitle: stageTitle).toModel();
  }

  static _SystemWorkoutPresetId _classifyWorkoutFocus(String focus) {
    final normalized = focus.toLowerCase();
    if (normalized.contains('empuje')) {
      return _SystemWorkoutPresetId.push;
    }
    if (normalized.contains('tiron')) {
      return _SystemWorkoutPresetId.pull;
    }
    if (normalized.contains('pierna')) {
      return _SystemWorkoutPresetId.legs;
    }
    if (normalized.contains('core')) {
      return _SystemWorkoutPresetId.core;
    }
    if (normalized.contains('handstand') || normalized.contains('skill')) {
      return _SystemWorkoutPresetId.skill;
    }
    if (normalized.contains('movilidad') ||
        normalized.contains('caminata') ||
        normalized.contains('descarga') ||
        normalized.contains('recuperacion')) {
      return _SystemWorkoutPresetId.recovery;
    }
    if (normalized.contains('resistencia') ||
        normalized.contains('full body') ||
        normalized.contains('bloque tecnico') ||
        normalized.contains('fuerza maxima')) {
      return _SystemWorkoutPresetId.fullBody;
    }
    return _SystemWorkoutPresetId.defaultActivation;
  }

  static _SystemMuscleMapPreset _presetFor(
    _SystemWorkoutPresetId presetId, {
    required String stageTitle,
  }) {
    switch (presetId) {
      case _SystemWorkoutPresetId.push:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Pecho, hombro y triceps',
          secondaryFocus: 'Core y estabilidad escapular',
          recoveryHint: 'Movilidad de hombro y pectoral',
          highlightTags: ['Pecho', 'Hombro', 'Triceps', 'Core'],
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
      case _SystemWorkoutPresetId.pull:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Espalda, biceps y antebrazo',
          secondaryFocus: 'Core anti-balanceo',
          recoveryHint: 'Descarga de dorsal y agarre',
          highlightTags: ['Espalda', 'Biceps', 'Antebrazo', 'Core'],
          highlightZonesFront: [
            SystemMuscleZone.biceps,
            SystemMuscleZone.forearms,
            SystemMuscleZone.core,
          ],
          highlightZonesBack: [
            SystemMuscleZone.back,
            SystemMuscleZone.forearms,
          ],
          exerciseCards: [
            SystemExerciseCardModel(
              name: 'Dominadas',
              category: 'Tiron',
              muscles: ['Espalda', 'Biceps', 'Antebrazo'],
            ),
            SystemExerciseCardModel(
              name: 'Remo australiano',
              category: 'Tiron',
              muscles: ['Espalda', 'Biceps', 'Core'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.legs:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Cuadriceps, gluteo y femoral',
          secondaryFocus: 'Gemelos y zona media',
          recoveryHint: 'Cadera, tobillo y femoral',
          highlightTags: ['Cuadriceps', 'Gluteo', 'Femoral', 'Gemelos'],
          highlightZonesFront: [
            SystemMuscleZone.quadriceps,
            SystemMuscleZone.calves,
          ],
          highlightZonesBack: [
            SystemMuscleZone.glutes,
            SystemMuscleZone.hamstrings,
            SystemMuscleZone.calves,
          ],
          exerciseCards: [
            SystemExerciseCardModel(
              name: 'Sentadillas',
              category: 'Pierna',
              muscles: ['Cuadriceps', 'Gluteo', 'Core'],
            ),
            SystemExerciseCardModel(
              name: 'Puente de gluteo',
              category: 'Pierna',
              muscles: ['Gluteo', 'Femoral', 'Gemelos'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.core:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Abdominales y oblicuos',
          secondaryFocus: 'Lumbar y gluteo medio',
          recoveryHint: 'Respiracion y movilidad toracica',
          highlightTags: ['Abdominales', 'Oblicuos', 'Lumbar'],
          highlightZonesFront: [
            SystemMuscleZone.core,
            SystemMuscleZone.obliques,
          ],
          highlightZonesBack: [
            SystemMuscleZone.lowerBack,
          ],
          exerciseCards: [
            SystemExerciseCardModel(
              name: 'Hollow hold',
              category: 'Core',
              muscles: ['Abdominales', 'Oblicuos'],
            ),
            SystemExerciseCardModel(
              name: 'Superman hold',
              category: 'Core',
              muscles: ['Lumbar', 'Gluteo', 'Espalda'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.skill:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Hombro, triceps y control corporal',
          secondaryFocus: 'Core profundo y mu\u00f1eca',
          recoveryHint: 'Mu\u00f1eca, hombro y cuello',
          highlightTags: ['Hombro', 'Triceps', 'Core', 'Mu\u00f1eca'],
          highlightZonesFront: [
            SystemMuscleZone.shoulders,
            SystemMuscleZone.triceps,
            SystemMuscleZone.core,
            SystemMuscleZone.forearms,
            SystemMuscleZone.wrists,
          ],
          highlightZonesBack: [
            SystemMuscleZone.shoulders,
            SystemMuscleZone.triceps,
            SystemMuscleZone.forearms,
            SystemMuscleZone.wrists,
          ],
          exerciseCards: [
            SystemExerciseCardModel(
              name: 'Wall handstand',
              category: 'Skill',
              muscles: ['Hombro', 'Triceps', 'Core'],
            ),
            SystemExerciseCardModel(
              name: 'Planche lean',
              category: 'Skill',
              muscles: ['Mu\u00f1eca', 'Hombro', 'Core'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.recovery:
        return const _SystemMuscleMapPreset(
          primaryFocus: 'Recuperacion activa global',
          secondaryFocus: 'Cadera, espalda y gemelos',
          recoveryHint: 'Movilidad completa y respiracion',
          highlightTags: ['Cadera', 'Espalda', 'Gemelos', 'Respiracion'],
          highlightZonesFront: [
            SystemMuscleZone.hips,
            SystemMuscleZone.calves,
            SystemMuscleZone.core,
          ],
          highlightZonesBack: [
            SystemMuscleZone.hips,
            SystemMuscleZone.back,
            SystemMuscleZone.calves,
          ],
          exerciseCards: [
            SystemExerciseCardModel(
              name: 'Movilidad de cadera',
              category: 'Recuperacion',
              muscles: ['Cadera', 'Gemelos', 'Core'],
            ),
            SystemExerciseCardModel(
              name: 'Caminata ligera',
              category: 'Recuperacion',
              muscles: ['Espalda', 'Cadera', 'Respiracion'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.fullBody:
        return _SystemMuscleMapPreset(
          primaryFocus: 'Cuerpo completo',
          secondaryFocus: 'Enfasis de etapa: $stageTitle',
          recoveryHint: 'Descarga general y movilidad',
          highlightTags: const [
            'Pecho',
            'Espalda',
            'Pierna',
            'Core',
            'Hombro',
          ],
          highlightZonesFront: const [
            SystemMuscleZone.chest,
            SystemMuscleZone.quadriceps,
            SystemMuscleZone.calves,
            SystemMuscleZone.core,
            SystemMuscleZone.shoulders,
          ],
          highlightZonesBack: const [
            SystemMuscleZone.back,
            SystemMuscleZone.hamstrings,
            SystemMuscleZone.calves,
            SystemMuscleZone.shoulders,
            SystemMuscleZone.glutes,
          ],
          exerciseCards: const [
            SystemExerciseCardModel(
              name: 'Burpees',
              category: 'Full body',
              muscles: ['Pecho', 'Pierna', 'Core'],
            ),
            SystemExerciseCardModel(
              name: 'Circuito tecnico',
              category: 'Full body',
              muscles: ['Espalda', 'Hombro', 'Gluteo'],
            ),
          ],
        );
      case _SystemWorkoutPresetId.defaultActivation:
        return _SystemMuscleMapPreset(
          primaryFocus: 'Activacion general',
          secondaryFocus: 'Etapa activa: $stageTitle',
          recoveryHint: 'Movilidad y chequeo tecnico',
          highlightTags: const ['Activacion', 'Core', 'Pierna'],
          highlightZonesFront: const [
            SystemMuscleZone.core,
            SystemMuscleZone.quadriceps,
          ],
          highlightZonesBack: const [
            SystemMuscleZone.hamstrings,
          ],
          exerciseCards: const [
            SystemExerciseCardModel(
              name: 'Activacion base',
              category: 'General',
              muscles: ['Core', 'Pierna'],
            ),
          ],
        );
    }
  }
}

class _SystemMuscleMapPreset {
  const _SystemMuscleMapPreset({
    required this.primaryFocus,
    required this.secondaryFocus,
    required this.recoveryHint,
    required this.highlightTags,
    required this.highlightZonesFront,
    required this.highlightZonesBack,
    required this.exerciseCards,
  });

  final String primaryFocus;
  final String secondaryFocus;
  final String recoveryHint;
  final List<String> highlightTags;
  final List<SystemMuscleZone> highlightZonesFront;
  final List<SystemMuscleZone> highlightZonesBack;
  final List<SystemExerciseCardModel> exerciseCards;

  SystemMuscleMapModel toModel() {
    return SystemMuscleMapModel(
      primaryFocus: primaryFocus,
      secondaryFocus: secondaryFocus,
      recoveryHint: recoveryHint,
      highlightTags: highlightTags,
      highlightZonesFront: highlightZonesFront,
      highlightZonesBack: highlightZonesBack,
      exerciseCards: exerciseCards,
    );
  }
}
