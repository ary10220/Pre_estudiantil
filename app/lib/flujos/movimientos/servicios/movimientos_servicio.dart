import '../../../comun/formato.dart';
import '../../../comun/servicios/api.dart';
import '../modelos/movimiento.dart';

class MovimientosServicio {
  static Future<List<Movimiento>> listar(String token) async {
    final datos = await Api.get('/movimientos', token: token);
    final lista = datos['movimientos'] as List;
    return lista.map((fila) => Movimiento.desdeJson(fila)).toList();
  }

  static Future<Movimiento> guardarGasto(String token, String concepto, double monto, DateTime fecha) async {
    final datos = await Api.post('/movimientos', {
      'concepto': concepto,
      'monto': monto,
      'fecha': fechaParaApi(fecha),
    }, token: token);
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static Future<Movimiento> marcarPagado(String token, int id) async {
    final datos = await Api.patch('/movimientos/$id/pagar', token: token);
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static Future<Movimiento> editarMovimiento(
      String token, int id, String concepto, double monto, DateTime fecha) async {
    final datos = await Api.put('/movimientos/$id', {
      'concepto': concepto,
      'monto': monto,
      'fecha': fechaParaApi(fecha),
    }, token: token);
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static Future<void> eliminarMovimiento(String token, int id) async {
    await Api.delete('/movimientos/$id', token: token);
  }
}









