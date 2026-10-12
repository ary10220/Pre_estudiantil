import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/filtros.dart';
import 'package:ihcpre_estudiantil2/modelos/movimiento.dart';

void main() {
  group('FiltrosMovimientos', () {
    test('sin filtros no hay parámetros ni chips', () {
      const filtros = FiltrosMovimientos();
      expect(filtros.hayFiltros, false);
      expect(filtros.toQuery(), isEmpty);
      expect(filtros.activos, isEmpty);
    });

    test('combina búsqueda y filtros en la consulta', () {
      final filtros = FiltrosMovimientos(
        buscar: '  almuerzo ',
        tipo: TipoMovimiento.gasto,
        categoria: CategoriaMovimiento.comida,
        estado: EstadoMovimiento.pendiente,
        periodo: PeriodoFiltro.esteMes,
      );
      expect(filtros.toQuery(), {
        'buscar': 'almuerzo',
        'tipo': 'gasto',
        'categoria': 'comida',
        'estado': 'pendiente',
        'periodo': 'este_mes',
      });
    });

    test('el rango de fechas viaja como AAAA-MM-DD', () {
      final filtros = FiltrosMovimientos(
        periodo: PeriodoFiltro.rango,
        desde: DateTime(2026, 10, 1),
        hasta: DateTime(2026, 10, 31),
      );
      expect(filtros.toQuery(), {
        'periodo': 'rango',
        'desde': '2026-10-01',
        'hasta': '2026-10-31',
      });
    });

    test('los filtros activos se muestran como chips en orden', () {
      final filtros = FiltrosMovimientos(
        buscar: 'café',
        tipo: TipoMovimiento.gasto,
        periodo: PeriodoFiltro.esteMes,
      );
      expect(
        filtros.activos.map((a) => a.texto).toList(),
        ['Búsqueda: "café"', 'Gasto', 'Este mes'],
      );
    });

    test('quitar un filtro deja los demás', () {
      final filtros = FiltrosMovimientos(
        tipo: TipoMovimiento.gasto,
        categoria: CategoriaMovimiento.comida,
      ).quitar(ClaveFiltro.tipo);
      expect(filtros.tipo, null);
      expect(filtros.categoria, CategoriaMovimiento.comida);
    });

    test('quitar el periodo también limpia las fechas del rango', () {
      final filtros = FiltrosMovimientos(
        periodo: PeriodoFiltro.rango,
        desde: DateTime(2026, 10, 1),
        hasta: DateTime(2026, 10, 31),
      ).quitar(ClaveFiltro.periodo);
      expect(filtros.hayFiltros, false);
      expect(filtros.toQuery(), isEmpty);
    });

    test('valida el rango de fechas', () {
      expect(
        const FiltrosMovimientos(periodo: PeriodoFiltro.rango).validar(),
        mensajeRangoIncompleto,
      );
      expect(
        FiltrosMovimientos(
          periodo: PeriodoFiltro.rango,
          desde: DateTime(2026, 10, 9),
          hasta: DateTime(2026, 10, 1),
        ).validar(),
        mensajeRangoInvertido,
      );
      expect(
        FiltrosMovimientos(
          periodo: PeriodoFiltro.rango,
          desde: DateTime(2026, 10, 1),
          hasta: DateTime(2026, 10, 9),
        ).validar(),
        null,
      );
      expect(const FiltrosMovimientos(periodo: PeriodoFiltro.esteMes).validar(), null);
    });

    test('los totales se leen de lo que devuelve el servidor', () {
      final totales = TotalesMovimientos.desdeJson(
        {'cantidad': 3, 'ingresos': 0, 'gastos': 36.6},
      );
      expect(totales.cantidad, 3);
      expect(totales.ingresos, 0.0);
      expect(totales.gastos, 36.6);
    });
  });

  group('Movimiento con tipo y categoría', () {
    test('lee el tipo y la categoría desde el servidor', () {
      final m = Movimiento.desdeJson({
        'id': 1,
        'concepto': 'Beca',
        'monto': 500,
        'fecha': '2026-10-01',
        'tipo': 'ingreso',
        'categoria': 'estudio',
        'estado': 'pagado',
      });
      expect(m.tipo, TipoMovimiento.ingreso);
      expect(m.categoria, CategoriaMovimiento.estudio);
    });

    test('pagar y editar conservan el tipo; editar puede cambiar la categoría', () {
      final m = Movimiento(
        id: 1,
        concepto: 'Almuerzo',
        monto: 25,
        fecha: DateTime(2026, 10, 9),
        tipo: TipoMovimiento.ingreso,
        categoria: CategoriaMovimiento.comida,
      );
      final pagado = m.marcarComoPagado();
      expect(pagado.tipo, TipoMovimiento.ingreso);
      expect(pagado.categoria, CategoriaMovimiento.comida);

      final editado = pagado.editar(
        concepto: 'Almuerzo',
        monto: 25,
        fecha: DateTime(2026, 10, 9),
        categoria: CategoriaMovimiento.otros,
      );
      expect(editado.tipo, TipoMovimiento.ingreso);
      expect(editado.categoria, CategoriaMovimiento.otros);
    });
  });
}