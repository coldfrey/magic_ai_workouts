import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_ai/models/exercise.dart';
import 'package:magic_ai/widgets/exercise_widget.dart';
import 'package:magic_ai/models/workout_exercise.dart';
import 'package:magic_ai/models/set.dart';

final testExercise = WorkoutExercise(
  exercise: Exercise.squat,
  sets: [
    Set(
      weight: 100.0,
      repetitions: 5,
    ),
    Set(
      weight: 110.0,
      repetitions: 5,
    ),
  ],
);

void deleteSet(int index) {
  testExercise.sets.removeAt(index);
}

void main() {
  testWidgets('ExerciseWidget displays exercise name, sets and max weight',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ExerciseWidget(
          exerciseIndex: 0,
          exercise: testExercise,
          exercises: [testExercise],
          isExpanded: false,
          onExpand: () {},
          sessionType: 'legs',
          updateWorkoutField: (List<WorkoutExercise> exercises) {
            // do nothing
          }),
    ));

    expect(find.text('squat'), findsOneWidget);
    expect(find.text('2 sets • Max weight: 110.0 kg'), findsOneWidget);
  });
}
