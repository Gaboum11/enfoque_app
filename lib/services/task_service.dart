import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

/// Servicio de almacenamiento local offline para tareas de estudio
class TaskService {
  static const String _tasksKey = 'user_tasks_list';

  static TaskService? _instance;
  static TaskService get instance => _instance ??= TaskService._();
  TaskService._();

  /// Obtiene la lista de tareas guardadas (inicializa con ejemplos si está vacía)
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_tasksKey);

    if (list == null || list.isEmpty) {
      final initialTasks = _getDefaultInitialTasks();
      await saveAllTasks(initialTasks);
      return initialTasks;
    }

    return list.map((item) {
      try {
        return Task.fromMap(jsonDecode(item));
      } catch (_) {
        return null;
      }
    }).whereType<Task>().toList();
  }

  /// Guarda una nueva tarea o actualiza una existente
  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await saveAllTasks(tasks);
  }

  /// Guarda toda la lista de tareas
  Future<void> saveAllTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_tasksKey, encoded);
  }

  /// Elimina una tarea por su id
  Future<void> deleteTask(String id) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == id);
    await saveAllTasks(tasks);
  }

  /// Tareas iniciales de ejemplo para estudiantes
  List<Task> _getDefaultInitialTasks() {
    return [
      Task(
        id: 'init-1',
        title: 'Ejercicios de Cálculo Diferencial',
        goal: 'Resolver 5 problemas de optimización y máximos/mínimos',
        durationMinutes: 45,
        priority: 'Alta',
        tags: ['Matemáticas', 'Examen'],
        blockDistractions: true,
        blockedApps: ['Instagram', 'TikTok', 'YouTube', 'Twitter / X'],
      ),
      Task(
        id: 'init-2',
        title: 'Lectura de Microeconomía',
        goal: 'Comprender conceptos de elasticidad de la demanda',
        durationMinutes: 30,
        priority: 'Media',
        tags: ['Lectura', 'Universidad'],
        blockDistractions: true,
        blockedApps: ['Instagram', 'TikTok'],
      ),
      Task(
        id: 'init-3',
        title: 'Laboratorio de Algoritmos',
        goal: 'Implementar estructura de datos grafo en Dart',
        durationMinutes: 60,
        priority: 'Alta',
        tags: ['Programación', 'Proyecto'],
        blockDistractions: true,
        blockedApps: ['Instagram', 'TikTok', 'Facebook'],
      ),
    ];
  }
}
