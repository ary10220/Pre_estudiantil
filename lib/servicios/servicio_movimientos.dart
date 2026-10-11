import '../modelos/movimiento.dart';
import 'servicio_acceso.dart';

// Se lanza cuando no hay sesión válida: la pantalla debe volver al login
class SesionExpirada implements Exception {}

class ServicioMovimientos {
  // Llamada con el token de la sesión
  static Future<Map<String, dynamic>> _pedir(
      String metodo,
      String ruta, {
        Map<String, dynamic>? datos,
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

  // Recuperar: lee los movimientos guardados
  static Future<List<Movimiento>> listar() async {
    final datos = await _pedir('GET', '/movimientos');
    final lista = datos['movimientos'] as List;
    return lista
        .map((j) => Movimiento.desdeJson(j as Map<String, dynamic>))
        .toList();
  }

  // Construir y guardar un movimiento nuevo
  static Future<Movimiento> crear(
      String concepto,
      double monto,
      DateTime fecha,
      ) async {
    final datos = await _pedir('POST', '/movimientos', datos: {
      'concepto': concepto,
      'monto': monto,
      'fecha': _fechaParaServidor(fecha),
    });
    return Movimiento.desdeJson(datos['movimiento']);
  }

  // Acción: pendiente -> pagado
  static Future<Movimiento> marcarComoPagado(Movimiento movimiento) async {
    movimiento.marcarComoPagado(); // regla del modelo: rechaza si ya está pagado
    final datos = await _pedir('POST', '/movimientos/${movimiento.id}/pagar');
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static String _fechaParaServidor(DateTime f) {
    final mes = f.month.toString().padLeft(2, '0');
    final dia = f.day.toString().padLeft(2, '0');
    return '${f.year.toString().padLeft(4, '0')}-$mes-$dia';
  }

  // Editar: primero la regla del modelo, luego se guarda en el servidor
  static Future<Movimiento> editar(
      Movimiento original,
      String concepto,
      double monto,
      DateTime fecha,
      ) async {
    original.editar(concepto: concepto, monto: monto, fecha: fecha);
    final datos = await _pedir('PUT', '/movimientos/${original.id}', datos: {
      'concepto': concepto,
      'monto': monto,
      'fecha': _fechaParaServidor(fecha),
    });
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static Future<void> eliminar(Movimiento movimiento) async {
    await _pedir('DELETE', '/movimientos/${movimiento.id}');
  }

}