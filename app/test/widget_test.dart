import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Sin sesión arranca en la bienvenida', (tester) async {
    await tester.pumpWidget(const MiApp(rutaInicial: '/'));
    expect(find.text('Presupuesto Estudiantil'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Ya tengo cuenta'), findsOneWidget);
  });
}
