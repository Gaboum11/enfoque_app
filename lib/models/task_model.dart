/// Modelo de datos para las tareas de concentración y estudio
class Task {
  final String id;
  final String title;
  final String goal;
  final int durationMinutes;
  final String priority; // 'Alta', 'Media', 'Baja'
  final List<String> tags;
  final bool blockDistractions;
  final List<String> blockedApps;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.goal,
    required this.durationMinutes,
    this.priority = 'Alta',
    this.tags = const [],
    this.blockDistractions = true,
    this.blockedApps = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'goal': goal,
      'durationMinutes': durationMinutes,
      'priority': priority,
      'tags': tags,
      'blockDistractions': blockDistractions,
      'blockedApps': blockedApps,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      goal: map['goal'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 25,
      priority: map['priority'] ?? 'Alta',
      tags: List<String>.from(map['tags'] ?? []),
      blockDistractions: map['blockDistractions'] ?? true,
      blockedApps: List<String>.from(map['blockedApps'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Modelo para las aplicaciones bloqueadas durante la sesión de estudio
class BlockedAppItem {
  final String name;
  final String packageName;
  final String category;
  bool isBlocked;

  BlockedAppItem({
    required this.name,
    required this.packageName,
    this.category = 'Redes Sociales',
    this.isBlocked = false,
  });
}
