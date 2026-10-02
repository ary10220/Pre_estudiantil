import '../../../comun/servicios/api.dart';
import '../modelos/movimiento.dart';

class MovimientosServicio {
  static Future<List<Movimiento>> listar(String token) async {
    final datos = await Api.get('/movimientos', token: token);
    final lista = datos['movimientos'] as List;
    return lista.map((fila) => Movimiento.desdeJson(fila)).toList();
  }

  static Future<Movimiento> guardarGasto(String token, String concepto, double monto) async {
    final datos = await Api.post('/movimientos', {
      'concepto': concepto,
      'monto': monto,
    }, token: token);
    return Movimiento.desdeJson(datos['movimiento']);
  }
}
