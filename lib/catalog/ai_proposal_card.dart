import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final aiCoachProposalCardSchema = S.object(
  properties: {
    'component': S.string(enumValues: ['AiCoachProposalCard']),
    'proposal': S.string(
      description:
          'The conversational proposal or introductory text from the AI coach.',
    ),
  },
  required: ['proposal'],
);

class AiCoachProposalCardData {
  final String proposal;

  AiCoachProposalCardData({required this.proposal});

  factory AiCoachProposalCardData.fromJson(Map<String, Object?> json) {
    return AiCoachProposalCardData(
      proposal: json['proposal'] as String,
    );
  }
}

final aiCoachProposalCard = CatalogItem(
  name: 'AiCoachProposalCard',
  dataSchema: aiCoachProposalCardSchema,
  widgetBuilder: (itemContext) {
    final data = AiCoachProposalCardData.fromJson(
      itemContext.data as Map<String, Object?>,
    );

    return AiCoachProposalCardWidget(data: data);
  },
);

class AiCoachProposalCardWidget extends StatelessWidget {
  final AiCoachProposalCardData data;

  const AiCoachProposalCardWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI COACH',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  data.proposal,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.format_quote,
              size: 100,
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }
}
