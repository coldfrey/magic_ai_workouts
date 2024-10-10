import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_ai/widgets/exercise_widget.dart';
import '../controllers/workout_input_controller.dart';
import '../models/workout_exercise.dart';

class WorkoutInput extends StatefulWidget {
  final String workoutId;

  const WorkoutInput({super.key, required this.workoutId});

  @override
  WorkoutInputState createState() => WorkoutInputState();
}

class WorkoutInputState extends State<WorkoutInput> {
  late final WorkoutViewController workoutViewController;
  bool isEditingName = false;
  final FocusNode _nameFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();

  int? expandedExerciseIndex; // Holds the index of the expanded exercise

  @override
  void initState() {
    super.initState();
    workoutViewController =
        Get.put(WorkoutViewController(workoutId: widget.workoutId));
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus && isEditingName) {
        workoutViewController.updateWorkoutField(name: _nameController.text);
        setState(() {
          isEditingName = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _nameController.dispose();
    // Delete the controller when the view is disposed
    Get.delete<WorkoutViewController>(tag: widget.workoutId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    workoutViewController.subscribeToWorkout(widget.workoutId);
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (workoutViewController.workout == null) {
            return const Text('Workout');
          }

          if (isEditingName) {
            return TextField(
              focusNode: _nameFocusNode,
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Workout Name',
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                setState(() {
                  isEditingName = true;
                  _nameController.text = workoutViewController.workout!.name;
                  _nameFocusNode.requestFocus();
                });
              },
              child: Text(workoutViewController.workout!.name),
            );
          }
        }),
      ),
      body: Obx(() {
        if (workoutViewController.workout == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final workout = workoutViewController.workout!;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // Collapse all expanded exercises when tapping outside
            setState(() {
              expandedExerciseIndex = null;
            });
          },
          child: ListView(
            children: [
              ListTile(
                title: Text(
                    'Date: ${workout.date.toLocal().toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: workout.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      workoutViewController.updateWorkoutField(
                          date: pickedDate);
                    }
                  },
                ),
              ),
              // Map over exercises and pass expanded state
              ...workout.exercises.asMap().entries.map((entry) {
                int exerciseIndex = entry.key;
                WorkoutExercise exercise = entry.value;

                bool isExpanded = expandedExerciseIndex == exerciseIndex;

                return ExerciseWidget(
                  exerciseIndex: exerciseIndex,
                  exercise: exercise,
                  // workoutViewController: workoutViewController,
                  updateWorkoutField: (List<WorkoutExercise> exercises) {
                    workoutViewController.updateWorkoutField(
                        exercises: exercises);
                  },
                  exercises: workout.exercises,
                  isExpanded: isExpanded,
                  sessionType: workout.sessionType,
                  onExpand: () {
                    setState(() {
                      if (expandedExerciseIndex == exerciseIndex) {
                        // Collapse if already expanded
                        expandedExerciseIndex = null;
                      } else {
                        // Expand the selected exercise
                        expandedExerciseIndex = exerciseIndex;
                      }
                    });
                  },
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new exercise
          final workout = workoutViewController.workout!;
          workout.exercises.add(
            WorkoutExercise(
              exercise: null,
              sets: [],
            ),
          );
          workoutViewController.updateWorkoutField(
              exercises: workout.exercises);
          setState(() {
            // Expand the new exercise and collapse others
            expandedExerciseIndex = workout.exercises.length - 1;
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
