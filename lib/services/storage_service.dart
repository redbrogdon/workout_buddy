import 'dart:convert';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import '../models/workout_session.dart';
import '../models/user_preferences.dart';

class StorageService {
  final FileSystem _fs;
  final String _basePath;

  StorageService({FileSystem? fs, required String basePath})
      : _fs = fs ?? const LocalFileSystem(),
        _basePath = basePath;

  File _getFile(String fileName) => _fs.file(p.join(_basePath, fileName));

  // --- Active Session ---

  Future<void> saveActiveSession(WorkoutSessionRecord session) async {
    final file = _getFile('active_session.json');
    await file.writeAsString(jsonEncode(session.toJson()));
  }

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

  Future<void> clearActiveSession() async {
    final file = _getFile('active_session.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // --- History ---

  Future<void> saveToHistory(WorkoutSessionRecord session) async {
    final history = await readHistory();
    history.insert(0, session); // Newest first
    
    final file = _getFile('workout_history.json');
    final jsonList = history.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

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

  // --- User Preferences ---

  Future<void> savePreferences(UserPreferences prefs) async {
    final file = _getFile('user_preferences.json');
    await file.writeAsString(jsonEncode(prefs.toJson()));
  }

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
