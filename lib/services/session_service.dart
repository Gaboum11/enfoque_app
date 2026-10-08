import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';

/// Servicio de almacenamiento local para sesiones resilientes de enfoque (100% Offline)
class SessionService {
  static const String _activeSessionKey = 'active_focus_session';
  static const String _historyKey = 'focus_sessions_history';

  static SessionService? _instance;
  static SessionService get instance => _instance ??= SessionService._();
  SessionService._();

  /// Guarda la sesión activa en almacenamiento local
  Future<void> saveActiveSession(FocusSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSessionKey, jsonEncode(session.toMap()));
  }

  /// Recupera la sesión activa actual si existe
  Future<FocusSession?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_activeSessionKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr);
      return FocusSession.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Elimina la sesión activa una vez concluida o descartada
  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeSessionKey);
  }

  /// Registra una sesión completada en el historial local (Req. 2)
  Future<void> recordCompletedSession(FocusSession session, {required bool goalAchieved}) async {
    session.isCompleted = true;
    session.isAbandoned = false;
    session.goalAchieved = goalAchieved;
    session.finishedAt = DateTime.now();

    await _saveToHistory(session);
    await clearActiveSession();
  }

  /// Registra una sesión abandonada en el historial local (Req. 2)
  Future<void> recordAbandonedSession(FocusSession session) async {
    session.isCompleted = false;
    session.isAbandoned = true;
    session.goalAchieved = false;
    session.finishedAt = DateTime.now();

    await _saveToHistory(session);
    await clearActiveSession();
  }

  /// Guarda una sesión en la lista de historial
  Future<void> _saveToHistory(FocusSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getSessionHistory();
    history.insert(0, session);

    final encodedList = history.map((s) => jsonEncode(s.toMap())).toList();
    await prefs.setStringList(_historyKey, encodedList);
  }

  /// Obtiene la lista de sesiones completadas y abandonadas
  Future<List<FocusSession>> getSessionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    return list.map((item) {
      try {
        return FocusSession.fromMap(jsonDecode(item));
      } catch (_) {
        return null;
      }
    }).whereType<FocusSession>().toList();
  }
}
