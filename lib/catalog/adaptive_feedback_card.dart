import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final adaptiveFeedbackCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['AdaptiveFeedbackCard']),
    'exercise': S.string(description: 'The exercise that just completed'),
    'onFeedback': A2uiSchemas.action(
      description:
          'The action dispatched when the user provides feedback. '
          'I will provide the feedback string as "feedback".',
    ),
  },
  required: ['exercise', 'onFeedback'],
);

class AdaptiveFeedbackCardData {
  final String exercise;
  final JsonMap? onFeedback;

  AdaptiveFeedbackCardData({required this.exercise, this.onFeedback});

  factory AdaptiveFeedbackCardData.fromJson(Map<String, Object?> json) {
    return AdaptiveFeedbackCardData(
      exercise: json['exercise'] as String,
      onFeedback: json['onFeedback'] as JsonMap?,
    );
  }
}

final adaptiveFeedbackCard = CatalogItem(
  name: 'AdaptiveFeedbackCard',
  dataSchema: adaptiveFeedbackCardSchema,
  widgetBuilder: (itemContext) {
    final data = AdaptiveFeedbackCardData.fromJson(
      itemContext.data as Map<String, Object?>,
    );

    return AdaptiveFeedbackWidget(
      data: data,
      onFeedbackSubmit: (feedbackStr) async {
        final action = data.onFeedback;
        if (action == null) return;
        final event = action['event'] as JsonMap?;
        final name = (event?['name'] as String?) ?? '';
        final JsonMap contextDefinition =
            (event?['context'] as JsonMap?) ?? <String, Object?>{};
        final JsonMap resolvedContext = await resolveContext(
          itemContext.dataContext,
          contextDefinition,
        );
        resolvedContext['feedback'] = feedbackStr;
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

class AdaptiveFeedbackWidget extends StatefulWidget {
  final AdaptiveFeedbackCardData data;
  final void Function(String) onFeedbackSubmit;

  const AdaptiveFeedbackWidget({
    super.key,
    required this.data,
    required this.onFeedbackSubmit,
  });

  @override
  State<AdaptiveFeedbackWidget> createState() => _AdaptiveFeedbackWidgetState();
}

class _AdaptiveFeedbackWidgetState extends State<AdaptiveFeedbackWidget> {
  bool _submitted = false;

  void _submit(String feedback) {
    if (_submitted) return;
    setState(() => _submitted = true);
    widget.onFeedbackSubmit(feedback);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submitted) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Feedback recorded.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            'ADAPTIVE FEEDBACK',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How was that last set of ${widget.data.exercise}?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => _submit('Too Easy'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  'TOO EASY',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _submit('Just Right'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'JUST RIGHT',
                  style: TextStyle(letterSpacing: 1.5),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _submit('Too Hard'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  'TOO HARD',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
