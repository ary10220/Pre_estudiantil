import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/movimiento.dart';

void main() {
  Movimiento pendiente() => Movimiento(
    id: 1,
    concepto: 'Fotocopias',
    monto: 25.5,
    fecha: DateTime(2026, 10, 9),
  );

  Movimiento pagado() => pendiente().marcarComoPagado();

  group('Restricción: un movimiento pagado no permite modificar su monto', () {
    test('un movimiento pendiente permite cambiar el monto', () {
      final editado = pendiente().editar(
        concepto: 'Fotocopias',
        monto: 40,
        fecha: DateTime(2026, 10, 9),
      );
      expect(editado.monto, 40);
    });

    test('un movimiento pagado rechaza cambiar el monto', () {
      expect(
            () => pagado().editar(
          concepto: 'Fotocopias',
          monto: 40,
          fecha: DateTime(2026, 10, 9),
        ),
        throwsA(
          isA<StateError>().having(
                (e) => e.message,
            'mensaje',
            Movimiento.motivoMontoBloqueado,
          ),
        ),
      );
    });

    test('un movimiento pagado sí permite cambiar concepto y fecha', () {
      final editado = pagado().editar(
        concepto: 'Fotocopias de química',
        monto: 25.5,
        fecha: DateTime(2026, 11, 1),
      );
      expect(editado.concepto, 'Fotocopias de química');
      expect(editado.fecha, DateTime(2026, 11, 1));
      expect(editado.monto, 25.5);
    });

    test('editar conserva el id y el estado', () {
      final editado = pagado().editar(
        concepto: 'Otro concepto',
        monto: 25.5,
        fecha: DateTime(2026, 10, 9),
      );
      expect(editado.id, 1);
      expect(editado.estado, EstadoMovimiento.pagado);
    });

    test('montoBloqueado depende del estado', () {
      expect(pendiente().montoBloqueado, false);
      expect(pagado().montoBloqueado, true);
    });
  });
}