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
  /// Equivale a un GROUP BY local de los eventos registrados por flujo.
  static Future<Map<String, dynamic>> obtenerResumen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_claveEventos);
      final List<dynamic> lista = raw != null ? jsonDecode(raw) as List<dynamic> : [];

      // 1. Embudo Movimientos
      int movIniciados = 0;
      int movGuardados = 0;

      // 2 Embudo Metas
      int metasIniciadas = 0;
      int metasGuardadas = 0;
      int fondosOperados = 0;

      // 3 Embudo Limites
      int limitesIniciados = 0;
      int limitesGuardados = 0;

      // 4 Aviso limite 
      int avisosMostrados = 0;
      int avisosConfirmados = 0;
      int avisosCancelados = 0;

      // 5 Friccion y Búsquedas
      final Map<String, int> erroresFormulario = {};
      int busquedasSinResultado = 0;

      for (final item in lista) {
        if (item is Map<String, dynamic>) {
          final nombre = item['evento'] as String? ?? '';
          final props = item['props'] as Map<String, dynamic>? ?? {};

          switch (nombre) {
            case 'movimiento_iniciado':
              movIniciados++;
              break;
            case 'movimiento_guardado':
              movGuardados++;
              break;
            case 'meta_creacion_iniciada':
              metasIniciadas++;
              break;
            case 'meta_guardada':
              metasGuardadas++;
              break;
            case 'fondos_meta_operados':
              fondosOperados++;
              break;
            case 'limite_iniciado':
              limitesIniciados++;
              break;
            case 'limite_guardado':
              limitesGuardados++;
              break;
            case 'aviso_limite_mostrado':
              avisosMostrados++;
              break;
            case 'aviso_limite_confirmado':
              avisosConfirmados++;
              break;
            case 'aviso_limite_cancelado':
              avisosCancelados++;
              break;
            case 'error_formulario_mostrado':
              final motivo = props['motivo'] as String? ?? 'desconocido';
              erroresFormulario[motivo] = (erroresFormulario[motivo] ?? 0) + 1;
              break;
            case 'busqueda_sin_resultados':
              busquedasSinResultado++;
              break;
          }
        }
      }

      double calcularTasa(int exito, int total) {
        if (total <= 0) return 0.0;
        return ((exito / total) * 1000).round() / 10;
      }

      double calcularCaida(int exito, int total) {
        if (total <= 0) return 0.0;
        final caida = ((total - exito) / total) * 100;
        return (caida * 10).round() / 10;
      }

      // Invertir para mostrar los más recientes primero
      final ultimos = lista.reversed.take(20).toList();

      return {
        // Compatibilidad con metricas previas
        'iniciados': movIniciados,
        'guardados': movGuardados,
        'porcentaje': calcularTasa(movGuardados, movIniciados),

        // Embudo Movimientos
        'movimientos': {
          'iniciados': movIniciados,
          'guardados': movGuardados,
          'conversion': calcularTasa(movGuardados, movIniciados),
          'caida': calcularCaida(movGuardados, movIniciados),
        },

        // Embudo Metas
        'metas': {
          'iniciadas': metasIniciadas,
          'guardadas': metasGuardadas,
          'fondosOperados': fondosOperados,
          'conversion': calcularTasa(metasGuardadas, metasIniciadas),
          'caida': calcularCaida(metasGuardadas, metasIniciadas),
        },

        // Embudo Limites
        'limites': {
          'iniciados': limitesIniciados,
          'guardados': limitesGuardados,
          'conversion': calcularTasa(limitesGuardados, limitesIniciados),
          'caida': calcularCaida(limitesGuardados, limitesIniciados),
        },

        // Metricas de Advertencia de limite 
        'avisoLimite': {
          'mostrados': avisosMostrados,
          'confirmados': avisosConfirmados,
          'cancelados': avisosCancelados,
          'tasaDisuasion': calcularTasa(avisosCancelados, avisosMostrados),
        },

        // Friccion
        'erroresFormulario': erroresFormulario,
        'busquedasSinResultado': busquedasSinResultado,

        'ultimos': ultimos,
      };
    } catch (e) {
      debugPrint('[analitica] Error al leer resumen: $e');
      return {
        'iniciados': 0,
        'guardados': 0,
        'porcentaje': 0.0,
        'movimientos': {'iniciados': 0, 'guardados': 0, 'conversion': 0.0, 'caida': 0.0},
        'metas': {'iniciadas': 0, 'guardadas': 0, 'fondosOperados': 0, 'conversion': 0.0, 'caida': 0.0},
        'limites': {'iniciados': 0, 'guardados': 0, 'conversion': 0.0, 'caida': 0.0},
        'avisoLimite': {'mostrados': 0, 'confirmados': 0, 'cancelados': 0, 'tasaDisuasion': 0.0},
        'erroresFormulario': <String, int>{},
        'busquedasSinResultado': 0,
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
