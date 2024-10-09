enum ExerciseCategory { pull, push, legs }

enum Exercise {
  // Pull Exercises
  pullUp(ExerciseCategory.pull),
  chinUp(ExerciseCategory.pull),
  barbellRow(ExerciseCategory.pull),
  dumbbellRow(ExerciseCategory.pull),
  latPulldown(ExerciseCategory.pull),
  facePull(ExerciseCategory.pull),
  seatedRow(ExerciseCategory.pull),

  // Push Exercises
  benchPress(ExerciseCategory.push),
  overheadPress(ExerciseCategory.push),
  pushUp(ExerciseCategory.push),
  dumbbellPress(ExerciseCategory.push),
  tricepDip(ExerciseCategory.push),
  inclineBenchPress(ExerciseCategory.push),

  // Leg Exercises
  squat(ExerciseCategory.legs),
  deadlift(ExerciseCategory.legs),
  legPress(ExerciseCategory.legs),
  lunge(ExerciseCategory.legs),
  legExtension(ExerciseCategory.legs),
  legCurl(ExerciseCategory.legs),
  calfRaise(ExerciseCategory.legs);

  final ExerciseCategory category;

  const Exercise(this.category);

  @override
  String toString() {
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
  }
}
