import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/task_model.dart';
import '../models/session_model.dart';
import '../services/task_service.dart';
import '../utils/form_validators.dart';
import 'focus_session_screen.dart';

/// Modelo de presentación para etiquetas modernas con iconos vectoriales de diseño
class TagBadgeItem {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  bool isSelected;

  TagBadgeItem({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.isSelected = true,
  });
}

class TaskFormScreen extends StatefulWidget {
  final bool showBottomNav;

  const TaskFormScreen({
    super.key,
    this.showBottomNav = false,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // Clave global para identificar y validar el Formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;
  late final TextEditingController _durationController;

  // Estados del formulario
  double _durationSliderValue = 45;
  String _selectedPriority = 'Alta';
  bool _blockDistractions = true;
  String? _appsErrorMessage;

  // Lista de etiquetas con iconos vectoriales profesionales Lucide
  final List<TagBadgeItem> _availableTags = [
    TagBadgeItem(
      label: 'Proyecto',
      icon: LucideIcons.laptop,
      backgroundColor: const Color(0xFFEEF2FF),
      textColor: const Color(0xFF4338CA),
      borderColor: const Color(0xFFC7D2FE),
      isSelected: true,
    ),
    TagBadgeItem(
      label: 'Informe',
      icon: LucideIcons.fileText,
      backgroundColor: const Color(0xFFF5F3FF),
      textColor: const Color(0xFF6D28D9),
      borderColor: const Color(0xFFDDD6FE),
      isSelected: true,
    ),
    TagBadgeItem(
      label: 'Urgente',
      icon: LucideIcons.zap,
      backgroundColor: const Color(0xFFFEF2F2),
      textColor: const Color(0xFFDC2626),
      borderColor: const Color(0xFFFECACA),
      isSelected: true,
    ),
    TagBadgeItem(
      label: 'Estudio',
      icon: LucideIcons.bookOpen,
      backgroundColor: const Color(0xFFECFDF5),
      textColor: const Color(0xFF047857),
      borderColor: const Color(0xFFA7F3D0),
      isSelected: false,
    ),
    TagBadgeItem(
      label: 'Examen',
      icon: LucideIcons.target,
      backgroundColor: const Color(0xFFFFFBEB),
      textColor: const Color(0xFFB45309),
      borderColor: const Color(0xFFFDE68A),
      isSelected: false,
    ),
  ];

  // Lista de apps distractoras disponibles
  final List<BlockedAppItem> _availableApps = [
    BlockedAppItem(name: 'Instagram', packageName: 'com.instagram.android', isBlocked: true),
    BlockedAppItem(name: 'TikTok', packageName: 'com.zhiliaoapp.musically', isBlocked: true),
    BlockedAppItem(name: 'Twitter / X', packageName: 'com.twitter.android', isBlocked: true),
    BlockedAppItem(name: 'YouTube', packageName: 'com.google.android.youtube', isBlocked: true),
  ];

  // Presets rápidos de duración
  final List<int> _presetDurations = [15, 25, 45, 60];

  // Conteo en tiempo real de caracteres para retroalimentación visual
  int _titleLength = 32;
  int _goalLength = 85;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Finalizar informe de métricas Q2');
    _goalController = TextEditingController(
      text: 'Completar el análisis de retención de usuarios y redactar las 3 conclusiones clave.',
    );
    _durationController = TextEditingController(text: '45');

    _titleLength = _titleController.text.trim().length;
    _goalLength = _goalController.text.trim().length;

    _titleController.addListener(() {
      setState(() {
        _titleLength = _titleController.text.trim().length;
      });
    });

    _goalController.addListener(() {
      setState(() {
        _goalLength = _goalController.text.trim().length;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Sincroniza la duración seleccionada
  void _setDuration(int minutes) {
    setState(() {
      _durationSliderValue = minutes.toDouble().clamp(5, 180);
      _durationController.text = minutes.toString();
    });
  }

  // Calcula hora estimada de finalización
  String _getEstimatedEndTime(int minutes) {
    final now = DateTime.now();
    final end = now.add(Duration(minutes: minutes));
    final hour = end.hour > 12 ? end.hour - 12 : (end.hour == 0 ? 12 : end.hour);
    final period = end.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = end.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

  // Obtiene nombres de las apps actualmente bloqueadas
  List<String> get _selectedAppNames => _availableApps
      .where((app) => app.isBlocked)
      .map((app) => app.name)
      .toList();

  // Obtiene etiquetas seleccionadas
  List<String> get _selectedTags => _availableTags
      .where((t) => t.isSelected)
      .map((t) => t.label)
      .toList();

  // Acción de guardar y validar el formulario
  void _submitForm({required bool startFocusMode}) {
    // 1. Validar campos estándar mediante Form y GlobalKey
    final isFormValid = _formKey.currentState!.validate();

    // 2. Validar regla de apps bloqueadas
    final appsError = FormValidators.validateBlockedApps(
      isBlockingEnabled: _blockDistractions,
      apps: _selectedAppNames,
    );

    setState(() {
      _appsErrorMessage = appsError;
    });

    if (!isFormValid || appsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Datos inválidos: Revisa los campos marcados en rojo antes de guardar.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Datos válidos: Crear objeto de tarea
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      goal: _goalController.text.trim(),
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 25,
      priority: _selectedPriority,
      tags: _selectedTags,
      blockDistractions: _blockDistractions,
      blockedApps: _selectedAppNames,
    );

    // Persistir localmente de forma 100% offline
    TaskService.instance.saveTask(task);

    _showSuccessDialog(task, startFocusMode: startFocusMode);
  }

  // Muestra diálogo modal con los datos guardados de forma 100% offline
  void _showSuccessDialog(Task task, {required bool startFocusMode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.checkCircle2, color: Color(0xFF059669), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Tarea Guardada Localmente!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        startFocusMode
                            ? 'Iniciando sesión de enfoque de ${task.durationMinutes} min (Terminas ${_getEstimatedEndTime(task.durationMinutes)})'
                            : 'Almacenada con éxito en la lista offline',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECF8)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 18, color: Color(0xFF3227C9)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al finalizar la sesión, se te preguntará si cumpliste el objetivo para registrarlo en el historial.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4338CA), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow('Título', task.title),
            _buildSummaryRow('Objetivo', task.goal),
            _buildSummaryRow('Duración', '${task.durationMinutes} minutos'),
            _buildSummaryRow('Prioridad', task.priority),
            _buildSummaryRow('Etiquetas', task.tags.isEmpty ? 'Ninguna' : task.tags.map((t) => '#$t').join(', ')),
            _buildSummaryRow(
              'Bloqueo',
              task.blockDistractions
                  ? '${task.blockedApps.length} apps silenciadas (${task.blockedApps.join(', ')})'
                  : 'Desactivado',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (startFocusMode) {
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
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3227C9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  startFocusMode ? 'Comenzar Sesión' : 'Listo',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5A5D72))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E1E2F))),
          ),
        ],
      ),
    );
  }

  // Diálogo interactivo con selector de iconos Lucide vectoriales
  void _showAddTagDialog() {
    final tagCtrl = TextEditingController();
    IconData selectedIcon = LucideIcons.bookOpen;
    final availableIcons = [
      LucideIcons.bookOpen,
      LucideIcons.laptop,
      LucideIcons.fileText,
      LucideIcons.zap,
      LucideIcons.target,
      LucideIcons.flaskConical,
      LucideIcons.palette,
      LucideIcons.bookmark,
      LucideIcons.calculator,
      LucideIcons.penTool,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nueva Etiqueta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona un icono vectorial:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5A5D72)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableIcons.map((iconData) {
                  final isSel = selectedIcon == iconData;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setDlgState(() => selectedIcon = iconData),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFECEEFD) : const Color(0xFFF3F4F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? const Color(0xFF3227C9) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(iconData, size: 18, color: isSel ? const Color(0xFF3227C9) : const Color(0xFF5A5D72)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nombre (ej. Matemáticas)',
                  prefixText: '#',
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final newTag = tagCtrl.text.trim().replaceAll('#', '');
                if (newTag.isNotEmpty && !_availableTags.any((t) => t.label.toLowerCase() == newTag.toLowerCase())) {
                  setState(() {
                    _availableTags.add(
                      TagBadgeItem(
                        label: newTag,
                        icon: selectedIcon,
                        backgroundColor: const Color(0xFFEEF2FF),
                        textColor: const Color(0xFF4338CA),
                        borderColor: const Color(0xFFC7D2FE),
                        isSelected: true,
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3227C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para gestionar/seleccionar apps bloqueadas
  void _showManageAppsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(LucideIcons.shieldCheck, color: Color(0xFF3227C9), size: 20),
                SizedBox(width: 8),
                Text('Apps a Bloquear', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableApps.length,
                itemBuilder: (context, index) {
                  final app = _availableApps[index];
                  return CheckboxListTile(
                    value: app.isBlocked,
                    activeColor: const Color(0xFF3227C9),
                    title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(app.packageName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onChanged: (val) {
                      setDialogState(() {
                        app.isBlocked = val ?? false;
                      });
                      setState(() {
                        _appsErrorMessage = null;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Listo', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
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
              'Nueva',
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
                  '100% OFFLINE / LOCAL',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la Sección
                _buildHeaderCard(),
                const SizedBox(height: 20),

                // 1. Campo: Título de la tarea
                _buildTitleField(),
                const SizedBox(height: 20),

                // 2. Campo: ¿Qué quieres lograr exactamente?
                _buildGoalField(),
                const SizedBox(height: 20),

                // 3. Campo: Duración de la sesión
                _buildDurationField(),
                const SizedBox(height: 20),

                // 4. Selector de Prioridad Rediseñado
                _buildPrioritySection(),
                const SizedBox(height: 20),

                // 5. Selector de Etiquetas con Iconos Vectoriales Lucide
                _buildTagsSection(),
                const SizedBox(height: 20),

                // 6. Tarjeta: Bloqueo de distracciones
                _buildDistractionBlockCard(),
                const SizedBox(height: 28),

                // Botón Principal: Guardar e Iniciar Enfoque
                _buildPrimaryButton(),
                const SizedBox(height: 12),

                // Botón Secundario: Solo Guardar en Lista
                _buildSecondaryButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNav ? _buildBottomNavigationBar() : null,
    );
  }

  // Tarjeta informativa "Crear Nueva Tarea"
  Widget _buildHeaderCard() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear Nueva Tarea',
                style: TextStyle(
                  color: Color(0xFF1E1E2F),
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.smartphone, size: 14, color: Color(0xFF6B6E82)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Tus datos se guardan de forma local en tu dispositivo',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFECEEFD),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.fileEdit, color: Color(0xFF3227C9), size: 18),
        ),
      ],
    );
  }

  // 1. Campo: Título de la tarea con TextFormField y validación
  Widget _buildTitleField() {
    final isValid = _titleLength >= 3 && _titleLength <= 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'Título de la tarea ',
                  style: TextStyle(
                    color: Color(0xFF1E1E2F),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(LucideIcons.pencil, color: Color(0xFF9E9EAF), size: 17),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          validator: FormValidators.validateTitle,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E2F), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Ej. Finalizar informe de métricas Q2',
            hintStyle: const TextStyle(color: Color(0xFFA5A7B8)),
            filled: true,
            fillColor: const Color(0xFFF3F4F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE9ECF8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3227C9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isValid ? LucideIcons.checkCircle : LucideIcons.info,
              size: 15,
              color: isValid ? const Color(0xFF3227C9) : const Color(0xFF757588),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Mínimo 3 caracteres (Actual: $_titleLength caracteres ${isValid ? '✓' : ''})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isValid ? const Color(0xFF3227C9) : const Color(0xFF757588),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Campo: Objetivo detallado con sugerencias vectoriales limpias
  Widget _buildGoalField() {
    final isValid = _goalLength >= 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: '¿Qué quieres lograr exactamente? ',
                  style: TextStyle(
                    color: Color(0xFF1E1E2F),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(LucideIcons.flag, color: Color(0xFF9E9EAF), size: 17),
          ],
        ),
        const SizedBox(height: 6),
        // Badge de ayuda metodológica
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECEEFD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.compass, size: 13, color: Color(0xFF3227C9)),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Mínimo 10 caracteres para evitar metas vagas',
                  style: TextStyle(
                    color: Color(0xFF3227C9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _goalController,
          validator: FormValidators.validateGoal,
          minLines: 3,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E1E2F), height: 1.4),
          decoration: InputDecoration(
            hintText: 'Ej. Completar el análisis de retención de usuarios y redactar las 3 conclusiones clave.',
            hintStyle: const TextStyle(color: Color(0xFFA5A7B8)),
            filled: true,
            fillColor: const Color(0xFFF3F4F9),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE9ECF8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3227C9), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isValid ? LucideIcons.checkCircle : LucideIcons.info,
              size: 15,
              color: isValid ? const Color(0xFF3227C9) : const Color(0xFF757588),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '$_goalLength caracteres ${isValid ? '✓ (Meta clara y definida)' : '(necesitas mínimo 10)'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isValid ? const Color(0xFF3227C9) : const Color(0xFF757588),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sugerencias amigables con icono vectorial Lucide
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildInspirationChip('Resolver 5 ejercicios'),
              const SizedBox(width: 8),
              _buildInspirationChip('Redactar introducción y conclusiones'),
              const SizedBox(width: 8),
              _buildInspirationChip('Repasar apuntes para examen'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationChip(String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _goalController.text = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECF8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, size: 12, color: Color(0xFF3227C9)),
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF5A5D72), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Campo: Duración de la sesión con Presets, Slider y Hora Estimada
  Widget _buildDurationField() {
    final currentMinutes = int.tryParse(_durationController.text) ?? _durationSliderValue.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'Duración de la sesión ',
                  style: TextStyle(
                    color: Color(0xFF1E1E2F),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECEEFD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$currentMinutes minutos',
                style: const TextStyle(
                  color: Color(0xFF3227C9),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fila de Presets rápidos
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presetDurations.map((mins) {
            final isSelected = currentMinutes == mins;
            final label = mins == 25 ? '25 min Pomodoro' : '$mins min';
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _setDuration(mins),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3227C9) : const Color(0xFFF3F4F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF3227C9) : const Color(0xFFE9ECF8),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E1E2F),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Slider para ajuste fino
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF3227C9),
            inactiveTrackColor: const Color(0xFFE3E6F7),
            thumbColor: const Color(0xFF3227C9),
            overlayColor: const Color(0x223227C9),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          ),
          child: Slider(
            value: _durationSliderValue,
            min: 5,
            max: 180,
            divisions: 35,
            onChanged: (val) {
              setState(() {
                _durationSliderValue = val;
                _durationController.text = val.round().toString();
              });
            },
          ),
        ),

        // Etiquetas inferiores del slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('5 min', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            const Text(
              'Ajuste fino manual',
              style: TextStyle(color: Color(0xFF1E1E2F), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text('180 min (3h)', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),

        // Hora estimada de término con icono Lucide Clock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.clock, size: 14, color: Color(0xFF3227C9)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Si inicias ahora, terminarás a las ${_getEstimatedEndTime(currentMinutes)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3227C9),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Entrada manual TextFormField vinculada para validación estricta
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.timer, size: 16, color: Color(0xFF5A5D72)),
                SizedBox(width: 6),
                Text(
                  'Entrada directa en minutos:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF5A5D72)),
                ),
              ],
            ),
            SizedBox(
              width: 90,
              child: TextFormField(
                controller: _durationController,
                validator: FormValidators.validateDuration,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
                  ),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed >= 5 && parsed <= 180) {
                    setState(() {
                      _durationSliderValue = parsed;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Selector de Prioridad Moderno y Suave con Iconos Lucide
  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Prioridad',
              style: TextStyle(
                color: Color(0xFF1E1E2F),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              'Opcional',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPriorityBadge(
              label: 'Alta',
              icon: LucideIcons.alertTriangle,
              activeBg: const Color(0xFFFEE2E2),
              activeColor: const Color(0xFFB91C1C),
              activeBorder: const Color(0xFFFCA5A5),
            ),
            const SizedBox(width: 10),
            _buildPriorityBadge(
              label: 'Media',
              icon: LucideIcons.equal,
              activeBg: const Color(0xFFFEF3C7),
              activeColor: const Color(0xFFB45309),
              activeBorder: const Color(0xFFFCD34D),
            ),
            const SizedBox(width: 10),
            _buildPriorityBadge(
              label: 'Baja',
              icon: LucideIcons.arrowDown,
              activeBg: const Color(0xFFD1FAE5),
              activeColor: const Color(0xFF047857),
              activeBorder: const Color(0xFF6EE7B7),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityBadge({
    required String label,
    required IconData icon,
    required Color activeBg,
    required Color activeColor,
    required Color activeBorder,
  }) {
    final isSelected = _selectedPriority == label;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedPriority = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : const Color(0xFFF3F4F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeBorder : const Color(0xFFE9ECF8),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? LucideIcons.checkCircle2 : icon,
                size: 15,
                color: isSelected ? activeColor : const Color(0xFF757588),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : const Color(0xFF1E1E2F),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Selector de Etiquetas Rediseñado con Lucide Icons (Minimalista, Sofisticado)
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Etiquetas de estudio',
              style: TextStyle(
                color: Color(0xFF1E1E2F),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              '${_selectedTags.length} seleccionadas',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            ..._availableTags.map((tag) => _buildModernTagChip(tag)),
            // Botón Agregar Tag moderno con icono Lucide Plus
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showAddTagDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3227C9), style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 14, color: Color(0xFF3227C9)),
                    SizedBox(width: 5),
                    Text(
                      'Nueva Etiqueta',
                      style: TextStyle(
                        color: Color(0xFF3227C9),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernTagChip(TagBadgeItem tag) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          tag.isSelected = !tag.isSelected;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: tag.isSelected ? tag.backgroundColor : const Color(0xFFF3F4F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tag.isSelected ? tag.borderColor : const Color(0xFFE5E7EB),
            width: tag.isSelected ? 1.5 : 1,
          ),
          boxShadow: tag.isSelected
              ? [
                  BoxShadow(
                    color: tag.textColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tag.icon, size: 14, color: tag.isSelected ? tag.textColor : const Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              tag.label,
              style: TextStyle(
                color: tag.isSelected ? tag.textColor : const Color(0xFF6B7280),
                fontWeight: tag.isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (tag.isSelected) ...[
              const SizedBox(width: 6),
              Icon(LucideIcons.check, size: 13, color: tag.textColor),
            ],
          ],
        ),
      ),
    );
  }

  // 6. Tarjeta: Bloqueo de distracciones y selector de apps
  Widget _buildDistractionBlockCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _appsErrorMessage != null ? const Color(0xFFBA1A1A) : const Color(0xFFE9ECF8),
          width: _appsErrorMessage != null ? 1.5 : 1,
        ),
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
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFECEEFD),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: const Icon(LucideIcons.shieldAlert, color: Color(0xFF3227C9), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bloqueo de distracciones',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1E1E2F),
                      ),
                    ),
                    Text(
                      'Activar bloqueo estricto (Android Accessibility)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _blockDistractions,
                activeColor: const Color(0xFF3227C9),
                onChanged: (val) {
                  setState(() {
                    _blockDistractions = val;
                    if (!val) _appsErrorMessage = null;
                  });
                },
              ),
            ],
          ),
          if (_blockDistractions) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'APLICACIONES SILENCIADAS (${_selectedAppNames.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Color(0xFF888B9E),
                  ),
                ),
                InkWell(
                  onTap: _showManageAppsDialog,
                  child: const Text(
                    'Gestionar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3227C9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: _availableApps.map((app) {
                return _buildAppItemTile(app);
              }).toList(),
            ),
            if (_appsErrorMessage != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(LucideIcons.alertCircle, size: 14, color: Color(0xFFBA1A1A)),
                  const SizedBox(width: 6),
                  Text(
                    _appsErrorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBA1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAppItemTile(BlockedAppItem app) {
    IconData icon;
    Color iconColor;

    switch (app.name) {
      case 'Instagram':
        icon = LucideIcons.instagram;
        iconColor = const Color(0xFFE1306C);
        break;
      case 'TikTok':
        icon = LucideIcons.music2;
        iconColor = const Color(0xFF25F4EE);
        break;
      case 'Twitter / X':
        icon = LucideIcons.twitter;
        iconColor = const Color(0xFF1DA1F2);
        break;
      case 'YouTube':
        icon = LucideIcons.youtube;
        iconColor = const Color(0xFFFF0000);
        break;
      default:
        icon = LucideIcons.layoutGrid;
        iconColor = const Color(0xFF3227C9);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          app.isBlocked = !app.isBlocked;
          _appsErrorMessage = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: app.isBlocked ? const Color(0xFFF3F4F9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: app.isBlocked ? const Color(0xFFD6DBF8) : const Color(0xFFE9ECF8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                app.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: app.isBlocked ? const Color(0xFF1E1E2F) : Colors.grey.shade500,
                ),
              ),
            ),
            Icon(
              app.isBlocked ? LucideIcons.checkCircle2 : LucideIcons.circle,
              size: 14,
              color: app.isBlocked ? const Color(0xFF3227C9) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Botón Principal: Guardar e Iniciar Enfoque
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _submitForm(startFocusMode: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3227C9),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.playCircle, size: 19),
            SizedBox(width: 8),
            Text(
              'Guardar e Iniciar Enfoque',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Botón Secundario: Solo Guardar en Lista
  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _submitForm(startFocusMode: false),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFECEEFD),
          foregroundColor: const Color(0xFF3227C9),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bookmark, size: 18),
            SizedBox(width: 8),
            Text(
              'Solo Guardar en Lista',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Barra de navegación inferior
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F1F7), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: LucideIcons.checkCircle, label: 'Tareas', isSelected: false),
          _buildNavItem(icon: LucideIcons.plusCircle, label: 'Nueva', isSelected: true),
          _buildNavItem(icon: LucideIcons.target, label: 'Enfoque', isSelected: false),
          _buildNavItem(icon: LucideIcons.lineChart, label: 'Historial', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
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
    );
  }
}
