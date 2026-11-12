import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnaliticaServicio {
  static const String _claveEventos = 'tabla_eventos_analitica';

  /// Registra un evento de interacción localmente.
  /// Formato: { evento, props, fecha }
  /// - try-catch hermético: NUNCA interrumpe el flujo principal de la app.
  /// - debugPrint con interpolación de texto.
  /// - Escritura secuencial persistente con await en shared_preferences.
  static Future<void> track(String evento, Map<String, dynamic> props) async {
    // Saneamiento de props: asegura que enums o tipos especiales se conviertan a String para JSON
    final propsLimpias = <String, dynamic>{};
    for (final entrada in props.entries) {
      final valor = entrada.value;
      if (valor is Enum) {
        propsLimpias[entrada.key] = valor.name;
      } else {
        propsLimpias[entrada.key] = valor;
      }
    }

    final registro = {
      'evento': evento,
      'props': propsLimpias,
      'fecha': DateTime.now().toUtc().toIso8601String(),
    };

    // Ajuste 1: debugPrint en Dart recibe un solo String
    debugPrint('[evento] $registro');

    // Ajuste 2: try-catch hermético para proteger el flujo del usuario
    try {
      final prefs = await SharedPreferences.getInstance();

      // Ajuste 3: lectura -> agregación -> escritura secuencial con await
      final raw = prefs.getString(_claveEventos);
      final List<dynamic> lista = raw != null ? jsonDecode(raw) as List<dynamic> : [];
      lista.add(registro);

      await prefs.setString(_claveEventos, jsonEncode(lista));
    } catch (e) {
      // Falla silenciosa de analítica: no interrumpe el guardado ni muestra error en pantalla
      debugPrint('[analitica] Error al registrar evento: $e');
    }
  }

  /// Lee los eventos almacenados localmente y calcula los conteos y la tasa de conversión.
  /// Equivale a: SELECT evento, COUNT(*) FROM eventos GROUP BY evento
  static Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_claveEventos);
      final List<dynamic> lista = raw != null ? jsonDecode(raw) as List<dynamic> : [];

      int iniciados = 0;
      int guardados = 0;

      for (final item in lista) {
        if (item is Map<String, dynamic>) {
          final nombre = item['evento'];
          if (nombre == 'movimiento_iniciado') iniciados++;
          if (nombre == 'movimiento_guardado') guardados++;
        }
      }

      final porcentaje = iniciados > 0
          ? ((guardados / iniciados) * 1000).round() / 10
          : 0.0;

      // Invertir para mostrar los más recientes primero
      final ultimos = lista.reversed.take(20).toList();

      return {
        'iniciados': iniciados,
        'guardados': guardados,
        'porcentaje': porcentaje,
        'ultimos': ultimos,
      };
    } catch (e) {
      debugPrint('[analitica] Error al leer resumen: $e');
      return {
        'iniciados': 0,
        'guardados': 0,
        'porcentaje': 0.0,
        'ultimos': [],
      };
    }
  }

  /// Opcional para pruebas o reiniciar métricas
  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveEventos);
  }
}
