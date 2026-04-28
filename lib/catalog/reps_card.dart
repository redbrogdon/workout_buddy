import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final repsCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['RepsCard']),
    'exercise': S.string(description: 'The name of the workout'),
    'instructions': S.string(
      description: 'A brief description of how one should perform the exercise',
    ),
    'numberOfReps': S.integer(
      description:
          'The number of reps to be done in order to complete this exercise',
    ),
    'repsCompleted': S.integer(
      description:
          'The number of reps that were actually performed by the user.',
    ),
    'isCompleted': S.boolean(
      description:
          'Whether or not the exercise has been completed yet (initial value '
          'is false)',
    ),
    'onComplete': A2uiSchemas.action(
      description:
          'The action performed when the user has completed the exercise. '
          'I will provide the number of reps completed by the users as '
          '"numberOfRepsCompleted".',
    ),
  },
  required: [
    'exercise',
    'instructions',
    'numberOfReps',
    'isCompleted',
    'onComplete',
  ],
);

class RepsCardData {
  final String exercise;
  final String instructions;
  final int numberOfReps;
  final int? repsCompleted;
  final bool isCompleted;
  final JsonMap? onComplete;

  RepsCardData({
    required this.exercise,
    required this.instructions,
    required this.numberOfReps,
    this.repsCompleted,
    required this.isCompleted,
    this.onComplete,
  });

  factory RepsCardData.fromJson(Map<String, Object?> json) {
    try {
      return RepsCardData(
        exercise: json['exercise'] as String,
        instructions: json['instructions'] as String,
        numberOfReps: json['numberOfReps'] as int,
        repsCompleted: json['repsCompleted'] as int?,
        isCompleted: json['isCompleted'] as bool,
        onComplete: json['onComplete'] as JsonMap?,
      );
    } catch (_) {
      throw Exception('Invalid JSON for RepsCardData');
    }
  }
}

final repsCard = CatalogItem(
  name: 'RepsCard',
  dataSchema: repsCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final data = RepsCardData.fromJson(json);

    return RepsCard(
      data: data,
      onCompleted: (reps) async {
        final action = data.onComplete;
        if (action == null) {
          return;
        }
        final event = action['event'] as JsonMap?;
        final name = (event?['name'] as String?) ?? '';
        final JsonMap contextDefinition =
            (event?['context'] as JsonMap?) ?? <String, Object?>{};
        final JsonMap resolvedContext = await resolveContext(
          itemContext.dataContext,
          contextDefinition,
        );
        resolvedContext['numberOfRepsCompleted'] = reps;
        itemContext.dispatchEvent(
          UserActionEvent(
            name: name,
            sourceComponentId: itemContext.id,
            context: resolvedContext,
          ),
        );
      },
    );
  },
);

class RepsCard extends StatefulWidget {
  final RepsCardData data;
  final void Function(int) onCompleted;

  const RepsCard({
    super.key,
    required this.data,
    required this.onCompleted,
  });

  @override
  State<RepsCard> createState() => _RepsCardState();
}

class _RepsCardState extends State<RepsCard> {
  late int repsCompleted;

  @override
  void initState() {
    super.initState();
    repsCompleted = widget.data.numberOfReps;
  }

  @override
  void didUpdateWidget(RepsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data.exercise != widget.data.exercise) {
      repsCompleted = widget.data.numberOfReps;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.data.numberOfReps > 0
        ? repsCompleted / widget.data.numberOfReps
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            widget.data.exercise.toUpperCase(),
            key: const ValueKey('exercise_name'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.data.instructions,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$repsCompleted',
                key: const ValueKey('reps_completed_text'),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 72,
                ),
              ),
              Text(
                ' / ${widget.data.numberOfReps} REPS',
                key: const ValueKey('target_reps'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: theme.colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              IconButton.filledTonal(
                key: const ValueKey('decrement_reps'),
                icon: const Icon(Icons.remove),
                iconSize: 32,
                onPressed: widget.data.isCompleted || repsCompleted <= 0
                    ? null
                    : () => setState(() => repsCompleted--),
              ),
              IconButton.filledTonal(
                key: const ValueKey('increment_reps'),
                icon: const Icon(Icons.add),
                iconSize: 32,
                onPressed: widget.data.isCompleted
                    ? null
                    : () => setState(() => repsCompleted++),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('complete_button'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: widget.data.isCompleted
                  ? null
                  : () => widget.onCompleted(repsCompleted),
              child: const Text(
                'COMPLETE SET',
                style: TextStyle(letterSpacing: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
