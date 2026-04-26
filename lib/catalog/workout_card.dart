import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final workoutCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['WorkoutCard']),
    'title': S.string(description: 'The title of the workout'),
    'exercises': S.list(
      description: 'A list of 3-5 exercises to perform as part of the workout',
      items: S.string(
        description:
            'The type of exercise to perform, including name and details '
            'like the amount of reps. 50 characters max.',
        minLength: 3,
        maxLength: 5,
      ),
    ),
  },
  required: ['title', 'exercises'],
);

class WorkoutCardData {
  final String title;
  final List<String> exercises;

  WorkoutCardData({required this.title, required this.exercises});

  factory WorkoutCardData.fromJson(Map<String, Object?> json) {
    try {
      return WorkoutCardData(
        title: json['title'] as String,
        exercises: List<String>.from(json['exercises'] as List),
      );
    } catch (_) {
      throw Exception('Invalid JSON for WorkoutCardData');
    }
  }
}

final workoutCard = CatalogItem(
  name: 'WorkoutCard',
  dataSchema: workoutCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, dynamic>;
    final data = WorkoutCardData.fromJson(json);

    return WorkoutCard(data: data);
  },
);

class WorkoutCard extends StatelessWidget {
  final WorkoutCardData data;

  const WorkoutCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              data.title,
              key: const ValueKey('workout_title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              key: const ValueKey('exercise_wrap'),
              spacing: 8.0,
              runSpacing: 8.0,
              children: data.exercises
                  .map(
                    (exercise) => Chip(
                      key: ValueKey('exercise_chip_$exercise'),
                      avatar: const Icon(Icons.fitness_center),
                      label: Text(exercise),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
