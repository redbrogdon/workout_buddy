import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final workoutCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['WorkoutCard']),
    'title': S.string(description: 'The title of the workout'),
    'description': S.string(
      description: 'A brief overview or motivation for the workout.',
    ),
    'exercises': S.list(
      description: 'A list of 3-5 exercises to perform as part of the workout',
      items: S.string(
        description:
            'The type of exercise to perform, including name and details '
            'like the amount of reps.',
        minLength: 3,
      ),
      minItems: 3,
      maxItems: 5,
    ),
    'onStart': A2uiSchemas.action(
      description: 'Action to trigger when starting the workout',
    ),
  },
  required: ['title', 'exercises'],
);

class WorkoutCardData {
  final String title;
  final String? description;
  final List<String> exercises;

  WorkoutCardData({
    required this.title,
    this.description,
    required this.exercises,
  });

  factory WorkoutCardData.fromJson(Map<String, Object?> json) {
    try {
      return WorkoutCardData(
        title: json['title'] as String,
        description: json['description'] as String?,
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

    final onStart = json['onStart'];
    return WorkoutCard(
      data: data,
      onStart: onStart != null
          ? () {
              final eventJson = onStart as Map<String, dynamic>;
              if (eventJson.containsKey('event')) {
                final eventData = eventJson['event'] as Map<String, dynamic>;
                itemContext.dispatchEvent(
                  UserActionEvent(
                    name: eventData['name'] as String,
                    context: (eventData['context'] as Map?)
                        ?.cast<String, dynamic>(),
                    sourceComponentId: itemContext.id,
                    surfaceId: itemContext.surfaceId,
                  ),
                );
              }
            }
          : null,
    );
  },
);

class WorkoutCard extends StatelessWidget {
  final WorkoutCardData data;
  final VoidCallback? onStart;

  const WorkoutCard({super.key, required this.data, this.onStart});

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
          if (data.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                data.description!,
                key: const ValueKey('workout_description'),
                style: theme.textTheme.bodyMedium,
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
          if (onStart != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Workout'),
              ),
            ),
        ],
      ),
    );
  }
}
