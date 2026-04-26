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
              widget.data.exercise,
              key: const ValueKey('exercise_name'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.data.instructions,
              key: const ValueKey('instructions'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suggested Duration: ${widget.data.suggestedDuration}s',
              key: const ValueKey('suggested_duration'),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 8,
              children: [
                const Text('Actual Duration:'),
                Text(
                  '${actualDuration}s',
                  key: const ValueKey('actual_duration'),
                ),
                IconButton(
                  key: const ValueKey('toggle_timer'),
                  icon: Icon(
                    (_timer?.isActive ?? false)
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: widget.data.isCompleted ? null : _toggleTimer,
                ),
                IconButton(
                  key: const ValueKey('reset_timer'),
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.data.isCompleted ? null : _resetTimer,
                ),
                IconButton(
                  key: const ValueKey('complete_button'),
                  icon: const Icon(Icons.check),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () {
                          _timer?.cancel();
                          widget.onCompleted(actualDuration);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
