import 'package:flutter/material.dart';

Future<List<String>?> showWorkoutCreationDialog(BuildContext context) async {
  TextEditingController nameController = TextEditingController();
  String selectedType = '';
  bool nameVisible = false; 

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
                  if (nameVisible)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                  TextButton(
                    onPressed: () {
                      if (!nameVisible) {
                        if (selectedType.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a session type.'),
                            ),
                          );
                        } else {
                          if (nameController.text.isEmpty) {
                            nameController.text = '$selectedType Session';
                          }
                          setState(() {
                            nameVisible = true; 
                          });
                        }
                      } else {
                        Navigator.of(context).pop(
                          [nameController.text, selectedType],
                        ); 
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
