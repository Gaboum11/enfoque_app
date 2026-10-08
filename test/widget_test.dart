import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enfoque_app/main.dart';
import 'package:enfoque_app/widgets/task_form_screen.dart';
import 'package:enfoque_app/widgets/history_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Verifica renderizado de navegación principal y Dashboard (Req. 4: Inicio < 5 toques)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EnfoqueApp());
    await tester.pumpAndSettle();

    // Comprueba elementos del Dashboard
    expect(find.text('Enfoque'), findsNWidgets(2)); // AppBar y pestaña Enfoque
    expect(find.text('100% OFFLINE • PRIVACIDAD TOTAL'), findsOneWidget);
    expect(find.text('Lanzamiento Rápido (< 5 toques)'), findsOneWidget);
    expect(find.text('Tareas'), findsOneWidget);
    expect(find.text('Nueva'), findsNWidgets(2)); // Botón 'Nueva' en lista y pestaña inferior
    expect(find.text('Historial'), findsOneWidget);

    // Navega a la pestaña 'Nueva'
    await tester.tap(find.text('Nueva').last);
    await tester.pumpAndSettle();

    expect(find.text('Crear Nueva Tarea'), findsOneWidget);
    expect(find.text('Guardar e Iniciar Enfoque'), findsOneWidget);
  });

  testWidgets('Verifica validaciones y rechazo de datos inválidos en TaskFormScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: TaskFormScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Comprueba campos del formulario
    expect(find.text('Crear Nueva Tarea'), findsOneWidget);
    expect(find.text('Guardar e Iniciar Enfoque'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    // Borra el título para dejarlo inválido y presiona guardar
    final titleFinder = find.widgetWithText(TextFormField, 'Finalizar informe de métricas Q2');
    await tester.enterText(titleFinder, '');
    await tester.pumpAndSettle();

    // Presiona el botón de guardar
    final saveButton = find.text('Guardar e Iniciar Enfoque');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Comprueba que el validador del campo rechazó la entrada y mostró el mensaje de error
    expect(find.text('Por favor ingresa el título de la tarea'), findsOneWidget);
    expect(find.text('Datos inválidos: Revisa los campos marcados en rojo antes de guardar.'), findsOneWidget);
  });

  testWidgets('Verifica renderizado de HistoryScreen (Req. 2: Historial y evaluación)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HistoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Historial de Enfoque'), findsOneWidget);
    expect(find.text('100% LOCAL • REGISTRO DE LOGRO'), findsOneWidget);
    expect(find.text('Minutos Totales'), findsOneWidget);
    expect(find.text('Completadas'), findsOneWidget);
  });
}
