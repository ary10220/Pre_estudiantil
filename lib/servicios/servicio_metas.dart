import '../modelos/meta_ahorro.dart';
import '../modelos/movimiento.dart';
import 'servicio_acceso.dart';
import 'servicio_movimientos.dart';

class ServicioMetas {
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

  static Future<ResultadoMetas> listar() async {
    final datos = await _pedir('GET', '/metas');
    final metas = (datos['metas'] as List)
        .map((json) => MetaAhorro.desdeJson(json as Map<String, dynamic>))
        .toList();
    final resumen = ResumenMetas.desdeJson(
      datos['resumen'] as Map<String, dynamic>,
    );
    return ResultadoMetas(metas, resumen);
  }

  static Future<ResultadoMeta> crear(
    String nombre,
    double montoObjetivo,
    DateTime fechaObjetivo,
  ) async {
    final datos = await _pedir(
      'POST',
      '/metas',
      datos: {
        'nombre': nombre,
        'montoObjetivo': montoObjetivo,
        'fechaObjetivo': Movimiento.fechaParaServidor(fechaObjetivo),
      },
    );
    return ResultadoMeta(
      MetaAhorro.desdeJson(datos['meta'] as Map<String, dynamic>),
      ResumenMetas.desdeJson(datos['resumen'] as Map<String, dynamic>),
    );
  }

  static Future<ResultadoMeta> asignar(int id, double monto) async {
    final datos = await _pedir(
      'POST',
      '/metas/$id/asignar',
      datos: {'monto': monto},
    );
    return ResultadoMeta(
      MetaAhorro.desdeJson(datos['meta'] as Map<String, dynamic>),
      ResumenMetas.desdeJson(datos['resumen'] as Map<String, dynamic>),
    );
  }

  static Future<ResultadoMeta> retirar(int id, double monto) async {
    final datos = await _pedir(
      'POST',
      '/metas/$id/retirar',
      datos: {'monto': monto},
    );
    return ResultadoMeta(
      MetaAhorro.desdeJson(datos['meta'] as Map<String, dynamic>),
      ResumenMetas.desdeJson(datos['resumen'] as Map<String, dynamic>),
    );
  }

  static Future<ResultadoMeta> transferir(
    int id,
    int metaDestinoId,
    double monto,
  ) async {
    final datos = await _pedir(
      'POST',
      '/metas/$id/transferir',
      datos: {'metaDestinoId': metaDestinoId, 'monto': monto},
    );
    return ResultadoMeta(
      MetaAhorro.desdeJson(datos['meta'] as Map<String, dynamic>),
      ResumenMetas.desdeJson(datos['resumen'] as Map<String, dynamic>),
    );
  }

  static Future<List<MovimientoMeta>> historial(int id) async {
    final datos = await _pedir('GET', '/metas/$id/movimientos');
    return (datos['movimientos'] as List)
        .map((json) => MovimientoMeta.desdeJson(json as Map<String, dynamic>))
        .toList();
  }
}
