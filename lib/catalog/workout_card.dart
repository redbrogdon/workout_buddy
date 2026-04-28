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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  key: const ValueKey('workout_title'),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (data.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.description!,
                    key: const ValueKey('workout_description'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Exercise List
          ...data.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _buildExerciseCard(context, index, exercise);
          }),

          if (onStart != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
                child: const Text(
                  'START WORKOUT',
                  style: TextStyle(letterSpacing: 2.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, int index, String exercise) {
    final theme = Theme.of(context);

    // Extract name vs details if formatted like "Pushups (3 sets of 10)"
    final parts = exercise.split(RegExp(r'\(|:|-'));
    final name = parts[0].trim().toUpperCase();
    final details = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll(')', '').trim()
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXERCISE ${index + 1 < 10 ? '0${index + 1}' : index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (details.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                details,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
