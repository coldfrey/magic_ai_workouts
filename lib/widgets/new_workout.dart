import 'package:flutter/material.dart';

Future<List<String>?> showWorkoutCreationDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  String selectedType = ''; // No default selection
  bool nameVisible = false; // Controls whether the name input is visible

  final sessionTypes = ['Legs', 'Push', 'Pull'];

  return await showDialog<List<String>>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Center(
              child: Text(
                'Create New Workout',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Session Type Selection Buttons
                  if (!nameVisible)
                    Column(
                      children: sessionTypes.map((type) {
                        bool isSelected = selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = type;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        const BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Optional: Add an icon for each type
                                  Icon(
                                    type == 'Legs'
                                        ? Icons.directions_walk
                                        : type == 'Push'
                                            ? Icons.fitness_center
                                            : Icons.arrow_upward,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    type,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // Name Input Field
                  if (nameVisible)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Workout Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel Button (visible only when nameVisible is true)
                  if (nameVisible)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(), // Placeholder to keep alignment

                  // Next or Create Button
                  TextButton(
                    onPressed: () {
                      if (!nameVisible) {
                        if (selectedType.isEmpty) {
                          // Show a message if no session type is selected
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a session type.'),
                            ),
                          );
                        } else {
                          // Set default name based on selected session type
                          if (nameController.text.isEmpty) {
                            nameController.text = '$selectedType Session';
                          }
                          setState(() {
                            nameVisible = true; // Show the name field
                          });
                        }
                      } else {
                        Navigator.of(context).pop(
                          [nameController.text, selectedType],
                        ); // Return the name and type
                      }
                    },
                    child: Text(
                      nameVisible ? 'Create' : 'Next',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
