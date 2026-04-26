import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;
import 'package:workout_buddy/main.dart';
import 'package:workout_buddy/services/storage_service.dart';
import 'package:workout_buddy/providers/storage_providers.dart';
import 'package:workout_buddy/models/workout_session.dart';
import 'package:workout_buddy/models/user_preferences.dart';
import 'package:workout_buddy/services/agent_service.dart';

class MockStorageService implements StorageService {
  @override
  Future<void> clearActiveSession() async {}

  @override
  Future<WorkoutSessionRecord?> readActiveSession() async => null;

  @override
  Future<List<WorkoutSessionRecord>> readHistory() async => [];

  @override
  Future<UserPreferences> readPreferences() async =>
      UserPreferences(description: '');

  @override
  Future<void> saveActiveSession(WorkoutSessionRecord session) async {}

  @override
  Future<void> savePreferences(UserPreferences prefs) async {}

  @override
  Future<void> saveToHistory(WorkoutSessionRecord session) async {}
}

class MockAgentService implements AgentService {
  @override
  Future<String?> sendMessage(genui.ChatMessage msg) async {
    // Return a dummy response
    return 'Test Response';
  }

  @override
  void dispose() {}
}

class MockBrokenAgentService implements AgentService {
  @override
  Future<String?> sendMessage(genui.ChatMessage msg) async {
    // Simulate a failure or timeout returning null
    return null;
  }

  @override
  void dispose() {}
}

void main() {
  group('Main Application Smoke Tests', () {
    testWidgets('Navigation smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            agentServiceProvider.overrideWith(
              (ref, purpose) => MockAgentService(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // Initial render - Plan screen should show its AppBar title
      expect(find.text('Plan'), findsAtLeast(1));
      expect(find.text('Plan Your Workout'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar), findsAtLeast(1));

      // Navigate to Workout
      await tester.tap(find.byIcon(Icons.fitness_center));
      await tester.pumpAndSettle();

      expect(find.text('Workout'), findsAtLeast(1));
      expect(find.text('Active Session'), findsOneWidget);

      // Navigate to Report
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.text('Report'), findsAtLeast(1));
      expect(find.text('Performance Report'), findsOneWidget);
    });

    testWidgets('ReportScreen handles empty history gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            agentServiceProvider.overrideWith(
              (ref, purpose) => MockAgentService(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // Navigate to Report
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.text('Performance Report'), findsOneWidget);
    });

    testWidgets('PlanScreen survives silent agent (null response)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(MockStorageService()),
            agentServiceProvider.overrideWith(
              (ref, purpose) => MockBrokenAgentService(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      // Enter text and send
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.tap(find.byType(IconButton).first); // Send button
      await tester.pump();

      expect(find.text('Plan Your Workout'), findsOneWidget);
    });
  });
}
