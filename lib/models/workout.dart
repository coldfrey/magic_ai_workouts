import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'workout_exercise.dart';

part 'workout.g.dart';

@JsonSerializable(explicitToJson: true)
class Workout {
  final String id;
  final String name;
  final DateTime date;
  final List<WorkoutExercise> exercises;
  final String sessionType;

  Workout({
    required this.id,
    this.name = 'New Workout',
    required this.date,
    required this.exercises,
    required this.sessionType,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'],
      date: (json['date'] as Timestamp).toDate(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((exercise) =>
                  WorkoutExercise.fromJson(exercise as Map<String, dynamic>))
              .toList() ??
          [],
      sessionType: json['sessionType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'sessionType': sessionType,
    };
  }

  factory Workout.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Workout.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<WorkoutExercise>? exercises,
    String? sessionType,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}
