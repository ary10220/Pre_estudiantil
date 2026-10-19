import '../modelos/evento.dart';
import 'servicio_acceso.dart';
import 'servicio_movimientos.dart' show SesionExpirada;

class ServicioHistorial {
  // Llamada con el token de la sesión (mismo patrón que ServicioMovimientos)
  static Future<Map<String, dynamic>> _pedir(String ruta) async {
    final token = await ServicioAcceso.obtenerToken();
    if (token == null) throw SesionExpirada();

    final respuesta = await ServicioAcceso.llamar('GET', ruta, token: token);
    if (respuesta.statusCode == 401) throw SesionExpirada();
    return ServicioAcceso.leer(respuesta);
  }

  // Lee el historial del usuario. 'tipo' aplica el chip del filtro.
  static Future<List<GrupoDia>> listar({
    FiltroHistorial filtro = FiltroHistorial.todos,
  }) async {
    final ruta = '/historial?tipo=${filtro.textoServidor}';
    final datos = await _pedir(ruta);
    final lista = (datos['grupos'] as List)
        .map((j) => GrupoDia.desdeJson(j as Map<String, dynamic>))
        .toList();
    return lista;
  }
}
