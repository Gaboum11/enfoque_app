import 'package:flutter_test/flutter_test.dart';
import 'package:enfoque_app/models/session_model.dart';

void main() {
  group('Requerimiento 5: Resiliencia del Temporizador ante Cierre de la App', () {
    test('Calcula el tiempo real restante si la app se reabre 10 minutos después', () {
      final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));

      final session = FocusSession(
        id: 'session-1',
        taskId: 'task-100',
        taskTitle: 'Estudiar Cálculo III',
        taskGoal: 'Resolver 5 integrales triples',
        startedAt: tenMinutesAgo,
        scheduledMinutes: 25,
      );

      // Total 25 min (1500 s), transcurridos 10 min (600 s) -> restante ~ 15 min (900 s)
      final remaining = session.remainingSeconds;
      expect(remaining, inInclusiveRange(895, 900));
      expect(session.isFinished, isFalse);
    });

    test('Detecta que la sesión concluyó si transcurrió todo el tiempo programado', () {
      final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));

      final session = FocusSession(
        id: 'session-2',
        taskId: 'task-100',
        taskTitle: 'Estudiar Historia',
        taskGoal: 'Resumir capítulo 4',
        startedAt: thirtyMinutesAgo,
        scheduledMinutes: 25,
      );

      expect(session.remainingSeconds, 0);
      expect(session.isFinished, isTrue);
      expect(session.progressPercentage, 1.0);
    });

    test('Serialización y deserialización conserva la marca temporal exacta de inicio', () {
      final now = DateTime.now();
      final session = FocusSession(
        id: 'session-3',
        taskId: 'task-200',
        taskTitle: 'Desarrollo de Software',
        taskGoal: 'Implementar pruebas unitarias',
        startedAt: now,
        scheduledMinutes: 45,
        blockedApps: ['Instagram', 'TikTok'],
      );

      final map = session.toMap();
      final reconstructed = FocusSession.fromMap(map);

      expect(reconstructed.id, session.id);
      expect(reconstructed.startedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(reconstructed.scheduledMinutes, 45);
      expect(reconstructed.blockedApps, ['Instagram', 'TikTok']);
    });
  });
}
