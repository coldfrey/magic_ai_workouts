import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/workout_exercise.dart';
import '../models/workout.dart';
import 'dart:async';

class WorkoutViewController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String workoutId;

  /// Holds the current workout being edited or viewed
  final Rx<Workout?> _workout = Rx<Workout?>(null);

  /// Subscription to the workout document
  StreamSubscription<DocumentSnapshot>? _workoutSubscription;

  Workout? get workout => _workout.value;

  WorkoutViewController({required this.workoutId});

  /// Initialize the controller by subscribing to the workout document
  void subscribeToWorkout(String workoutId) {
    print('Subscribing to workout: $workoutId');
    _workoutSubscription?.cancel();
    _workoutSubscription = _firestore
        .collection('workouts')
        .doc(workoutId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _workout.value = Workout.fromFirestore(doc);
      } else {
        _workout.value = null;
      }
    }, onError: (e) {
      print('Error subscribing to workout: $e');
    });
  }

  /// Save the workout to Firestore, either creating a new document or updating an existing one
  Future<void> saveWorkout(Workout workout) async {
    try {
      if (workout.id.isEmpty) {
        // Create a new workout
        DocumentReference newDoc =
            await _firestore.collection('workouts').add(workout.toJson());
        _workout.value = workout.copyWith(id: newDoc.id);
      } else {
        // Update existing workout
        await _firestore
            .collection('workouts')
            .doc(workout.id)
            .update(workout.toJson());
      }
    } catch (e) {
      print('Error saving workout: $e');
    }
  }

  /// Manually update a field in the current workout
  void updateWorkoutField({
    String? id,
    String? name,
    DateTime? date,
    List<WorkoutExercise>? exercises,
  }) {
    if (_workout.value != null) {
      _workout.value = _workout.value!.copyWith(
        id: id,
        name: name,
        date: date,
        exercises: exercises,
      );
      saveWorkout(_workout.value!);
    }
  }

  /// Get the current workout
  Workout? get currentWorkout => _workout.value;

  @override
  void onClose() {
    print('WorkoutViewController for workoutId $workoutId is being closed.');
    _workoutSubscription?.cancel();
    super.onClose();
  }
}
