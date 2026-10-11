import 'servicio_acceso.dart';
import 'servicio_movimientos.dart';

class ServicioLimite {
  // Llamada con el token de la sesión
  static Future<Map<String, dynamic>> _pedir(
      String metodo, {
        Map<String, dynamic>? datos,
      }) async {
    final token = await ServicioAcceso.obtenerToken();
    if (token == null) throw SesionExpirada();

    final respuesta = await ServicioAcceso.llamar(
      metodo,
      '/limite',
      datos: datos,
      token: token,
    );
    if (respuesta.statusCode == 401) throw SesionExpirada();
    return ServicioAcceso.leer(respuesta);
  }

  // null si la persona todavía no definió su límite
  static Future<double?> leer() async {
    final datos = await _pedir('GET');
    final limite = datos['limite'] as num?;
    return limite?.toDouble();
  }

  static Future<double> guardar(double limite) async {
    final datos = await _pedir('PUT', datos: {'limite': limite});
    return (datos['limite'] as num).toDouble();
  }
}
