import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/task_model.dart';
import '../models/session_model.dart';
import '../services/task_service.dart';
import '../services/session_service.dart';
import 'focus_session_screen.dart';

/// Pantalla Principal: Dashboard y Lista de Tareas (Requerimiento 4: Lanzamiento < 5 toques)
class TaskListScreen extends StatefulWidget {
  final VoidCallback? onNavigateToNewTask;

  const TaskListScreen({
    super.key,
    this.onNavigateToNewTask,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedPriorityFilter = 'Todas';
  FocusSession? _activeSession;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tasks = await TaskService.instance.getTasks();
    final active = await SessionService.instance.getActiveSession();

    if (mounted) {
      setState(() {
        _tasks = tasks;
        _activeSession = active;
        _isLoading = false;
      });
    }
  }

  List<Task> get _filteredTasks {
    if (_selectedPriorityFilter == 'Todas') {
      return _tasks;
    }
    return _tasks.where((t) => t.priority == _selectedPriorityFilter).toList();
  }

  /// Requerimiento 4: Inicia la sesión de enfoque en 1 solo toque
  void _startFocusSession(Task task) {
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: task.id,
      taskTitle: task.title,
      taskGoal: task.goal,
      startedAt: DateTime.now(),
      scheduledMinutes: task.durationMinutes,
      blockedApps: task.blockDistractions ? task.blockedApps : const [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusSessionScreen(session: session),
      ),
    ).then((_) => _loadData());
  }

  void _resumeActiveSession() {
    if (_activeSession == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusSessionScreen(session: _activeSession!),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _deleteTask(Task task) async {
    await TaskService.instance.deleteTask(task.id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea "${task.title}" eliminada'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
              'Enfoque',
              style: TextStyle(
                color: Color(0xFF1E1E2F),
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3227C9),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  '100% OFFLINE • PRIVACIDAD TOTAL',
                  style: TextStyle(
                    color: Color(0xFF3227C9),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF3227C9),
              child: Icon(LucideIcons.user, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3227C9)))
          : RefreshIndicator(
              color: const Color(0xFF3227C9),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner de Sesión Activa Resiliente (si hay una en curso)
                    if (_activeSession != null && !_activeSession!.isFinished) ...[
                      _buildActiveSessionBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Tarjeta de Lanzamiento Rápido (< 5 toques - Req. 4)
                    _buildQuickLaunchCard(),
                    const SizedBox(height: 20),

                    // Barra de Filtros por Prioridad
                    _buildPriorityFilterBar(),
                    const SizedBox(height: 16),

                    // Título de la lista
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mis Tareas (${_filteredTasks.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E2F),
                          ),
                        ),
                        if (widget.onNavigateToNewTask != null)
                          TextButton.icon(
                            onPressed: widget.onNavigateToNewTask,
                            icon: const Icon(LucideIcons.plus, size: 16, color: Color(0xFF3227C9)),
                            label: const Text(
                              'Nueva',
                              style: TextStyle(color: Color(0xFF3227C9), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Lista de Tareas
                    if (_filteredTasks.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildTaskCard(_filteredTasks[index]);
                        },
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  /// Banner de sesión activa persistida en segundo plano (Req. 5)
  Widget _buildActiveSessionBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3227C9), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3227C9).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.clock, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'SESIÓN EN CURSO',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _activeSession!.taskTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _resumeActiveSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3227C9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Reanudar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de Lanzamiento Rápido: Comienza en 1 solo toque (Req. 4)
  Widget _buildQuickLaunchCard() {
    final quickTask = _tasks.isNotEmpty ? _tasks.first : null;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.zap, color: Color(0xFF3227C9), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lanzamiento Rápido (< 5 toques)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1E2F),
                      ),
                    ),
                    Text(
                      'Inicia de inmediato tu próxima sesión de estudio',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B6E82)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (quickTask != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECF8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quickTask.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E2F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${quickTask.durationMinutes} min • Objetivo: ${quickTask.goal}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _startFocusSession(quickTask),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3227C9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(LucideIcons.play, size: 15),
                    label: const Text('Iniciar (1 toque)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, size: 16, color: Color(0xFF3227C9)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Crea tu primera tarea para habilitar el inicio en 1 toque.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4338CA)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriorityFilterBar() {
    final filters = ['Todas', 'Alta', 'Media', 'Baja'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedPriorityFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(f),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF5A5D72),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF3227C9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF3227C9) : const Color(0xFFE9ECF8),
                ),
              ),
              onSelected: (val) {
                setState(() {
                  _selectedPriorityFilter = f;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityBg;
    Color priorityText;
    Color priorityBorder;

    switch (task.priority) {
      case 'Alta':
        priorityBg = const Color(0xFFFEF2F2);
        priorityText = const Color(0xFFBA1A1A);
        priorityBorder = const Color(0xFFFECACA);
        break;
      case 'Media':
        priorityBg = const Color(0xFFFFFBEB);
        priorityText = const Color(0xFFD97706);
        priorityBorder = const Color(0xFFFDE68A);
        break;
      default:
        priorityBg = const Color(0xFFEFF6FF);
        priorityText = const Color(0xFF2563EB);
        priorityBorder = const Color(0xFFBFDBFE);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9ECF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E2F),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: priorityBorder),
                ),
                child: Text(
                  task.priority,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: priorityText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.target, size: 12, color: Color(0xFF3227C9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.goal,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B4F69),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEFD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.clock, size: 12, color: Color(0xFF3227C9)),
                            const SizedBox(width: 4),
                            Text(
                              '${task.durationMinutes} min',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3227C9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (task.blockDistractions) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.shieldCheck, size: 12, color: Color(0xFF059669)),
                              const SizedBox(width: 4),
                              Text(
                                '${task.blockedApps.length} apps',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, size: 17, color: Color(0xFFBA1A1A)),
                    tooltip: 'Eliminar tarea',
                    onPressed: () => _deleteTask(task),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _startFocusSession(task),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3227C9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(LucideIcons.play, size: 14),
                    label: const Text('Iniciar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
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
            child: const Icon(LucideIcons.checkSquare, color: Color(0xFF3227C9), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay tareas en esta categoría',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E2F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea una nueva tarea para iniciar tus sesiones de estudio y concentración.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
