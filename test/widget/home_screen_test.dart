// ============================================================================
// TEST SUITE: HomeScreen Widget Tests
// Archivo: test/widget/home_screen_test.dart
// Descripción: Pruebas de widget para HomeScreen
// Fecha: 2026-02-04
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/view/pages/home_screen.dart';

void main() {
  group('Widget: HomeScreen', () {
    // =========================================================================
    // TEST WDG-HS-001: Renderiza correctamente
    // =========================================================================
    testWidgets('WDG-HS-001: debería renderizar sin errores', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-002: Muestra título de bienvenida
    // =========================================================================
    testWidgets('WDG-HS-002: debería mostrar título de bienvenida', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Bienvenido a SymptoLeaf'), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-003: Muestra subtítulo descriptivo
    // =========================================================================
    testWidgets('WDG-HS-003: debería mostrar subtítulo descriptivo', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(
        find.text('Detecta enfermedades en tus plantas de manera rápida y precisa'),
        findsOneWidget,
      );
    });

    // =========================================================================
    // TEST WDG-HS-004: Muestra tarjeta de analizar planta
    // =========================================================================
    testWidgets('WDG-HS-004: debería mostrar tarjeta de analizar planta', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Analizar Planta'), findsOneWidget);
      expect(find.text('Toma una foto o selecciona de galería'), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-005: Muestra tarjeta de asistente virtual
    // =========================================================================
    testWidgets('WDG-HS-005: debería mostrar tarjeta de asistente virtual', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Asistente Virtual'), findsOneWidget);
      expect(find.text('Pregunta sobre cuidados y tratamientos'), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-006: Callback onTabChange funciona
    // =========================================================================
    testWidgets('WDG-HS-006: debería llamar onTabChange al tocar analizar planta', (tester) async {
      // Arrange
      int? tappedTab;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(
              onTabChange: (index) {
                tappedTab = index;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Analizar Planta'));
      await tester.pumpAndSettle();

      // Assert
      expect(tappedTab, equals(1));
    });

    // =========================================================================
    // TEST WDG-HS-007: Contiene iconos esperados
    // =========================================================================
    testWidgets('WDG-HS-007: debería contener iconos de cámara y chat', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-008: Contiene Cards de acciones rápidas
    // =========================================================================
    testWidgets('WDG-HS-008: debería contener Cards de acciones rápidas', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert - debe haber al menos 2 Cards (Analizar y Asistente)
      expect(find.byType(Card), findsAtLeast(2));
    });

    // =========================================================================
    // TEST WDG-HS-009: Es scrolleable
    // =========================================================================
    testWidgets('WDG-HS-009: debería ser scrolleable', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    // =========================================================================
    // TEST WDG-HS-010: Navegación a chat funciona
    // =========================================================================
    testWidgets('WDG-HS-010: debería navegar a /chat al tocar asistente virtual', (tester) async {
      // Arrange
      String? navigatedRoute;
      
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: HomeScreen(),
          ),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Chat Screen')),
            );
          },
        ),
      );

      // Act
      await tester.tap(find.text('Asistente Virtual'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatedRoute, equals('/chat'));
    });
  });
}
