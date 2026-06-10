import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:indriver_clone_flutter/main.dart' as app;

void main() {
  // Inicializa el driver de pruebas de integración de Flutter
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Aceptación E2E - Flujo de Login y Navegación (RF-001)', () {
    testWidgets('Debe iniciar sesión correctamente con credenciales válidas y entrar al panel principal', (WidgetTester tester) async {
      // 1. Arranca la aplicación
      app.main();
      await tester.pumpAndSettle(); // Espera a que termine la animación de carga

      // 2. Busca los campos de texto e interactúa
      // Nota: Reemplazar 'EmailTextField' y 'PasswordTextField' con las llaves (Keys) reales usadas en tu UI
      final Finder emailField = find.byKey(const Key('email_field'));
      final Finder passwordField = find.byKey(const Key('password_field'));
      final Finder loginButton = find.byKey(const Key('btn_login'));

      // 3. Escribe las credenciales institucionales de prueba
      await tester.enterText(emailField, 'estudiante@uta.edu.ec');
      await tester.enterText(passwordField, 'Pass1234*');
      await tester.pumpAndSettle(); // Procesa el texto escrito

      // 4. Presiona el botón de inicio de sesión
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Espera la respuesta de la API

      // 5. Verifica que fuimos redirigidos al Panel Principal o Pantalla de Viajes
      // Buscamos un widget característico del panel de control
      expect(find.text('Buscar Viajes'), findsOneWidget);
    });
  });
}
