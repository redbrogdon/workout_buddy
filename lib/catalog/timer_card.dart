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
    'completeAction': A2uiSchemas.action(
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
    'completeAction',
  ],
);

class _TimerCardData {
  final String exercise;
  final String instructions;
  final int suggestedDuration;
  final int actualDuration;
  final bool isCompleted;
  final JsonMap? completeAction;

  _TimerCardData({
    required this.exercise,
    required this.instructions,
    required this.suggestedDuration,
    required this.actualDuration,
    required this.isCompleted,
    this.completeAction,
  });

  factory _TimerCardData.fromJson(Map<String, Object?> json) {
    try {
      return _TimerCardData(
        exercise: json['exercise'] as String,
        instructions: json['instructions'] as String,
        suggestedDuration: json['suggestedDuration'] as int,
        actualDuration: json['actualDuration'] as int,
        isCompleted: json['isCompleted'] as bool,
        completeAction: json['completeAction'] as JsonMap?,
      );
    } catch (_) {
      throw Exception('Invalid JSON for _TimerCardData');
    }
  }
}

final timerCard = CatalogItem(
  name: 'TimerCard',
  dataSchema: timerCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final data = _TimerCardData.fromJson(json);

    return _TimerCard(
      data: data,
      onCompleted: (actualDuration) async {
        final action = data.completeAction;
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

class _TimerCard extends StatefulWidget {
  final _TimerCardData data;
  final void Function(int) onCompleted;

  const _TimerCard({
    required this.data,
    required this.onCompleted,
  });

  @override
  State<_TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<_TimerCard> {
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
  void didUpdateWidget(_TimerCard oldWidget) {
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.data.instructions,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suggested Duration: ${widget.data.suggestedDuration}s',
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
                Text('${actualDuration}s'),
                IconButton(
                  icon: Icon(
                    (_timer?.isActive ?? false)
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: widget.data.isCompleted ? null : _toggleTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.data.isCompleted ? null : _resetTimer,
                ),
                IconButton(
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
