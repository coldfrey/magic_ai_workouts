import 'package:json_annotation/json_annotation.dart';
import 'exercise.dart';

class ExerciseConverter implements JsonConverter<Exercise, String> {
  const ExerciseConverter();

  @override
  Exercise fromJson(String json) {
    return Exercise.values.firstWhere((e) => e.name == json);
  }

  @override
  String toJson(Exercise object) {
    return object.name;
  }
}
