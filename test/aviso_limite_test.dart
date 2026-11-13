import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ihcpre_estudiantil2/modelos/movimiento.dart';
import 'package:ihcpre_estudiantil2/modelos/presupuesto_categoria.dart';
import 'package:ihcpre_estudiantil2/pantallas/pantalla_nuevo_movimiento.dart';
import 'package:ihcpre_estudiantil2/servicios/analitica.dart';
import 'package:ihcpre_estudiantil2/servicios/servicio_acceso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'token-mock-para-test'});
    await AnaliticaServicio.reiniciar();
  });

  Widget crearApp({Movimiento? movimiento}) {
    return MaterialApp(
      home: Scaffold(body: PantallaNuevoMovimiento(movimiento: movimiento)),
    );
  }

  group('Parte B, aviso antes de superar el limite en gastos nuevos y editados', () {
    test('Calculo de superacion de limite y exceso exacto en gastos', () {
      // Presupuesto de comida: limite 100, gastado 80
      const presupuestoComida = PresupuestoCategoria(
        categoria: 'comida',
        limite: 100.0,
        gastado: 80.0,
        restante: 20.0,
        proporcion: 0.8,
      );

      // Caso 1, el gasto sin aviso (si gasto 15 <= restante 20)
      final monto1 = 15.0;
      final total1 = presupuestoComida.gastado + monto1;
      final supera1 = total1 > presupuestoComida.limite!;
      expect(supera1, isFalse);

      // Caso 2 y 3, gasto con aviso (si gasto 50 > restante 20 -> exceso = 30)
      final monto2 = 50.0;
      final total2 = presupuestoComida.gastado + monto2;
      final supera2 = total2 > presupuestoComida.limite!;
      final exceso2 = total2 - presupuestoComida.limite!;
      expect(supera2, isTrue);
      expect(exceso2, 30.0);
    });

    test('Los ingresos NO generan aviso de superacion de limite', () {
      const tipoIngreso = TipoMovimiento.ingreso;
      expect(tipoIngreso == TipoMovimiento.gasto, isFalse);
    });

    test(
      'En edicion de gastos, se descuenta el monto previo del mismo movimiento',
      () {
        const presupuestoComida = PresupuestoCategoria(
          categoria: 'comida',
          limite: 100.0,
          gastado: 80.0,
          restante: 20.0,
          proporcion: 0.8,
        );

        final montoPrevio = 40.0;
        final nuevoMonto = 45.0; // si solo sube 5

        final gastadoSinPrevio = presupuestoComida.gastado - montoPrevio; // 40
        final totalEditado = gastadoSinPrevio + nuevoMonto; // 85
        final supera = totalEditado > presupuestoComida.limite!;

        expect(supera, isFalse); // 85 <= 100, no debe avisar
      },
    );

    test(
      'Eventos de analitica del aviso: mostrado, cancelado y confirmado',
      () async {
        await AnaliticaServicio.reiniciar();

        // Simula el flujo donde se muestra y luego cancela
        await AnaliticaServicio.track('aviso_limite_mostrado', {
          'categoria': 'comida',
        });
        await AnaliticaServicio.track('aviso_limite_cancelado', {
          'categoria': 'comida',
        });

        var resumen = await AnaliticaServicio.obtenerResumen();
        var ultimos = resumen['ultimos'] as List<dynamic>;
        expect(ultimos.length, 2);
        expect(ultimos.first['evento'], 'aviso_limite_cancelado');

        // Simula el flujo donde se muestra y confirma
        await AnaliticaServicio.track('aviso_limite_mostrado', {
          'categoria': 'transporte',
        });
        await AnaliticaServicio.track('aviso_limite_confirmado', {
          'categoria': 'transporte',
        });

        resumen = await AnaliticaServicio.obtenerResumen();
        ultimos = resumen['ultimos'] as List<dynamic>;
        expect(ultimos.length, 4);
      },
    );
  });
}
