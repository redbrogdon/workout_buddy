import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final exerciseTileSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['ExerciseTile']),
    'name': S.string(description: 'The name of the exercise'),
    'sets': S.integer(description: 'The number of sets to perform'),
    'repetitions': S.integer(description: 'The number of repetitions per set'),
    'duration': S.integer(description: 'Duration in seconds if timed'),
    'deleteAction': A2uiSchemas.action(
      description: 'Action to delete this exercise from the plan',
    ),
    'replaceAction': A2uiSchemas.action(
      description: 'Action to replace this exercise with a different one',
    ),
  },
  required: ['name'],
);

class ExerciseTileData {
  final String name;
  final int? sets;
  final int? repetitions;
  final int? duration;
  final JsonMap? deleteAction;
  final JsonMap? replaceAction;

  ExerciseTileData({
    required this.name,
    this.sets,
    this.repetitions,
    this.duration,
    this.deleteAction,
    this.replaceAction,
  });

  factory ExerciseTileData.fromJson(Map<String, Object?> json) {
    return ExerciseTileData(
      name: json['name'] as String,
      sets: json['sets'] as int?,
      repetitions: json['repetitions'] as int?,
      duration: json['duration'] as int?,
      deleteAction: json['deleteAction'] as JsonMap?,
      replaceAction: json['replaceAction'] as JsonMap?,
    );
  }
}

final exerciseTile = CatalogItem(
  name: 'ExerciseTile',
  dataSchema: exerciseTileSchema,
  widgetBuilder: (itemContext) {
    final data = ExerciseTileData.fromJson(
      itemContext.data as Map<String, Object?>,
    );

    return ExerciseTile(
      data: data,
      onDelete: () async {
        if (data.deleteAction != null) {
          final event = data.deleteAction!['event'] as JsonMap?;
          itemContext.dispatchEvent(
            UserActionEvent(
              name: (event?['name'] as String?) ?? 'delete_exercise',
              sourceComponentId: itemContext.id,
              context: (event?['context'] as JsonMap?) ?? {},
            ),
          );
        }
      },
      onReplace: () async {
        if (data.replaceAction != null) {
          final event = data.replaceAction!['event'] as JsonMap?;
          itemContext.dispatchEvent(
            UserActionEvent(
              name: (event?['name'] as String?) ?? 'replace_exercise',
              sourceComponentId: itemContext.id,
              context: (event?['context'] as JsonMap?) ?? {},
            ),
          );
        }
      },
    );
  },
);

class ExerciseTile extends StatelessWidget {
  final ExerciseTileData data;
  final VoidCallback onDelete;
  final VoidCallback onReplace;

  const ExerciseTile({
    super.key,
    required this.data,
    required this.onDelete,
    required this.onReplace,
  });

  String _getImageForExercise(String exerciseName) {
    final name = exerciseName.toLowerCase();
    if (name.contains('push')) return 'assets/images/pushup.png';
    if (name.contains('squat')) return 'assets/images/squat.png';
    if (name.contains('plank')) return 'assets/images/plank.png';
    return 'assets/images/pushup.png'; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = _getImageForExercise(data.name);

    String subtitle = '';
    if (data.sets != null) subtitle += '${data.sets} sets ';
    if (data.repetitions != null) subtitle += 'of ${data.repetitions} reps';
    if (data.duration != null) subtitle += 'for ${data.duration}s';
    subtitle = subtitle.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      height: 140,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4.0),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.surface.withValues(alpha: 0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name.toUpperCase(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      color: theme.colorScheme.primary,
                      onPressed: onReplace,
                      tooltip: 'Replace',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: theme.colorScheme.error,
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
