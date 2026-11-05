import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/presupuesto_categoria.dart';
import 'package:ihcpre_estudiantil2/configuracion/constantes.dart';

void main() {
  group('PresupuestoCategoria - Estados y cálculos', () {
    test('sin límite: estado sinLimite y valores nulos', () {
      const p = PresupuestoCategoria(
        categoria: 'comida',
        limite: null,
        gastado: 50.0,
        restante: null,
        proporcion: null,
      );

      expect(p.tieneLimite, isFalse);
      expect(p.enAviso, isFalse);
      expect(p.excedido, isFalse);
      expect(p.estado, EstadoPresupuesto.sinLimite);
      expect(p.progresoBarra, 0.0);
      expect(p.porcentajeTexto, '');
    });

    test('estado normal: gasto menor al 80 %', () {
      const p = PresupuestoCategoria(
        categoria: 'comida',
        limite: 200.0,
        gastado: 100.0,
        restante: 100.0,
        proporcion: 0.5,
      );

      expect(p.tieneLimite, isTrue);
      expect(p.enAviso, isFalse);
      expect(p.excedido, isFalse);
      expect(p.estado, EstadoPresupuesto.normal);
      expect(p.colorEstado, Colores.verdeOscuro);
      expect(p.progresoBarra, 0.5);
      expect(p.porcentajeTexto, '50%');
    });

    test('estado aviso: gasto entre 80 % y 100 %', () {
      const p80 = PresupuestoCategoria(
        categoria: 'transporte',
        limite: 100.0,
        gastado: 80.0,
        restante: 20.0,
        proporcion: 0.8,
      );

      expect(p80.enAviso, isTrue);
      expect(p80.excedido, isFalse);
      expect(p80.estado, EstadoPresupuesto.aviso);
      expect(p80.colorEstado, Colores.aviso);
      expect(p80.porcentajeTexto, '80%');

      const p95 = PresupuestoCategoria(
        categoria: 'transporte',
        limite: 100.0,
        gastado: 95.0,
        restante: 5.0,
        proporcion: 0.95,
      );

      expect(p95.enAviso, isTrue);
      expect(p95.excedido, isFalse);
      expect(p95.estado, EstadoPresupuesto.aviso);
    });

    test('estado excedido: gasto superior al 100 %', () {
      const p = PresupuestoCategoria(
        categoria: 'estudio',
        limite: 100.0,
        gastado: 120.0,
        restante: -20.0,
        proporcion: 1.2,
      );

      expect(p.tieneLimite, isTrue);
      expect(p.enAviso, isFalse);
      expect(p.excedido, isTrue);
      expect(p.estado, EstadoPresupuesto.excedido);
      expect(p.colorEstado, Colores.rojo);
      expect(p.progresoBarra, 1.0); // acotado a 1.0 para el LinearProgressIndicator
      expect(p.porcentajeTexto, '120%');
    });

    test('desdeJson: parseo correcto de tipos numéricos', () {
      final json = {
        'categoria': 'comida',
        'limite': 350,
        'gastado': 175.5,
        'restante': 174.5,
        'proporcion': 0.501,
      };

      final p = PresupuestoCategoria.desdeJson(json);
      expect(p.categoria, 'comida');
      expect(p.limite, 350.0);
      expect(p.gastado, 175.5);
      expect(p.restante, 174.5);
      expect(p.nombreLegible, 'Comida');
    });
  });
}

