import 'package:flutter/material.dart';
import '../models/workout_exercise.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import 'slide_to_confirm.dart';

class ExerciseWidget extends StatefulWidget {
  final int exerciseIndex;
  final WorkoutExercise exercise;
  final List<WorkoutExercise> exercises;
  final bool isExpanded;
  final VoidCallback onExpand;
  final String sessionType; 
  final Function(List<WorkoutExercise> exercises) updateWorkoutField;

  const ExerciseWidget({
    super.key,
    required this.exerciseIndex,
    required this.exercise,
    required this.exercises,
    required this.isExpanded,
    required this.onExpand,
    required this.sessionType, 
    required this.updateWorkoutField,
  });

  @override
  ExerciseWidgetState createState() => ExerciseWidgetState();
}

class ExerciseWidgetState extends State<ExerciseWidget> {
  bool isEditing = false;
  bool showConfirmDelete = false;
  late Exercise selectedExercise; 

  @override
  void initState() {
    super.initState();
    if (widget.exercise.exercise == null) {
      selectedExercise = _getFilteredExercises()
          .first; 
    } else {
      selectedExercise =
          widget.exercise.exercise!; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final exerciseIndex = widget.exerciseIndex;

    if (!widget.isExpanded) {
      // Summary View
      return GestureDetector(
        onTap: () {
          widget.onExpand();
        },
        child: Card(
          elevation: 2,
          child: ListTile(
            title: Text(exercise.exercise != null
                ? exercise.exercise.toString()
                : 'Not Selected'),
            subtitle: Text(
                '${exercise.sets.length} sets • Max weight: ${_getMaxWeight()} kg'),
          ),
        ),
      );
    }

    // Expanded View
    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showConfirmDelete
              ? _buildSlideToDelete()
              : ListTile(
                  title: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select Exercise',
                      border: InputBorder.none,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.7,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Exercise>(
                          value: exercise.exercise,
                          isExpanded:
                              true,
                          icon: const Icon(Icons.arrow_drop_down,
                              color:
                                  Colors.black),
                          iconSize: 30, 
                          onChanged: (Exercise? newValue) {
                            if (newValue != null) {
                              widget.exercises[exerciseIndex] =
                                  exercise.copyWith(exercise: newValue);
                              widget.updateWorkoutField(widget.exercises);
                            }
                          },
                          items: _getFilteredExercises()
                              .map<DropdownMenuItem<Exercise>>(
                                  (Exercise value) {
                            return DropdownMenuItem<Exercise>(
                              value: value,
                              child: Text(
                                value.toString(),
                                style: const TextStyle(
                                  fontSize: 16, 
                                  color: Colors.black, 
                                ),
                              ),
                            );
                          }).toList(),
                          dropdownColor: Colors
                              .white, 
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              showConfirmDelete = true;
                            });
                          },
                        ),
                      IconButton(
                        icon: Icon(isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          setState(() {
                            if (isEditing && exercise.sets.isEmpty) {
                              widget.exercises.removeAt(exerciseIndex);
                              widget.updateWorkoutField(widget.exercises);
                            }
                            isEditing = !isEditing;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.expand_less),
                        onPressed: () {
                          widget.onExpand();
                        },
                      ),
                    ],
                  ),
                ),
          if (!showConfirmDelete) _buildSetsList(exercise),
          _buildAddSetButton(context, exercise),
        ],
      ),
    );
  }

  double _getMaxWeight() {
    if (widget.exercise.sets.isEmpty) return 0.0;
    return widget.exercise.sets
        .map((set) => set.weight)
        .reduce((value, element) => element > value ? element : value);
  }

  Widget _buildSlideToDelete() {
    return SlideToConfirm(
      message: "Slide to Confirm Deletion",
      onConfirmed: () {
        widget.exercises.removeAt(widget.exerciseIndex);
        widget.updateWorkoutField(widget.exercises);
        setState(() {
          showConfirmDelete =
              false; 
        });
      },
    );
  }

  Widget _buildSetsList(WorkoutExercise exercise) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: exercise.sets.asMap().entries.map((setEntry) {
        int setIndex = setEntry.key;
        Set set = setEntry.value;
        return ListTile(
          title: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: set.weight.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  onChanged: (value) {
                    double weight = double.tryParse(value) ?? 0.0;
                    exercise.sets[setIndex] = set.copyWith(weight: weight);
                    widget.updateWorkoutField(widget.exercises);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: set.repetitions.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Repetitions'),
                  onChanged: (value) {
                    int repetitions = int.tryParse(value) ?? 0;
                    exercise.sets[setIndex] =
                        set.copyWith(repetitions: repetitions);
                    widget.updateWorkoutField(widget.exercises);
                  },
                ),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      exercise.sets.removeAt(setIndex);
                      widget.updateWorkoutField(widget.exercises);
                    });
                  },
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddSetButton(BuildContext context, WorkoutExercise exercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        Expanded(
          child: InkWell(
            onTap: () {
              exercise.sets.add(Set(weight: 0.0, repetitions: 0));
              widget.updateWorkoutField(widget.exercises);
            },
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.add, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text('Add Set',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }

  List<Exercise> _getFilteredExercises() {
    List<Exercise> filteredExercises = Exercise.values
        .where((exercise) => exercise.category
            .toString()
            .toLowerCase()
            .contains(widget.sessionType.toLowerCase()))
        .toList();

    if (widget.exercise.exercise != null &&
        !filteredExercises.contains(widget.exercise.exercise)) {
      filteredExercises.add(widget.exercise.exercise!);
    }

    return filteredExercises;
  }
}
