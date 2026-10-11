import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/movimiento.dart';

void main() {
  Movimiento crearMovimiento() => Movimiento(
    id: 1,
    concepto: 'Fotocopias',
    monto: 25.5,
    fecha: DateTime(2026, 10, 9),
  );

  group('Movimiento - estado pendiente a pagado', () {
    test('el estado inicial es pendiente', () {
      expect(crearMovimiento().estado, EstadoMovimiento.pendiente);
    });

    test('el estado se lee correctamente desde los datos del servidor', () {
      final datos = {
        'id': 7,
        'concepto': 'Pasajes',
        'monto': 10,
        'fecha': '2026-10-01',
      };
      expect(
        Movimiento.desdeJson({...datos, 'estado': 'pendiente'}).estado,
        EstadoMovimiento.pendiente,
      );
      expect(
        Movimiento.desdeJson({...datos, 'estado': 'pagado'}).estado,
        EstadoMovimiento.pagado,
      );
    });

    test('marcarComoPagado cambia el estado de pendiente a pagado', () {
      final pagado = crearMovimiento().marcarComoPagado();
      expect(pagado.estado, EstadoMovimiento.pagado);
    });

    test('marcar como pagado un movimiento ya pagado se rechaza', () {
      final pagado = crearMovimiento().marcarComoPagado();
      expect(() => pagado.marcarComoPagado(), throwsStateError);
    });

    test('marcar como pagado conserva los demás datos', () {
      final original = crearMovimiento();
      final pagado = original.marcarComoPagado();

      expect(pagado.id, original.id);
      expect(pagado.concepto, original.concepto);
      expect(pagado.monto, original.monto);
      expect(pagado.fecha, original.fecha);
    });

    test('el movimiento original no se modifica', () {
      final original = crearMovimiento();
      original.marcarComoPagado();
      expect(original.estado, EstadoMovimiento.pendiente);
    });
  });
}