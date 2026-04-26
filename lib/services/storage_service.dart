import 'dart:convert';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session.dart';
import '../models/user_preferences.dart';

/// Abstract interface for application storage.
abstract class StorageService {
  Future<void> saveActiveSession(WorkoutSessionRecord session);
  Future<WorkoutSessionRecord?> readActiveSession();
  Future<void> clearActiveSession();

  Future<void> saveToHistory(WorkoutSessionRecord session);
  Future<List<WorkoutSessionRecord>> readHistory();

  Future<void> savePreferences(UserPreferences prefs);
  Future<UserPreferences> readPreferences();
}

/// Implementation of [StorageService] that uses the local file system.
class FileStorageService implements StorageService {
  final FileSystem _fs;
  final String _basePath;

  FileStorageService({FileSystem? fs, required String basePath})
    : _fs = fs ?? const LocalFileSystem(),
      _basePath = basePath;

  File _getFile(String fileName) => _fs.file(p.join(_basePath, fileName));

  @override
  Future<void> saveActiveSession(WorkoutSessionRecord session) async {
    final file = _getFile('active_session.json');
    await file.writeAsString(jsonEncode(session.toJson()));
  }

  @override
  Future<WorkoutSessionRecord?> readActiveSession() async {
    final file = _getFile('active_session.json');
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return WorkoutSessionRecord.fromJson(jsonDecode(content));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearActiveSession() async {
    final file = _getFile('active_session.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> saveToHistory(WorkoutSessionRecord session) async {
    final history = await readHistory();
    history.insert(0, session);
    final file = _getFile('workout_history.json');
    await file.writeAsString(
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<WorkoutSessionRecord>> readHistory() async {
    final file = _getFile('workout_history.json');
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => WorkoutSessionRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    final file = _getFile('user_preferences.json');
    await file.writeAsString(jsonEncode(prefs.toJson()));
  }

  @override
  Future<UserPreferences> readPreferences() async {
    final file = _getFile('user_preferences.json');
    if (!await file.exists()) return UserPreferences(description: '');
    try {
      final content = await file.readAsString();
      return UserPreferences.fromJson(jsonDecode(content));
    } catch (_) {
      return UserPreferences(description: '');
    }
  }
}

/// Implementation of [StorageService] that uses SharedPreferences (LocalStorage on web).
class SharedPreferencesStorageService implements StorageService {
  final SharedPreferences _prefs;

  SharedPreferencesStorageService(this._prefs);

  static const _activeKey = 'active_session';
  static const _historyKey = 'workout_history';
  static const _preferencesKey = 'user_preferences';

  @override
  Future<void> saveActiveSession(WorkoutSessionRecord session) async {
    await _prefs.setString(_activeKey, jsonEncode(session.toJson()));
  }

  @override
  Future<WorkoutSessionRecord?> readActiveSession() async {
    final content = _prefs.getString(_activeKey);
    if (content == null) return null;
    try {
      return WorkoutSessionRecord.fromJson(jsonDecode(content));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearActiveSession() async {
    await _prefs.remove(_activeKey);
  }

  @override
  Future<void> saveToHistory(WorkoutSessionRecord session) async {
    final history = await readHistory();
    history.insert(0, session);
    await _prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<List<WorkoutSessionRecord>> readHistory() async {
    final content = _prefs.getString(_historyKey);
    if (content == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((e) => WorkoutSessionRecord.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    await _prefs.setString(_preferencesKey, jsonEncode(prefs.toJson()));
  }

  @override
  Future<UserPreferences> readPreferences() async {
    final content = _prefs.getString(_preferencesKey);
    if (content == null) return UserPreferences(description: '');
    try {
      return UserPreferences.fromJson(jsonDecode(content));
    } catch (_) {
      return UserPreferences(description: '');
    }
  }
}
