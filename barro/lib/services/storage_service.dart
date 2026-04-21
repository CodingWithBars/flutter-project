import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _subjectsKey = 'subjects_data';
  static const String _todosKey = 'todos_data';
  static const String _userKey = 'user_profile';
  static const String _scheduleKey = 'schedule_data';
  static const String _flashcardsKey = 'flashcards_data';

  // ── Subjects (legacy, kept for compatibility) ──

  static Future<void> saveSubjects(List<Map<String, dynamic>> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subjectsKey, jsonEncode(subjects));
  }

  static Future<List<Map<String, dynamic>>> loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_subjectsKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Todos ──

  static Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todosKey, jsonEncode(todos));
  }

  static Future<List<Map<String, dynamic>>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_todosKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── User Profile ──

  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_userKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(jsonDecode(data) as Map);
  }

  // ── Schedules ──

  static Future<void> saveSchedules(List<Map<String, dynamic>> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scheduleKey, jsonEncode(schedules));
  }

  static Future<List<Map<String, dynamic>>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_scheduleKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── Flashcards ──

  static Future<void> saveDecks(List<Map<String, dynamic>> decks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_flashcardsKey, jsonEncode(decks));
  }

  static Future<List<Map<String, dynamic>>> loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_flashcardsKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
