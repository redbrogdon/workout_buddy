import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:fl_chart/fl_chart.dart';

// --- LatestSessionCard ---
final latestSessionCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['LatestSessionCard']),
    'title': S.string(description: 'E.g. "LATEST SESSION"'),
    'duration': S.integer(description: 'Duration in minutes'),
    'calories': S.integer(description: 'Calories burned'),
    'exercises': S.integer(description: 'Number of exercises completed'),
  },
  required: ['title', 'duration', 'calories', 'exercises'],
);

class LatestSessionCardData {
  final String title;
  final int duration;
  final int calories;
  final int exercises;

  LatestSessionCardData({
    required this.title,
    required this.duration,
    required this.calories,
    required this.exercises,
  });

  factory LatestSessionCardData.fromJson(Map<String, Object?> json) {
    return LatestSessionCardData(
      title: json['title'] as String,
      duration: json['duration'] as int,
      calories: json['calories'] as int,
      exercises: json['exercises'] as int,
    );
  }
}

final latestSessionCard = CatalogItem(
  name: 'LatestSessionCard',
  dataSchema: latestSessionCardSchema,
  widgetBuilder: (itemContext) {
    final data = LatestSessionCardData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return LatestSessionWidget(data: data);
  },
);

class LatestSessionWidget extends StatelessWidget {
  final LatestSessionCardData data;
  const LatestSessionWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(context, '${data.duration}m', 'TIME'),
              _buildStat(context, '${data.calories}', 'KCAL'),
              _buildStat(context, '${data.exercises}', 'MOVES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// --- StreakWidget ---
final streakWidgetSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['StreakWidget']),
    'streakCount': S.integer(description: 'Current day streak'),
  },
  required: ['streakCount'],
);

class StreakWidgetData {
  final int streakCount;
  StreakWidgetData({required this.streakCount});
  factory StreakWidgetData.fromJson(Map<String, Object?> json) {
    return StreakWidgetData(streakCount: json['streakCount'] as int);
  }
}

final streakWidget = CatalogItem(
  name: 'StreakWidget',
  dataSchema: streakWidgetSchema,
  widgetBuilder: (itemContext) {
    final data = StreakWidgetData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return StreakCard(data: data);
  },
);

class StreakCard extends StatelessWidget {
  final StreakWidgetData data;
  const StreakCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.streakCount} DAY STREAK',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Keep the momentum going!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- RankingWidget ---
final rankingWidgetSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['RankingWidget']),
    'percentile': S.integer(description: 'User percentile ranking'),
  },
  required: ['percentile'],
);

class RankingWidgetData {
  final int percentile;
  RankingWidgetData({required this.percentile});
  factory RankingWidgetData.fromJson(Map<String, Object?> json) {
    return RankingWidgetData(percentile: json['percentile'] as int);
  }
}

final rankingWidget = CatalogItem(
  name: 'RankingWidget',
  dataSchema: rankingWidgetSchema,
  widgetBuilder: (itemContext) {
    final data = RankingWidgetData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return RankingCard(data: data);
  },
);

class RankingCard extends StatelessWidget {
  final RankingWidgetData data;
  const RankingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: theme.colorScheme.primary, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOP ${data.percentile}%',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'THIS WEEK',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WeeklyCalendarWidget ---
final weeklyCalendarWidgetSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['WeeklyCalendarWidget']),
    'completedDays': S.list(
      items: S.integer(),
      description: 'List of days (0=Mon, 6=Sun) where a workout was completed',
    ),
  },
  required: ['completedDays'],
);

class WeeklyCalendarData {
  final List<int> completedDays;
  WeeklyCalendarData({required this.completedDays});
  factory WeeklyCalendarData.fromJson(Map<String, Object?> json) {
    return WeeklyCalendarData(
      completedDays: (json['completedDays'] as List? ?? []).cast<int>(),
    );
  }
}

final weeklyCalendarWidget = CatalogItem(
  name: 'WeeklyCalendarWidget',
  dataSchema: weeklyCalendarWidgetSchema,
  widgetBuilder: (itemContext) {
    final data = WeeklyCalendarData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return WeeklyCalendarCard(data: data);
  },
);

class WeeklyCalendarCard extends StatelessWidget {
  final WeeklyCalendarData data;
  const WeeklyCalendarCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = data.completedDays.contains(index);
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// --- ProgressChartWidget ---
final progressChartWidgetSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['ProgressChartWidget']),
    'title': S.string(description: 'Chart title'),
    'labels': S.list(items: S.string(), description: 'X-axis labels'),
    'values': S.list(items: S.number(), description: 'Y-axis values'),
  },
  required: ['title', 'labels', 'values'],
);

class ProgressChartData {
  final String title;
  final List<String> labels;
  final List<double> values;

  ProgressChartData({
    required this.title,
    required this.labels,
    required this.values,
  });

  factory ProgressChartData.fromJson(Map<String, Object?> json) {
    return ProgressChartData(
      title: json['title'] as String,
      labels: (json['labels'] as List? ?? []).cast<String>(),
      values: (json['values'] as List? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

final progressChartWidget = CatalogItem(
  name: 'ProgressChartWidget',
  dataSchema: progressChartWidgetSchema,
  widgetBuilder: (itemContext) {
    final data = ProgressChartData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return ProgressChartCard(data: data);
  },
);

class ProgressChartCard extends StatelessWidget {
  final ProgressChartData data;
  const ProgressChartCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = List.generate(
      data.values.length,
      (index) => FlSpot(index.toDouble(), data.values[index]),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data.labels[index],
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- InsightAlertCard ---
final insightAlertCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['InsightAlertCard']),
    'title': S.string(description: 'E.g. "RECOVERY TIP"'),
    'insight': S.string(description: 'The advice or insight content'),
  },
  required: ['title', 'insight'],
);

class InsightAlertData {
  final String title;
  final String insight;

  InsightAlertData({required this.title, required this.insight});

  factory InsightAlertData.fromJson(Map<String, Object?> json) {
    return InsightAlertData(
      title: json['title'] as String,
      insight: json['insight'] as String,
    );
  }
}

final insightAlertCard = CatalogItem(
  name: 'InsightAlertCard',
  dataSchema: insightAlertCardSchema,
  widgetBuilder: (itemContext) {
    final data = InsightAlertData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return InsightAlertWidget(data: data);
  },
);

class InsightAlertWidget extends StatelessWidget {
  final InsightAlertData data;
  const InsightAlertWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.insight,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
