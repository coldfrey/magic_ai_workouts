import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:magic_ai/views/workout_input.dart';
import 'package:magic_ai/widgets/new_workout.dart';
import 'package:magic_ai/widgets/slide_to_confirm.dart';
import '../controllers/workout_list_controller.dart';

class WorkoutListView extends StatefulWidget {
  const WorkoutListView({super.key});

  @override
  _WorkoutListViewState createState() => _WorkoutListViewState();
}

class _WorkoutListViewState extends State<WorkoutListView> {
  final WorkoutListController workoutListController =
      Get.put(WorkoutListController());

  int? deletingWorkoutIndex;
  bool showDeleteIcons = false;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  final ScrollController _monthsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the current month after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // double monthWidth = 80.0 + 16.0; // Width + horizontal margin
      // double scrollTo = (selectedMonth - 1) * monthWidth;
      // _monthsScrollController.animateTo(
      //   scrollTo,
      //   duration: Duration(milliseconds: 1000),
      //   curve: Curves.easeInOut,
      // );
      scrollToMonth(selectedMonth);
    });
  }

  void scrollToMonth(int month) {
    double monthWidth = 80.0 + 16.0; // Width + horizontal margin
    double scrollTo = (month - 1) * monthWidth;
    _monthsScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _monthsScrollController.dispose();
    super.dispose();
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }
    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }
    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  Widget build(BuildContext context) {
    workoutListController.selectedWorkout.value = null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
            scrollToMonth(DateTime.now().month);
            setState(() {
              selectedYear = DateTime.now().year;
              selectedMonth = DateTime.now().month;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Workouts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Delete Workouts') {
                setState(() {
                  showDeleteIcons = true;
                });
              } else if (value == 'Exit Delete Mode') {
                setState(() {
                  showDeleteIcons = false;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value:
                      showDeleteIcons ? 'Exit Delete Mode' : 'Delete Workouts',
                  child: Text(
                      showDeleteIcons ? 'Exit Delete Mode' : 'Delete Workouts'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Year Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<int>(
              value: selectedYear,
              onChanged: (int? newValue) {
                setState(() {
                  selectedYear = newValue!;
                });
              },
              items: List.generate(5, (index) => DateTime.now().year - index)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Months Carousel
          SizedBox(
            height: 60,
            child: ListView.builder(
              controller: _monthsScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) {
                int month = index + 1;
                bool isSelected = selectedMonth == month;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                  child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('MMM').format(DateTime(selectedYear, month)),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Workouts List
          Expanded(
            child: Obx(() {
              var filteredWorkouts = workoutListController.workouts.values
                  .where((workout) =>
                      workout.date.year == selectedYear &&
                      workout.date.month == selectedMonth)
                  .toList();

              if (filteredWorkouts.isEmpty) {
                return const Center(
                    child: Text('No workouts recorded for this month.'));
              }

              return ListView.builder(
                itemCount: filteredWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = filteredWorkouts[index];

                  // Check if the current workout is being deleted
                  if (deletingWorkoutIndex == index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SlideToConfirm(
                        message: "Slide to Confirm Deletion",
                        onConfirmed: () async {
                          await workoutListController.deleteWorkout(workout.id);
                          setState(() {
                            deletingWorkoutIndex = null;
                            // Optionally exit delete mode
                            // showDeleteIcons = false;
                          });
                        },
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        workout.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${workout.exercises.length} Exercises'),
                      trailing: showDeleteIcons
                          ? IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  deletingWorkoutIndex = index;
                                });
                              },
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${DateFormat('EEEE').format(workout.date)}, ${workout.date.day}${getDayOfMonthSuffix(workout.date.day)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutInput(workoutId: workout.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show the popup to rename workout and choose session type
          var result = await showWorkoutCreationDialog(context);
          if (result != null) {
            String workoutName = result[0];
            String sessionType = result[1];

            // Create the new workout
            await workoutListController.createNewWorkout(
                workoutName, sessionType);
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutInput(
                    workoutId: workoutListController.selectedWorkout.value!
                        .id, // Pass the selected session type
                  ),
                ),
              );
            }
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
