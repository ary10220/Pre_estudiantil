import 'package:flutter_test/flutter_test.dart';
import 'package:app/flujos/limite/servicios/validaciones.dart';

void main() {
  test('HU-01 permitido: 500 y 500,50 son válidos', () {
    expect(validarLimite('500'), null);
    expect(validarLimite('500,50'), null);
  });

  test('HU-01 rechazado: vacío, 0, negativo o con letras', () {
    for (final valor in ['', '0', '-10', 'abc']) {
      expect(validarLimite(valor), 'El límite debe ser un número mayor a 0');
    }
  });
}
