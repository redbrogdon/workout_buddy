import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../providers/storage_providers.dart';
import '../models/workout_session.dart';

final storageToolsProvider = Provider<List<Tool>>((ref) {
  final storage = ref.watch(storageServiceProvider);

  return [
    Tool.functionDeclarations([
      AutoFunctionDeclaration(
        name: 'readHistory',
        description: 'Reads the entire workout history of the user.',
        parameters: {},
        callable: (args) async {
          final history = await storage.readHistory();
          return {
            'history': history.map((s) => s.toJson()).toList(),
          };
        },
      ),
      AutoFunctionDeclaration(
        name: 'saveWorkoutSession',
        description:
            'Saves or updates a workout session in the user\'s history. Use a unique ID to update an existing session (e.g. as exercises are completed).',
        parameters: {
          'session': Schema.object(
            description: 'The workout session data to save or update.',
            properties: {
              'id': Schema.string(
                description:
                    'A unique identifier for this session. Use the same ID to update progress.',
              ),
              'name': Schema.string(description: 'Name of the workout'),
              'exercises': Schema.array(
                items: Schema.object(
                  properties: {
                    'name': Schema.string(),
                    'suggestedDuration': Schema.integer(),
                    'numberOfReps': Schema.integer(),
                    'actualDuration': Schema.integer(),
                    'repsCompleted': Schema.integer(),
                    'exerciseFeedback': Schema.string(),
                    'completedTimestamp': Schema.string(),
                    'wasSkipped': Schema.boolean(),
                  },
                ),
              ),
              'createdTimestamp': Schema.string(
                description: 'ISO timestamp of when the session was created.',
              ),
              'startedTimestamp': Schema.string(
                description:
                    'ISO timestamp of when the workout actually began.',
              ),
              'completedTimestamp': Schema.string(
                description: 'ISO timestamp of when the workout was finished.',
              ),
              'overallFeedback': Schema.string(),
            },
          ),
        },
        callable: (args) async {
          final sessionJson = args['session'] as Map<String, dynamic>;
          final session = WorkoutSessionRecord.fromJson(sessionJson);
          await storage.saveToHistory(session);
          return {'status': 'success'};
        },
      ),
      AutoFunctionDeclaration(
        name: 'readPreferences',
        description: 'Reads the user preferences for workout styles and goals.',
        parameters: {},
        callable: (args) async {
          final prefs = await storage.readPreferences();
          return prefs.toJson();
        },
      ),
    ]),
  ];
});
