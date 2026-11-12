import 'servicio_acceso.dart';

class ServicioAnalitica {
  static Future<void> track(
    String evento,
    Map<String, dynamic> propiedades,
  ) async {
    try {
      final token = await ServicioAcceso.obtenerToken();
      if (token == null) return;

      await ServicioAcceso.llamar(
        'POST',
        '/analitica/eventos',
        datos: {'evento': evento, 'propiedades': propiedades},
        token: token,
      );
    } catch (_) {
      return;
    }
  }
}
