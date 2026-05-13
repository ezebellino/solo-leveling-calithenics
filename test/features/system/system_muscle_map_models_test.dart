import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_map_models.dart';

void main() {
  test('maps push workout to chest shoulders and triceps emphasis', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Empuje + hombro',
      stageTitle: 'Beginner',
    );

    expect(model.primaryFocus, 'Pecho, hombro y triceps');
    expect(model.secondaryFocus, 'Core y estabilidad escapular');
    expect(model.recoveryHint, 'Movilidad de hombro y pectoral');
    expect(model.highlightTags, ['Pecho', 'Hombro', 'Triceps', 'Core']);
    expect(
      model.highlightZonesFront,
      [
        SystemMuscleZone.chest,
        SystemMuscleZone.shoulders,
        SystemMuscleZone.triceps,
        SystemMuscleZone.core,
      ],
    );
    expect(
      model.highlightZonesBack,
      [SystemMuscleZone.shoulders, SystemMuscleZone.triceps],
    );
    expect(model.exerciseCards.first.name, 'Flexiones');
    expect(model.exerciseCards.first.category, 'Empuje');
  });

  test('maps pull workout to back biceps and grip support', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Tiron vertical + core',
      stageTitle: 'Intermediate',
    );

    expect(model.primaryFocus, 'Espalda, biceps y antebrazo');
    expect(model.secondaryFocus, 'Core anti-balanceo');
    expect(model.recoveryHint, 'Descarga de dorsal y agarre');
    expect(model.highlightTags, ['Espalda', 'Biceps', 'Antebrazo', 'Core']);
    expect(model.highlightZonesFront, contains(SystemMuscleZone.biceps));
    expect(model.highlightZonesFront, contains(SystemMuscleZone.forearms));
    expect(model.highlightZonesBack, contains(SystemMuscleZone.back));
    expect(model.exerciseCards.last.name, 'Remo australiano');
    expect(model.exerciseCards.last.muscles, contains('Core'));
  });

  test('maps leg workout to lower-body focus and recovery', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Pierna + gluteo',
      stageTitle: 'Advanced',
    );

    expect(model.primaryFocus, 'Cuadriceps, gluteo y femoral');
    expect(model.secondaryFocus, 'Gemelos y zona media');
    expect(model.recoveryHint, 'Cadera, tobillo y femoral');
    expect(model.highlightTags, ['Cuadriceps', 'Gluteo', 'Femoral', 'Gemelos']);
    expect(
      model.highlightZonesFront,
      [SystemMuscleZone.quadriceps, SystemMuscleZone.calves],
    );
    expect(model.highlightZonesBack, contains(SystemMuscleZone.glutes));
    expect(model.highlightZonesBack, contains(SystemMuscleZone.hamstrings));
    expect(model.exerciseCards.first.category, 'Pierna');
  });

  test('maps core workout to abdominal and lower-back support', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Core anti extension',
      stageTitle: 'Beginner',
    );

    expect(model.primaryFocus, 'Abdominales y oblicuos');
    expect(model.secondaryFocus, 'Lumbar y gluteo medio');
    expect(model.recoveryHint, 'Respiracion y movilidad toracica');
    expect(model.highlightTags, ['Abdominales', 'Oblicuos', 'Lumbar']);
    expect(
      model.highlightZonesFront,
      [SystemMuscleZone.core, SystemMuscleZone.obliques],
    );
    expect(model.highlightZonesBack, [SystemMuscleZone.lowerBack]);
    expect(model.exerciseCards.last.name, 'Superman hold');
  });

  test('maps skill workout with exact wrist strings and zones', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Skill + handstand',
      stageTitle: 'Intermediate',
    );

    expect(model.primaryFocus, 'Hombro, triceps y control corporal');
    expect(model.secondaryFocus, 'Core profundo y mu\u00f1eca');
    expect(model.recoveryHint, 'Mu\u00f1eca, hombro y cuello');
    expect(model.highlightTags, ['Hombro', 'Triceps', 'Core', 'Mu\u00f1eca']);
    expect(
      model.highlightZonesFront,
      [
        SystemMuscleZone.shoulders,
        SystemMuscleZone.triceps,
        SystemMuscleZone.core,
        SystemMuscleZone.forearms,
        SystemMuscleZone.wrists,
      ],
    );
    expect(
      model.highlightZonesBack,
      [
        SystemMuscleZone.shoulders,
        SystemMuscleZone.triceps,
        SystemMuscleZone.forearms,
        SystemMuscleZone.wrists,
      ],
    );
    expect(model.exerciseCards.last.name, 'Planche lean');
    expect(model.exerciseCards.last.category, 'Skill');
    expect(model.exerciseCards.last.muscles, ['Mu\u00f1eca', 'Hombro', 'Core']);
  });

  test('maps recovery workout to active recovery preset', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Movilidad + caminata',
      stageTitle: 'Intermediate',
    );

    expect(model.primaryFocus, 'Recuperacion activa global');
    expect(model.secondaryFocus, 'Cadera, espalda y gemelos');
    expect(model.recoveryHint, 'Movilidad completa y respiracion');
    expect(model.highlightTags, ['Cadera', 'Espalda', 'Gemelos', 'Respiracion']);
    expect(model.highlightZonesFront, contains(SystemMuscleZone.hips));
    expect(model.highlightZonesBack, contains(SystemMuscleZone.back));
    expect(model.exerciseCards.first.category, 'Recuperacion');
    expect(model.exerciseCards.last.muscles.last, 'Respiracion');
  });

  test('uses stage title for full-body emphasis', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Full body tecnico',
      stageTitle: 'Advanced',
    );

    expect(model.primaryFocus, 'Cuerpo completo');
    expect(model.secondaryFocus, 'Enfasis de etapa: Advanced');
    expect(model.recoveryHint, 'Descarga general y movilidad');
    expect(model.highlightTags, ['Pecho', 'Espalda', 'Pierna', 'Core', 'Hombro']);
    expect(model.highlightZonesFront, contains(SystemMuscleZone.chest));
    expect(model.highlightZonesBack, contains(SystemMuscleZone.back));
    expect(model.exerciseCards.first.category, 'Full body');
  });

  test('falls back to general activation for unknown focus', () {
    final model = SystemMuscleMapModel.fromWorkoutFocus(
      focus: 'Sesion experimental',
      stageTitle: 'Pre Beginner',
    );

    expect(model.primaryFocus, 'Activacion general');
    expect(model.secondaryFocus, 'Etapa activa: Pre Beginner');
    expect(model.recoveryHint, 'Movilidad y chequeo tecnico');
    expect(model.highlightTags, ['Activacion', 'Core', 'Pierna']);
    expect(
      model.highlightZonesFront,
      [SystemMuscleZone.core, SystemMuscleZone.quadriceps],
    );
    expect(model.highlightZonesBack, [SystemMuscleZone.hamstrings]);
    expect(model.exerciseCards.single.name, 'Activacion base');
    expect(model.exerciseCards.single.category, 'General');
  });
}
