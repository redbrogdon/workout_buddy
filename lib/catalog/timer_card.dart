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
  final int? actualDuration;
  final bool isCompleted;
  final JsonMap? completeAction;

  _TimerCardData({
    required this.exercise,
    required this.instructions,
    required this.suggestedDuration,
    this.actualDuration,
    required this.isCompleted,
    this.completeAction,
  });

  factory _TimerCardData.fromJson(Map<String, Object?> json) {
    try {
      return _TimerCardData(
        exercise: json['exercise'] as String,
        instructions: json['instructions'] as String,
        suggestedDuration: json['suggestedDuration'] as int,
        actualDuration: json['actualDuration'] as int?,
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
      onCompleted: (duration) async {
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
        resolvedContext['actualDuration'] = duration;
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

  @override
  void initState() {
    super.initState();
    actualDuration = widget.data.suggestedDuration;
  }

  @override
  void didUpdateWidget(_TimerCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data.exercise != widget.data.exercise) {
      actualDuration = widget.data.suggestedDuration;
    }
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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Suggested: ${widget.data.suggestedDuration}s',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 8,
              children: [
                const Text('Duration (s):'),
                Text('$actualDuration'),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => setState(() => actualDuration++),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => setState(() => actualDuration--),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => widget.onCompleted(actualDuration),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
