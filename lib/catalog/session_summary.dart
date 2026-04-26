import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final sessionSummarySchema = S.object(
  properties: {
    'component': S.string(enumValues: ['SessionSummary']),
    'totalExercises': S.integer(
      description: 'The total number of exercises in the session',
    ),
    'completedExercises': S.integer(
      description: 'The number of exercises completed so far',
    ),
    'elapsedSeconds': S.integer(description: 'Total elapsed time in seconds'),
  },
  required: ['totalExercises', 'completedExercises'],
);

class SessionSummaryData {
  final int totalExercises;
  final int completedExercises;
  final int elapsedSeconds;

  SessionSummaryData({
    required this.totalExercises,
    required this.completedExercises,
    this.elapsedSeconds = 0,
  });

  factory SessionSummaryData.fromJson(Map<String, Object?> json) {
    return SessionSummaryData(
      totalExercises: json['totalExercises'] as int,
      completedExercises: json['completedExercises'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    );
  }
}

final sessionSummary = CatalogItem(
  name: 'SessionSummary',
  dataSchema: sessionSummarySchema,
  widgetBuilder: (itemContext) {
    final data = SessionSummaryData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return SessionSummary(data: data);
  },
);

class SessionSummary extends StatelessWidget {
  final SessionSummaryData data;

  const SessionSummary({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = data.totalExercises > 0
        ? data.completedExercises / data.totalExercises
        : 0.0;
    final minutes = (data.elapsedSeconds / 60).floor();
    final seconds = data.elapsedSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${data.completedExercises + 1} of ${data.totalExercises}',
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  timeStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
