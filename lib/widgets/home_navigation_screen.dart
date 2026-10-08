import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/session_service.dart';
import '../services/task_service.dart';
import '../models/session_model.dart';
import 'task_list_screen.dart';
import 'task_form_screen.dart';
import 'focus_session_screen.dart';
import 'history_screen.dart';

/// Contenedor Principal de Navegación con BottomNavigationBar
class HomeNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const HomeNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) async {
    if (index == 2) {
      // Pestaña 'Enfoque': Si hay sesión activa, abre esa; si no, toma la primera tarea
      final active = await SessionService.instance.getActiveSession();
      if (active != null && !active.isFinished) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FocusSessionScreen(session: active)),
        );
        return;
      }

      final tasks = await TaskService.instance.getTasks();
      if (tasks.isNotEmpty) {
        final task = tasks.first;
        final newSession = FocusSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: task.id,
          taskTitle: task.title,
          taskGoal: task.goal,
          startedAt: DateTime.now(),
          scheduledMinutes: task.durationMinutes,
          blockedApps: task.blockDistractions ? task.blockedApps : const [],
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FocusSessionScreen(session: newSession)),
        );
        return;
      } else {
        // Redirige a crear tarea
        setState(() => _currentIndex = 1);
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: [
          TaskListScreen(
            onNavigateToNewTask: () {
              setState(() => _currentIndex = 1);
            },
          ),
          const TaskFormScreen(),
          const SizedBox.shrink(), // placeholder for direct focus push
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F1F7), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(index: 0, icon: LucideIcons.checkCircle, label: 'Tareas'),
            _buildNavItem(index: 1, icon: LucideIcons.plusCircle, label: 'Nueva'),
            _buildNavItem(index: 2, icon: LucideIcons.target, label: 'Enfoque'),
            _buildNavItem(index: 3, icon: LucideIcons.lineChart, label: 'Historial'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEFD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF3227C9), size: 20),
              )
            else
              Icon(icon, color: Colors.grey.shade500, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF3227C9) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
