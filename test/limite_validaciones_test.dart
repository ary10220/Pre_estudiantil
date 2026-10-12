import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/limite.dart';

void main() {
  test('permitido: "500", "500.50" y "500,50" son válidos', () {
    expect(validarMontoLimite('500'), null);
    expect(validarMontoLimite('500.50'), null);
    expect(validarMontoLimite('500,50'), null);
    expect(leerLimite('500,50'), 500.5);
  });

  test('rechazado: vacío', () {
    expect(validarMontoLimite('  '), 'Escribí el límite');
  });

  test('rechazado: 0, negativo o con letras', () {
    for (final valor in ['0', '-10', 'abc']) {
      expect(validarMontoLimite(valor), 'El límite debe ser un número mayor a 0');
    }
  });

  test('rechazado: más de 2 decimales', () {
    expect(validarMontoLimite('10.555'), 'Usá como máximo 2 decimales');
  });

  test('resumen: barra y aviso al pasar el 80 %', () {
    final bajo = ResumenLimite.desdeJson({'limite': 500, 'gastado': 400, 'restante': 100});
    final alto = ResumenLimite.desdeJson({'limite': 500, 'gastado': 450, 'restante': 50});
    expect(bajo.proporcion, 0.8);
    expect(bajo.enAviso, false);
    expect(alto.enAviso, true);
  });

  test('resumen: sin límite no hay tarjeta', () {
    final sinLimite = ResumenLimite.desdeJson({'limite': null, 'gastado': 80, 'restante': null});
    expect(sinLimite.tieneLimite, false);
    expect(formatearBs(25.5), 'Bs 25,50');
  });
}
