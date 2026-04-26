import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

// --- SummaryCard ---

final summaryCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['SummaryCard']),
    'title': S.string(description: 'Title of the summary'),
    'content': S.string(description: 'Markdown formatted content'),
  },
  required: ['title', 'content'],
);

class SummaryCardData {
  final String title;
  final String content;

  SummaryCardData({required this.title, required this.content});

  factory SummaryCardData.fromJson(Map<String, Object?> json) {
    return SummaryCardData(
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }
}

final summaryCard = CatalogItem(
  name: 'SummaryCard',
  dataSchema: summaryCardSchema,
  widgetBuilder: (itemContext) {
    final data = SummaryCardData.fromJson(itemContext.data as Map<String, Object?>);
    return SummaryCard(data: data);
  },
);

class SummaryCard extends StatelessWidget {
  final SummaryCardData data;
  const SummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: theme.textTheme.headlineSmall),
            const Divider(),
            const SizedBox(height: 8),
            // We use simple Text for now, or Markdown if we have the package.
            // Flutter doesn't have built-in Markdown, so we'll just show the text.
            Text(data.content),
          ],
        ),
      ),
    );
  }
}

// --- BarChart ---

final barChartSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['BarChart']),
    'title': S.string(description: 'Title of the chart'),
    'description': S.string(description: 'Optional description'),
    'labels': S.list(items: S.string(), description: 'Labels for each bar'),
    'values': S.list(items: S.number(), description: 'Values for each bar'),
  },
  required: ['title', 'labels', 'values'],
);

class BarChartData {
  final String title;
  final String? description;
  final List<String> labels;
  final List<double> values;

  BarChartData({
    required this.title,
    this.description,
    required this.labels,
    required this.values,
  });

  factory BarChartData.fromJson(Map<String, Object?> json) {
    return BarChartData(
      title: json['title'] as String,
      description: json['description'] as String?,
      labels: (json['labels'] as List? ?? []).cast<String>(),
      values: (json['values'] as List? ?? []).map((e) => (e as num).toDouble()).toList(),
    );
  }
}

final barChart = CatalogItem(
  name: 'BarChart',
  dataSchema: barChartSchema,
  widgetBuilder: (itemContext) {
    final data = BarChartData.fromJson(itemContext.data as Map<String, Object?>);
    return BarChart(data: data);
  },
);

class BarChart extends StatelessWidget {
  final BarChartData data;
  const BarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = data.values.isEmpty ? 1.0 : data.values.reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: theme.textTheme.titleLarge),
            if (data.description != null) ...[
              const SizedBox(height: 4),
              Text(data.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.labels.length, (index) {
                  final value = data.values[index];
                  final heightFactor = maxValue > 0 ? value / maxValue : 0.0;
                  
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                            height: 150 * heightFactor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.labels[index],
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
