import '../modelos/limite.dart';
import 'servicio_acceso.dart';
import 'servicio_movimientos.dart';

class ServicioLimite {
  // Llamada con el token de la sesión
  static Future<Map<String, dynamic>> _pedir(
      String metodo, {
        Map<String, dynamic>? datos,
        String ruta = '/limite',
      }) async {
    final token = await ServicioAcceso.obtenerToken();
    if (token == null) throw SesionExpirada();

    final respuesta = await ServicioAcceso.llamar(
      metodo,
      ruta,
      datos: datos,
      token: token,
    );
    if (respuesta.statusCode == 401) throw SesionExpirada();
    return ServicioAcceso.leer(respuesta);
  }

  // Límite, gastado y restante del mes (AAAA-MM; sin mes, el actual). limite null si no lo definió
  static Future<ResumenLimite> leer([String? mes]) async {
    final datos = await _pedir('GET', ruta: mes == null ? '/limite' : '/limite?mes=$mes');
    return ResumenLimite.desdeJson(datos);
  }

  // Primero la regla del modelo, después la API
  static Future<ResumenLimite> guardar(String texto) async {
    final error = validarMontoLimite(texto);
    if (error != null) throw StateError(error);
    final datos = await _pedir('PUT', datos: {'monto': leerLimite(texto)});
    return ResumenLimite.desdeJson(datos);
  }
}
