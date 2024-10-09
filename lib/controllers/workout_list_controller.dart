import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/workout.dart';
import 'dart:async';

class WorkoutListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Workouts collection as a map of workout id to workout
  final RxMap<String, Workout> _workouts = <String, Workout>{}.obs;
  Rxn<Workout> selectedWorkout = Rxn<Workout>();

  /// Subscription to the workouts collection
  StreamSubscription<QuerySnapshot>? _workoutsSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToWorkoutsCollection();
  }

  /// Subscribe to the Firestore workouts collection and handle changes
  void _subscribeToWorkoutsCollection() {
    try {
      _workoutsSubscription =
          _firestore.collection('workouts').snapshots().listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          if (docChange.type == DocumentChangeType.added ||
              docChange.type == DocumentChangeType.modified) {
            Workout workout = Workout.fromFirestore(docChange.doc);
            _workouts[docChange.doc.id] = workout;
          } else if (docChange.type == DocumentChangeType.removed) {
            _workouts.remove(docChange.doc.id);
          }
        }

        var sortedWorkouts = Map.fromEntries(_workouts.entries.toList()
          ..sort((a, b) => b.value.date.compareTo(a.value.date)));

        // Update the original map
        _workouts.assignAll(sortedWorkouts);
        // Notify observers
        _workouts.refresh();
      });
    } catch (e) {
      print('Error subscribing to workouts collection: $e');
    }
  }

  /// Delete a workout by ID from Firestore
  Future<void> deleteWorkout(String? workoutId) async {
    try {
      await _firestore.collection('workouts').doc(workoutId).delete();
    } catch (e) {
      print('Error deleting workout: $e');
    }
  }

  Future<void> createNewWorkout(String workoutName, String sessionType) async {
    try {
      DocumentReference docRef = await _firestore.collection('workouts').add(
            Workout(
              id: '',
              name:
                  workoutName.isEmpty ? 'My $sessionType Workout' : workoutName,
              date: DateTime.now(),
              exercises: List.empty(),
              sessionType: sessionType,
            ).toJson(),
          );
      // Wait for the new workout to be available in _workouts
      await Future.delayed(const Duration(milliseconds: 500));
      selectedWorkout.value = _workouts[docRef.id];
    } catch (e) {
      print('Error creating new workout: $e');
    }
  }

  /// Get the current list of workouts
  Map<String, Workout> get workouts => _workouts;

  @override
  void dispose() {
    super.dispose();
    _workoutsSubscription?.cancel();
  }
}
