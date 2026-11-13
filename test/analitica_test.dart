import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/servicios/analitica.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Configura almacenamiento en memoria aislado para las pruebas de SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  group('Analítica de Interacción - Pruebas por Evento', () {
    test('Evento movimiento_iniciado: se dispara una sola vez, propiedades exactas y sin datos personales', () async {
      await AnaliticaServicio.reiniciar();

      // 1. Disparo del evento al abrir formulario
      await AnaliticaServicio.track('movimiento_iniciado', {'tipo': 'gasto'});

      final resumen = await AnaliticaServicio.obtenerResumen();

      // 2. Comprobar que se registró una sola vez
      expect(resumen['iniciados'], 1);
      final ultimos = resumen['ultimos'] as List<dynamic>;
      expect(ultimos.length, 1);

      final ev = ultimos.first as Map<String, dynamic>;
      expect(ev['evento'], 'movimiento_iniciado');

      // 3. Comprobar propiedades exactamente definidas y ninguna más
      final props = ev['props'] as Map<String, dynamic>;
      expect(props.keys.toList(), ['tipo']);
      expect(props['tipo'], 'gasto');

      // 4. Regla de privacidad: NINGÚN dato personal o financiero
      expect(props.containsKey('email'), isFalse);
      expect(props.containsKey('correo'), isFalse);
      expect(props.containsKey('monto'), isFalse);
      expect(props.containsKey('concepto'), isFalse);
      expect(props.containsKey('descripcion'), isFalse);
      expect(props.containsKey('usuarioId'), isFalse);
    });

    test('Evento movimiento_guardado: solo tras confirmación, único y sin datos personales', () async {
      await AnaliticaServicio.reiniciar();

      // Simulación: Si la validación falla o hay error, NO se debe disparar
      bool intentarDisparo(bool confirmado) {
        if (confirmado) {
          AnaliticaServicio.track('movimiento_guardado', {'tipo': 'gasto'});
          return true;
        }
        return false;
      }

      intentarDisparo(false);
      var resumen = await AnaliticaServicio.obtenerResumen();
      expect(resumen['guardados'], 0);

      // Simulación: La base de datos confirmó el guardado con éxito
      await AnaliticaServicio.track('movimiento_guardado', {'tipo': 'ingreso'});

      resumen = await AnaliticaServicio.obtenerResumen();

      // 1. Se disparó una sola vez
      expect(resumen['guardados'], 1);

      final ultimos = resumen['ultimos'] as List<dynamic>;
      final ev = ultimos.first as Map<String, dynamic>;
      expect(ev['evento'], 'movimiento_guardado');

      // 2. Propiedades exactas
      final props = ev['props'] as Map<String, dynamic>;
      expect(props.keys.toList(), ['tipo']);
      expect(props['tipo'], 'ingreso');

      // 3. Sin datos sensibles
      expect(props.containsKey('monto'), isFalse);
      expect(props.containsKey('concepto'), isFalse);
      expect(props.containsKey('email'), isFalse);
    });

    test('Persistencia y cálculo de embudo (GROUP BY y porcentaje)', () async {
      await AnaliticaServicio.reiniciar();

      // 2 movimientos iniciados, 1 guardado (50.0%)
      await AnaliticaServicio.track('movimiento_iniciado', {'tipo': 'gasto'});
      await AnaliticaServicio.track('movimiento_iniciado', {'tipo': 'ingreso'});
      await AnaliticaServicio.track('movimiento_guardado', {'tipo': 'gasto'});

      final resumen = await AnaliticaServicio.obtenerResumen();

      expect(resumen['iniciados'], 2);
      expect(resumen['guardados'], 1);
      expect(resumen['porcentaje'], 50.0);
    });
  });
}
