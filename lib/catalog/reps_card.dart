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
    'completeAction': A2uiSchemas.action(
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
    'completeAction',
  ],
);

class _RepsCardData {
  final String exercise;
  final String instructions;
  final int numberOfReps;
  final int? repsCompleted;
  final bool isCompleted;
  final JsonMap? completeAction;

  _RepsCardData({
    required this.exercise,
    required this.instructions,
    required this.numberOfReps,
    this.repsCompleted,
    required this.isCompleted,
    this.completeAction,
  });

  factory _RepsCardData.fromJson(Map<String, Object?> json) {
    try {
      return _RepsCardData(
        exercise: json['exercise'] as String,
        instructions: json['instructions'] as String,
        numberOfReps: json['numberOfReps'] as int,
        repsCompleted: json['repsCompleted'] as int?,
        isCompleted: json['isCompleted'] as bool,
        completeAction: json['completeAction'] as JsonMap?,
      );
    } catch (_) {
      throw Exception('Invalid JSON for _RepsCardData');
    }
  }
}

final repsCard = CatalogItem(
  name: 'RepsCard',
  dataSchema: repsCardSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final data = _RepsCardData.fromJson(json);

    return _RepsCard(
      data: data,
      onCompleted: (reps) async {
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

class _RepsCard extends StatefulWidget {
  final _RepsCardData data;
  final void Function(int) onCompleted;

  const _RepsCard({
    required this.data,
    required this.onCompleted,
  });

  @override
  State<_RepsCard> createState() => _RepsCardState();
}

class _RepsCardState extends State<_RepsCard> {
  late int repsCompleted;

  @override
  void initState() {
    super.initState();
    repsCompleted = widget.data.numberOfReps;
  }

  @override
  void didUpdateWidget(_RepsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data.exercise != widget.data.exercise) {
      repsCompleted = widget.data.numberOfReps;
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
              '${widget.data.numberOfReps}',
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              spacing: 8,
              children: [
                const Text('Reps completed:'),
                Text('$repsCompleted'),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => setState(() => repsCompleted++),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => setState(() => repsCompleted--),
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: widget.data.isCompleted
                      ? null
                      : () => widget.onCompleted(repsCompleted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
