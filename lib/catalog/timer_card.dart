import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final timerCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['TimerCard']),
    'exercise': S.string(description: 'The name of the workout'),
    'instructions': S.string(
      description: 'A brief description of how one should perform the exercise',
    ),
    'suggestedDuration': S.integer(
      description: 'The suggested duration, in seconds, for this exercise',
    ),
    'actualDuration': S.integer(
      description:
          'The duration, in seconds, for which this exercise was performed '
          'by the user',
    ),
    'isCompleted': S.boolean(
      description:
          'Whether or not the exercise has been completed yet (initial value '
          'is false)',
    ),
    'onComplete': A2uiSchemas.action(
      description:
          'The action performed when the user has completed the exercise. '
          'I will provide the duration the user performed the exercise as '
          '"actualDuration".',
    ),
  },
  required: [
    'exercise',
    'instructions',
    'suggestedDuration',
    'actualDuration',
    'isCompleted',
    'onComplete',
  ],
);

class TimerCardData {
  final String exercise;
  final String instructions;
  final int suggestedDuration;
  final int actualDuration;
  final bool isCompleted;
  final JsonMap? onComplete;

  TimerCardData({
    required this.exercise,
    required this.instructions,
    required this.suggestedDuration,
    required this.actualDuration,
    required this.isCompleted,
    this.onComplete,
  });

  factory TimerCardData.fromJson(Map<String, Object?> json) {
    try {
      return TimerCardData(
        exercise: json['exercise'] as String,
        instructions: json['instructions'] as String,
        suggestedDuration: json['suggestedDuration'] as int,
        actualDuration: json['actualDuration'] as int,
        isCompleted: json['isCompleted'] as bool,
        onComplete: json['onComplete'] as JsonMap?,
      );
    } catch (_) {
      throw Exception('Invalid JSON for TimerCardData');
    }
  }
}

final timerCard = CatalogItem(
  name: 'TimerCard',
  dataSchema: timerCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final data = TimerCardData.fromJson(json);

    return TimerCard(
      data: data,
      onCompleted: (actualDuration) async {
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
        resolvedContext['actualDuration'] = actualDuration;
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

class TimerCard extends StatefulWidget {
  final TimerCardData data;
  final void Function(int) onCompleted;

  const TimerCard({
    super.key,
    required this.data,
    required this.onCompleted,
  });

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  late int actualDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    actualDuration = widget.data.actualDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data.exercise != widget.data.exercise) {
      _timer?.cancel();
      actualDuration = widget.data.actualDuration;
    }
  }

  void _toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          actualDuration++;
        });
      });
    }
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      actualDuration = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.data.suggestedDuration > 0
        ? actualDuration / widget.data.suggestedDuration
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
            key: const ValueKey('instructions'),
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
                '$actualDuration',
                key: const ValueKey('actual_duration'),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 72,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ' / ${widget.data.suggestedDuration} SEC',
                key: const ValueKey('suggested_duration'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
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
                key: const ValueKey('reset_timer'),
                icon: const Icon(Icons.refresh),
                iconSize: 32,
                onPressed: widget.data.isCompleted ? null : _resetTimer,
              ),
              IconButton.filled(
                key: const ValueKey('toggle_timer'),
                icon: Icon(
                  (_timer?.isActive ?? false) ? Icons.pause : Icons.play_arrow,
                ),
                iconSize: 32,
                onPressed: widget.data.isCompleted ? null : _toggleTimer,
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
                  : () {
                      _timer?.cancel();
                      widget.onCompleted(actualDuration);
                    },
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
