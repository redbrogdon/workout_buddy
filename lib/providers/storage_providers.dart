import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../models/workout_session.dart';
import '../models/user_preferences.dart';

/// The base storage service provider.
/// Should be overridden in [ProviderScope] during app initialization.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in main()');
});

/// Tracks the active workout session, if any.
final activeSessionProvider = NotifierProvider<ActiveSessionNotifier, WorkoutSessionRecord?>(ActiveSessionNotifier.new);

class ActiveSessionNotifier extends Notifier<WorkoutSessionRecord?> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  WorkoutSessionRecord? build() {
    // Initial load happens asynchronously in main shell or here if we use AsyncNotifier.
    // For now, we initialize as null and load manually.
    return null;
  }

  Future<void> load() async {
    state = await _storage.readActiveSession();
  }

  Future<void> save(WorkoutSessionRecord session) async {
    await _storage.saveActiveSession(session);
    state = session;
  }

  Future<void> clear() async {
    await _storage.clearActiveSession();
    state = null;
  }
}

/// Tracks the entire workout history.
final historyProvider = NotifierProvider<HistoryNotifier, List<WorkoutSessionRecord>>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<List<WorkoutSessionRecord>> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  List<WorkoutSessionRecord> build() {
    return [];
  }

  Future<void> load() async {
    state = await _storage.readHistory();
  }

  Future<void> addToHistory(WorkoutSessionRecord session) async {
    await _storage.saveToHistory(session);
    await load();
  }
}

/// Tracks user preferences.
final preferencesProvider = NotifierProvider<PreferencesNotifier, UserPreferences>(PreferencesNotifier.new);

class PreferencesNotifier extends Notifier<UserPreferences> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  UserPreferences build() {
    return UserPreferences(description: '');
  }

  Future<void> load() async {
    state = await _storage.readPreferences();
  }

  Future<void> updateDescription(String description) async {
    final newPrefs = UserPreferences(description: description);
    await _storage.savePreferences(newPrefs);
    state = newPrefs;
  }
}
