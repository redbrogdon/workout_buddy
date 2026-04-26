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
        name: 'saveActiveSession',
        description: 'Saves the current active workout session to history.',
        parameters: {
          'session': Schema.object(
            description: 'The workout session data to save.',
            properties: {
              'name': Schema.string(description: 'Name of the workout'),
              'exercises': Schema.array(
                items: Schema.object(
                  properties: {
                    'name': Schema.string(),
                    'sets': Schema.integer(),
                    'repetitions': Schema.integer(),
                    'duration': Schema.integer(),
                    'isCompleted': Schema.boolean(),
                  },
                ),
              ),
              'startTime': Schema.string(description: 'ISO timestamp'),
              'completedTimestamp': Schema.string(description: 'ISO timestamp'),
              'overallFeedback': Schema.string(),
            },
          ),
        },
        callable: (args) async {
          final sessionJson = args['session'] as Map<String, dynamic>;
          final session = WorkoutSessionRecord.fromJson(sessionJson);
          await storage.saveToHistory(session);
          await storage.clearActiveSession();
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
      AutoFunctionDeclaration(
        name: 'readActiveSession',
        description: 'Reads the current active workout session plan.',
        parameters: {},
        callable: (args) async {
          final session = await storage.readActiveSession();
          return session?.toJson() ?? {};
        },
      ),
    ]),
  ];
});
