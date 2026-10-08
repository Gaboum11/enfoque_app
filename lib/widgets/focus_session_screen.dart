import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

class FocusSessionScreen extends StatefulWidget {
  final FocusSession session;

  const FocusSessionScreen({
    super.key,
    required this.session,
  });

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  late FocusSession _session;
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _remainingSeconds = _session.remainingSeconds;

    // Guarda de inmediato en almacenamiento local para resiliencia ante cierres (Req. 5)
    SessionService.instance.saveActiveSession(_session);

    // Inicia el tick del temporizador
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_session.isPaused) {
        return;
      }

      setState(() {
        // Siempre recalculamos contra el tiempo real transcurrido (Req. 5)
        _remainingSeconds = _session.remainingSeconds;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _onSessionFinishedAutomatically();
      }
    });
  }

  void _togglePause() {
    setState(() {
      if (_session.isPaused) {
        // Reanudando: recalculamos startedAt ajustado al tiempo restante
        final elapsedMinutes = _session.scheduledMinutes - (_session.pausedRemainingSeconds ~/ 60);
        _session = FocusSession(
          id: _session.id,
          taskId: _session.taskId,
          taskTitle: _session.taskTitle,
          taskGoal: _session.taskGoal,
          startedAt: DateTime.now().subtract(Duration(minutes: elapsedMinutes)),
          scheduledMinutes: _session.scheduledMinutes,
          blockedApps: _session.blockedApps,
          isPaused: false,
        );
      } else {
        // Pausando: congelamos los segundos restantes
        _session.isPaused = true;
        _session.pausedRemainingSeconds = _remainingSeconds;
      }
    });
    SessionService.instance.saveActiveSession(_session);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Al concluir automáticamente por temporizador
  void _onSessionFinishedAutomatically() {
    _showGoalAssessmentDialog(wasCompleted: true);
  }

  // Diálogo para abandonar la sesión
  void _confirmAbandonSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text('¿Abandonar Sesión?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Si abandonas ahora, la sesión quedará registrada en el historial como "Abandonada" conforme a la metodología de estudio.',
          style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar Enfocado', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionService.instance.recordAbandonedSession(_session);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Sesión registrada como abandonada en el historial.'),
                    backgroundColor: Colors.grey.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              foregroundColor: const Color(0xFFDC2626),
              elevation: 0,
            ),
            child: const Text('Sí, Abandonar'),
          ),
        ],
      ),
    );
  }

  // Diálogo de Evaluación de Objetivo (Req. 2 y Tarea Principal)
  void _showGoalAssessmentDialog({required bool wasCompleted}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.award, color: Color(0xFF059669), size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Tiempo de Sesión Cumplido! 🎉',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Cierre de la Tarea Principal',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECF8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu objetivo era:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _session.taskGoal,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2F)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¿Cumpliste el objetivo propuesto?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E1E2F)),
            ),
            const SizedBox(height: 12),
            _buildAchievementOption(
              label: 'Sí, totalmente completado',
              icon: LucideIcons.checkCircle2,
              color: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              onTap: () => _finalizeSession(achieved: true),
            ),
            const SizedBox(height: 8),
            _buildAchievementOption(
              label: 'Parcialmente completado',
              icon: LucideIcons.helpCircle,
              color: const Color(0xFFD97706),
              bgColor: const Color(0xFFFFFBEB),
              onTap: () => _finalizeSession(achieved: false),
            ),
            const SizedBox(height: 8),
            _buildAchievementOption(
              label: 'No alcanzado (se reprogramará)',
              icon: LucideIcons.xCircle,
              color: const Color(0xFFDC2626),
              bgColor: const Color(0xFFFEF2F2),
              onTap: () => _finalizeSession(achieved: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementOption({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizeSession({required bool achieved}) async {
    Navigator.pop(context); // Cierra bottom sheet
    await SessionService.instance.recordCompletedSession(_session, goalAchieved: achieved);

    if (mounted) {
      Navigator.pop(context); // Vuelve a la pantalla principal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            achieved
                ? '¡Excelente trabajo! Sesión guardada con éxito en el historial.'
                : 'Sesión guardada. La constancia es la clave del aprendizaje.',
          ),
          backgroundColor: const Color(0xFF3227C9),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _session.progressPercentage;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF1E1E2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesión Activa de Enfoque',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E1E2F)),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'TIEMPO RESILIENTE • 100% OFFLINE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669), letterSpacing: 0.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.xCircle, color: Color(0xFFDC2626)),
            tooltip: 'Abandonar Sesión',
            onPressed: _confirmAbandonSession,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Tarjeta de la Tarea y Objetivo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9ECF8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEEFD),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.bookOpen, size: 16, color: Color(0xFF3227C9)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _session.taskTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E2F)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.target, size: 14, color: Color(0xFF4338CA)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _session.taskGoal,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF4338CA), fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Temporizador Circular Central
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFFE5E7FD),
                      color: const Color(0xFF3227C9),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1E2F),
                          letterSpacing: -1,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _session.isPaused ? 'EN PAUSA' : 'TIEMPO RESTANTE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: _session.isPaused ? const Color(0xFFD97706) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Tarjeta de Apps Bloqueadas
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shieldCheck, color: Color(0xFF3227C9), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bloqueo Estricto Activo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E2F)),
                          ),
                          Text(
                            '${_session.blockedApps.length} apps silenciadas (${_session.blockedApps.join(', ')})',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botones de Control
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _togglePause,
                        icon: Icon(_session.isPaused ? LucideIcons.play : LucideIcons.pause, size: 18),
                        label: Text(_session.isPaused ? 'Reanudar' : 'Pausar', style: const TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECEEFD),
                          foregroundColor: const Color(0xFF3227C9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showGoalAssessmentDialog(wasCompleted: true),
                        icon: const Icon(LucideIcons.checkCircle2, size: 18),
                        label: const Text('Completar', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3227C9),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
