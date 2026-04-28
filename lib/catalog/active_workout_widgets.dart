import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final estimatedCaloriesSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['EstimatedCalories']),
    'calories': S.integer(
      description: 'Estimated calories burned during the workout',
    ),
  },
  required: ['calories'],
);

class EstimatedCaloriesData {
  final int calories;

  EstimatedCaloriesData({required this.calories});

  factory EstimatedCaloriesData.fromJson(Map<String, Object?> json) {
    return EstimatedCaloriesData(
      calories: json['calories'] as int,
    );
  }
}

final estimatedCaloriesCard = CatalogItem(
  name: 'EstimatedCalories',
  dataSchema: estimatedCaloriesSchema,
  widgetBuilder: (itemContext) {
    final data = EstimatedCaloriesData.fromJson(
      itemContext.data as Map<String, Object?>,
    );
    return EstimatedCaloriesWidget(data: data);
  },
);

class EstimatedCaloriesWidget extends StatelessWidget {
  final EstimatedCaloriesData data;

  const EstimatedCaloriesWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Icon(
            Icons.local_fire_department,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'ESTIMATED BURN',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.calories}',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'KCAL',
                style: theme.textTheme.titleLarge?.copyWith(
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
