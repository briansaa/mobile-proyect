import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => MaterialApp(
      home: const LoginScreen(),
      routes: {'/home': (_) => const Scaffold(body: Text('HOME'))},
    );

void main() {
  tearDown(() => AuthService().logout());

  testWidgets('login correcto entra a la app (antes se quedaba en el login)', (tester) async {
    await tester.pumpWidget(_app());
    await tester.enterText(find.byType(TextFormField).at(0), 'alumno@correo.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secreta123');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(AuthService().isLoggedIn, isTrue);
  });

  testWidgets('el formulario no envía con campos vacíos', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    expect(find.text('HOME'), findsNothing);
    expect(AuthService().isLoggedIn, isFalse);
  });
}
