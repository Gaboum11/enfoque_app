import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';

/// Pantalla de Historial de Sesiones de Enfoque (Requerimiento 2 y Evaluación de Objetivos)
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FocusSession> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await SessionService.instance.getSessionHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  int get _totalCompletedMinutes {
    return _history
        .where((s) => s.isCompleted)
        .fold(0, (sum, s) => sum + s.scheduledMinutes);
  }

  int get _completedSessionsCount => _history.where((s) => s.isCompleted).length;
  int get _abandonedSessionsCount => _history.where((s) => s.isAbandoned).length;

  int get _goalsAchievedCount =>
      _history.where((s) => s.isCompleted && s.goalAchieved == true).length;

  double get _successRate {
    if (_history.isEmpty) return 0.0;
    return (_completedSessionsCount / _history.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9FE),
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Enfoque',
              style: TextStyle(
                color: Color(0xFF1E1E2F),
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
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
                  '100% LOCAL • REGISTRO DE LOGRO',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw, color: Color(0xFF3227C9), size: 19),
            tooltip: 'Actualizar historial',
            onPressed: _loadHistory,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3227C9)))
          : RefreshIndicator(
              color: const Color(0xFF3227C9),
              onRefresh: _loadHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryMetricsCard(),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sesiones Registradas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E2F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_history.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(_history[index]);
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: LucideIcons.clock,
                  iconColor: const Color(0xFF3227C9),
                  label: 'Minutos Totales',
                  value: '$_totalCompletedMinutes min',
                ),
              ),
              Container(width: 1, height: 44, color: const Color(0xFFF0F1F7)),
              Expanded(
                child: _buildMetricTile(
                  icon: LucideIcons.checkCircle2,
                  iconColor: const Color(0xFF059669),
                  label: 'Completadas',
                  value: '$_completedSessionsCount',
                ),
              ),
              Container(width: 1, height: 44, color: const Color(0xFFF0F1F7)),
              Expanded(
                child: _buildMetricTile(
                  icon: LucideIcons.target,
                  iconColor: const Color(0xFFD97706),
                  label: 'Objetivo Cumplido',
                  value: '$_goalsAchievedCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.pieChart, size: 14, color: Color(0xFF3227C9)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Tasa de Finalización: ${_successRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E2F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_abandonedSessionsCount abandonadas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _abandonedSessionsCount > 0 ? const Color(0xFFBA1A1A) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E1E2F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(FocusSession session) {
    final isCompleted = session.isCompleted;
    final isAbandoned = session.isAbandoned;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;
    IconData statusIcon;

    if (isCompleted) {
      statusBgColor = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF059669);
      statusLabel = 'Completada';
      statusIcon = LucideIcons.checkCircle2;
    } else if (isAbandoned) {
      statusBgColor = const Color(0xFFFEF2F2);
      statusTextColor = const Color(0xFFBA1A1A);
      statusLabel = 'Abandonada';
      statusIcon = LucideIcons.xCircle;
    } else {
      statusBgColor = const Color(0xFFEEF2FF);
      statusTextColor = const Color(0xFF3227C9);
      statusLabel = 'En curso';
      statusIcon = LucideIcons.clock;
    }

    final dateStr = _formatDateTime(session.startedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.taskTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E2F),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusTextColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                      ),
                    ),
                  ],
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
                const Icon(LucideIcons.target, size: 13, color: Color(0xFF3227C9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.taskGoal,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B4F69),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${session.scheduledMinutes} min programados',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '•  $dateStr',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (session.goalAchieved != null) ...[
                Row(
                  children: [
                    Icon(
                      session.goalAchieved == true ? LucideIcons.check : LucideIcons.x,
                      size: 13,
                      color: session.goalAchieved == true
                          ? const Color(0xFF059669)
                          : const Color(0xFFBA1A1A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.goalAchieved == true ? 'Objetivo logrado' : 'Objetivo incompleto',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: session.goalAchieved == true
                            ? const Color(0xFF059669)
                            : const Color(0xFFBA1A1A),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECF8)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFECEEFD),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.history, color: Color(0xFF3227C9), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin sesiones registradas aún',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inicia tu primera sesión de estudio para evaluar tu cumplimiento y registrar tu progreso localmente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hoy $hour:$minute';
    }
    return '${dt.day}/${dt.month} $hour:$minute';
  }
}
