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
    expect(validarMontoLimite('  '), 'Escribe el límite');
  });

  test('rechazado: 0, negativo o con letras', () {
    for (final valor in ['0', '-10', 'abc']) {
      expect(validarMontoLimite(valor), 'El límite debe ser un número mayor a 0');
    }
  });

  test('rechazado: más de 2 decimales', () {
    expect(validarMontoLimite('10.555'), 'Usa como máximo 2 decimales');
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

  // Clase 15 · hallazgo 1: confirmación junto al botón
  test('confirmación: monto con decimales y coma', () {
    final r = ResumenLimite.desdeJson(
        {'mes': '2026-10', 'limite': 500.5, 'gastado': 300, 'restante': 200.5});
    expect(textoConfirmacionLimite(r),
        'Límite guardado: Bs 500,50 para octubre · Te quedan Bs 200,50');
  });

  test('confirmación: nombre del mes en español', () {
    expect(nombreMes('2026-01'), 'enero');
    expect(nombreMes('2026-09'), 'septiembre');
    expect(nombreMes('2026-12'), 'diciembre');
  });

  test('confirmación: restante en 0', () {
    final r = ResumenLimite.desdeJson(
        {'mes': '2026-10', 'limite': 300, 'gastado': 300, 'restante': 0});
    expect(textoConfirmacionLimite(r),
        'Límite guardado: Bs 300,00 para octubre · Te quedan Bs 0,00');
  });

  // H5.1 (#19): cuánto queda del límite en el formulario
  final octubre = ResumenLimite.desdeJson(
      {'mes': '2026-10', 'limite': 600, 'gastado': 300, 'restante': 300});

  test('aviso del gasto: sin monto muestra lo que queda', () {
    final aviso = avisoGasto(octubre, null);
    expect(aviso.texto, 'Te quedan Bs 300,00 en octubre.');
    expect(aviso.seExcede, false);
  });

  test('aviso del gasto: un monto que entra dice cuánto quedaría', () {
    final aviso = avisoGasto(octubre, 120.5);
    expect(aviso.texto, 'Te quedan Bs 300,00 en octubre. Con este gasto te quedarían Bs 179,50.');
    expect(aviso.seExcede, false);
    expect(avisoGasto(octubre, 300).seExcede, false);
  });

  test('aviso del gasto: un monto que no entra avisa por cuánto se pasa', () {
    final aviso = avisoGasto(octubre, 400);
    expect(aviso.texto, 'Te quedan Bs 300,00 en octubre. Con este gasto te pasarías por Bs 100,00.');
    expect(aviso.seExcede, true);
  });

  test('aviso del gasto: al editar, el monto anterior vuelve a estar disponible', () {
    final aviso = avisoGasto(octubre, 400, montoAnterior: 150);
    expect(aviso.texto, 'Te quedan Bs 450,00 en octubre. Con este gasto te quedarían Bs 50,00.');
    expect(aviso.seExcede, false);
  });
}
