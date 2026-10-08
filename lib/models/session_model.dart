/// Modelo para las sesiones de concentración y enfoque
class FocusSession {
  final String id;
  final String taskId;
  final String taskTitle;
  final String taskGoal;
  final DateTime startedAt;
  final int scheduledMinutes;
  final List<String> blockedApps;
  bool isPaused;
  int pausedRemainingSeconds;
  bool isCompleted;
  bool isAbandoned;
  bool? goalAchieved; // true: Sí, false: No/Parcial, null: en progreso
  DateTime? finishedAt;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.taskGoal,
    required this.startedAt,
    required this.scheduledMinutes,
    this.blockedApps = const [],
    this.isPaused = false,
    this.pausedRemainingSeconds = 0,
    this.isCompleted = false,
    this.isAbandoned = false,
    this.goalAchieved,
    this.finishedAt,
  });

  /// Calcula los segundos restantes basados en el tiempo real transcurrido (Req. 5)
  int get remainingSeconds {
    if (isPaused) {
      return pausedRemainingSeconds;
    }
    final totalSeconds = scheduledMinutes * 60;
    final elapsedSeconds = DateTime.now().difference(startedAt).inSeconds;
    final remaining = totalSeconds - elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Porcentaje de progreso de 0.0 a 1.0
  double get progressPercentage {
    final totalSeconds = scheduledMinutes * 60;
    if (totalSeconds == 0) return 1.0;
    final remaining = remainingSeconds;
    final progress = (totalSeconds - remaining) / totalSeconds;
    return progress.clamp(0.0, 1.0);
  }

  bool get isFinished => remainingSeconds <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'taskGoal': taskGoal,
      'startedAt': startedAt.toIso8601String(),
      'scheduledMinutes': scheduledMinutes,
      'blockedApps': blockedApps,
      'isPaused': isPaused,
      'pausedRemainingSeconds': pausedRemainingSeconds,
      'isCompleted': isCompleted,
      'isAbandoned': isAbandoned,
      'goalAchieved': goalAchieved,
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory FocusSession.fromMap(Map<String, dynamic> map) {
    return FocusSession(
      id: map['id'] ?? '',
      taskId: map['taskId'] ?? '',
      taskTitle: map['taskTitle'] ?? '',
      taskGoal: map['taskGoal'] ?? '',
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'])
          : DateTime.now(),
      scheduledMinutes: map['scheduledMinutes'] ?? 25,
      blockedApps: List<String>.from(map['blockedApps'] ?? []),
      isPaused: map['isPaused'] ?? false,
      pausedRemainingSeconds: map['pausedRemainingSeconds'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      isAbandoned: map['isAbandoned'] ?? false,
      goalAchieved: map['goalAchieved'],
      finishedAt: map['finishedAt'] != null ? DateTime.parse(map['finishedAt']) : null,
    );
  }
}
