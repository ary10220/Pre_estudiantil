import 'package:flutter_test/flutter_test.dart';
import 'package:app/flujos/movimientos/servicios/validaciones.dart';

void main() {
  test('Concepto: vacío, corto, largo y bien', () {
    expect(validarConcepto('   '), 'Escribí el concepto');
    expect(validarConcepto('A'), 'El concepto debe tener entre 2 y 40 letras');
    expect(validarConcepto('a' * 41), 'El concepto debe tener entre 2 y 40 letras');
    expect(validarConcepto('Transporte'), null);
  });

  test('Monto: mismos mensajes que el backend', () {
    expect(validarMonto(''), 'Escribí el monto');
    expect(validarMonto('0'), 'El monto debe ser un número mayor a 0');
    expect(validarMonto('-5'), 'El monto debe ser un número mayor a 0');
    expect(validarMonto('abc'), 'El monto debe ser un número mayor a 0');
    expect(validarMonto('2.555'), 'Usá como máximo 2 decimales');
    expect(validarMonto('100000.01'), 'El monto no puede pasar de Bs 100000');
    expect(validarMonto('25'), null);
    expect(validarMonto('25,50'), null);
    expect(leerMonto('25,50'), 25.5);
  });
}
