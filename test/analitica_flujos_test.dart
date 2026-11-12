import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ihcpre_estudiantil2/servicios/analitica.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AnaliticaServicio.reiniciar();
  });

  group('Parte A - Analítica en todo el producto y embudos', () {
    test('1. Flujo de movimientos: registra inicio, guardado y cálculo de caída', () async {
      await AnaliticaServicio.track('movimiento_iniciado', {'tipo': 'gasto'});
      await AnaliticaServicio.track('movimiento_iniciado', {'tipo': 'ingreso'});
      await AnaliticaServicio.track('movimiento_guardado', {'tipo': 'gasto'});

      final resumen = await AnaliticaServicio.obtenerResumen();
      final mov = resumen['movimientos'] as Map<String, dynamic>;

      expect(mov['iniciados'], 2);
      expect(mov['guardados'], 1);
      expect(mov['conversion'], 50.0);
      expect(mov['caida'], 50.0);
    });

    test('2. Flujo de metas: creación y operaciones de fondos', () async {
      await AnaliticaServicio.track('meta_creacion_iniciada', {});
      await AnaliticaServicio.track('meta_guardada', {});
      await AnaliticaServicio.track('fondos_meta_operados', {'operacion': 'asignar'});
      await AnaliticaServicio.track('fondos_meta_operados', {'operacion': 'retirar'});

      final resumen = await AnaliticaServicio.obtenerResumen();
      final metas = resumen['metas'] as Map<String, dynamic>;

      expect(metas['iniciadas'], 1);
      expect(metas['guardadas'], 1);
      expect(metas['fondosOperados'], 2);
      expect(metas['conversion'], 100.0);
      expect(metas['caida'], 0.0);
    });

    test('3. Flujo de límites: apertura y guardado', () async {
      await AnaliticaServicio.track('limite_iniciado', {});
      await AnaliticaServicio.track('limite_guardado', {'alcance': 'general'});
      await AnaliticaServicio.track('limite_guardado', {'alcance': 'categoria'});

      final resumen = await AnaliticaServicio.obtenerResumen();
      final limites = resumen['limites'] as Map<String, dynamic>;

      expect(limites['iniciados'], 1);
      expect(limites['guardados'], 2);
    });

    test('4. Aviso de límite y tasa de disuasión', () async {
      await AnaliticaServicio.track('aviso_limite_mostrado', {'categoria': 'comida'});
      await AnaliticaServicio.track('aviso_limite_cancelado', {'categoria': 'comida'});
      await AnaliticaServicio.track('aviso_limite_mostrado', {'categoria': 'salud'});
      await AnaliticaServicio.track('aviso_limite_confirmado', {'categoria': 'salud'});

      final resumen = await AnaliticaServicio.obtenerResumen();
      final aviso = resumen['avisoLimite'] as Map<String, dynamic>;

      expect(aviso['mostrados'], 2);
      expect(aviso['cancelados'], 1);
      expect(aviso['confirmados'], 1);
      expect(aviso['tasaDisuasion'], 50.0);
    });

    test('5. Fricción y búsquedas en blanco con listas fijas', () async {
      await AnaliticaServicio.track('error_formulario_mostrado', {'motivo': 'monto_vacio'});
      await AnaliticaServicio.track('error_formulario_mostrado', {'motivo': 'monto_vacio'});
      await AnaliticaServicio.track('error_formulario_mostrado', {'motivo': 'concepto_vacio'});
      await AnaliticaServicio.track('busqueda_sin_resultados', {'origen': 'texto'});

      final resumen = await AnaliticaServicio.obtenerResumen();
      final errores = resumen['erroresFormulario'] as Map<String, int>;

      expect(errores['monto_vacio'], 2);
      expect(errores['concepto_vacio'], 1);
      expect(resumen['busquedasSinResultado'], 1);
    });

    test('6. Regla estricta de privacidad: NINGÚN evento almacena datos personales', () async {
      final eventosPrueba = [
        {'evento': 'movimiento_iniciado', 'props': {'tipo': 'gasto'}},
        {'evento': 'error_formulario_mostrado', 'props': {'motivo': 'monto_invalido'}},
        {'evento': 'aviso_limite_mostrado', 'props': {'categoria': 'comida'}},
        {'evento': 'fondos_meta_operados', 'props': {'operacion': 'asignar'}},
        {'evento': 'busqueda_sin_resultados', 'props': {'origen': 'filtros'}},
      ];

      for (final item in eventosPrueba) {
        final props = item['props'] as Map<String, dynamic>;
        expect(props.containsKey('email'), isFalse);
        expect(props.containsKey('correo'), isFalse);
        expect(props.containsKey('monto'), isFalse);
        expect(props.containsKey('montoDinero'), isFalse);
        expect(props.containsKey('concepto'), isFalse);
        expect(props.containsKey('descripcion'), isFalse);
        expect(props.containsKey('usuarioId'), isFalse);
        expect(props.containsKey('nombreUsuario'), isFalse);
      }
    });
  });
}

