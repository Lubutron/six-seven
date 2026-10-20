import 'package:examen/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login muestra validaciones cuando los campos están vacíos', (
    tester,
  ) async {
    await tester.pumpWidget(const CatalogApp());
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });

  testWidgets('login rechaza credenciales incorrectas', (tester) async {
    await tester.pumpWidget(const CatalogApp());
    await tester.enterText(find.byType(TextFormField).first, 'usuario');
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
  });
}
