import 'package:json_annotation/json_annotation.dart';
import 'exercise.dart';
import 'set.dart';
import 'exercise_converter.dart';

part 'workout_exercise.g.dart';

@JsonSerializable(explicitToJson: true)
class WorkoutExercise {
  @ExerciseConverter()
  Exercise? exercise;
  final List<Set> sets;

  WorkoutExercise({
    this.exercise,
    required this.sets,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutExerciseToJson(this);

  WorkoutExercise copyWith({
    Exercise? exercise,
    List<Set>? sets,
  }) {
    return WorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
    );
  }
}
