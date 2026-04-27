import 'dart:async';
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

class SessionSummary extends StatefulWidget {
  final SessionSummaryData data;

  const SessionSummary({super.key, required this.data});

  @override
  State<SessionSummary> createState() => _SessionSummaryState();
}

class _SessionSummaryState extends State<SessionSummary> {
  late int _elapsedSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.data.elapsedSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(SessionSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the agent updates the time (e.g. after a long think), sync to it.
    if (oldWidget.data.elapsedSeconds != widget.data.elapsedSeconds) {
      setState(() {
        _elapsedSeconds = widget.data.elapsedSeconds;
      });
    }

    final isComplete =
        widget.data.completedExercises >= widget.data.totalExercises;
    if (isComplete) {
      _timer?.cancel();
      _timer = null;
    } else if (_timer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    final isComplete =
        widget.data.completedExercises >= widget.data.totalExercises;
    if (isComplete) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete =
        widget.data.completedExercises >= widget.data.totalExercises;

    final progress = widget.data.totalExercises > 0
        ? widget.data.completedExercises / widget.data.totalExercises
        : 0.0;

    final minutes = (_elapsedSeconds / 60).floor();
    final seconds = _elapsedSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final statusText = isComplete
        ? 'Workout Complete!'
        : 'Exercise ${widget.data.completedExercises + 1} of ${widget.data.totalExercises}';

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
                  statusText,
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
