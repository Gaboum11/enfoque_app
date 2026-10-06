/// Utilidades de validación para el formulario de tareas y enfoque
/// Cada función es una función pura que devuelve `null` si el valor es válido,
/// o un mensaje descriptivo de error en caso de que sea inválido.
class FormValidators {
  /// Validador para el Campo 1: Título de la tarea
  /// - Rechaza valores nulos, vacíos o que solo contengan espacios.
  /// - Rechaza longitud menor a 3 caracteres.
  /// - Rechaza longitud mayor a 50 caracteres para evitar desbordes visuales.
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el título de la tarea';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }
    if (trimmed.length > 50) {
      return 'El título no puede superar los 50 caracteres';
    }
    return null;
  }

  /// Validador para el Campo 2: Declaración del objetivo ("¿Qué quieres lograr exactamente?")
  /// - Rechaza valores nulos o vacíos.
  /// - Rechaza metas ambiguas o monosilábicas (mínimo 10 caracteres).
  /// - Rechaza metas excesivamente largas (>300 caracteres).
  static String? validateGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Declara qué quieres lograr en esta sesión';
    }
    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Sé más específico: escribe al menos 10 caracteres';
    }
    if (trimmed.length > 300) {
      return 'El objetivo no puede superar los 300 caracteres';
    }
    return null;
  }

  /// Validador para el Campo 3: Duración estimada de la sesión en minutos
  /// - Rechaza valores vacíos.
  /// - Rechaza formatos no enteros (letras, símbolos, números decimales).
  /// - Rechaza sesiones no realistas para la concentración (menor a 5 min o mayor a 180 min / 3 horas).
  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa la duración estimada';
    }
    final trimmed = value.trim();
    final number = int.tryParse(trimmed);
    if (number == null) {
      return 'Ingresa un número entero válido (sin letras ni decimales)';
    }
    if (number < 5 || number > 180) {
      return 'La duración debe estar entre 5 y 180 minutos';
    }
    return null;
  }

  /// Validador para el Campo 4 (Selector de apps bloqueadas)
  /// - Si el bloqueo estricto está activado, exige seleccionar al menos una app.
  static String? validateBlockedApps({
    required bool isBlockingEnabled,
    required List<String> apps,
  }) {
    if (isBlockingEnabled && apps.isEmpty) {
      return 'Debes seleccionar al menos una app para bloquear';
    }
    return null;
  }
}
