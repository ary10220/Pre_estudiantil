import '../modelos/filtros.dart';
import '../modelos/movimiento.dart';
import 'servicio_acceso.dart';

// Se lanza cuando no hay sesión válida: la pantalla debe volver al login
class SesionExpirada implements Exception {}

// Lo que devuelve el listado: los movimientos filtrados y su total
class ResultadoListado {
  final List<Movimiento> movimientos;
  final TotalesMovimientos totales;
  const ResultadoListado(this.movimientos, this.totales);
}

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

  // Recuperar: lee los movimientos guardados, con búsqueda y filtros opcionales
  static Future<ResultadoListado> listar([
    FiltrosMovimientos filtros = FiltrosMovimientos.vacio,
  ]) async {
    final consulta = Uri(queryParameters: filtros.toQuery()).query;
    final ruta = consulta.isEmpty ? '/movimientos' : '/movimientos?$consulta';

    final datos = await _pedir('GET', ruta);
    final lista = (datos['movimientos'] as List)
        .map((j) => Movimiento.desdeJson(j as Map<String, dynamic>))
        .toList();
    final totales = TotalesMovimientos.desdeJson(datos['totales'] as Map<String, dynamic>);
    return ResultadoListado(lista, totales);
  }

  // Construir y guardar un movimiento nuevo
  static Future<Movimiento> crear(
      String concepto,
      double monto,
      DateTime fecha,
      TipoMovimiento tipo,
      CategoriaMovimiento categoria,
      ) async {
    final datos = await _pedir('POST', '/movimientos', datos: {
      'concepto': concepto,
      'monto': monto,
      'fecha': Movimiento.fechaParaServidor(fecha),
      'tipo': tipo.name,
      'categoria': categoria.name,
    });
    return Movimiento.desdeJson(datos['movimiento']);
  }

  // Acción: pendiente -> pagado
  static Future<Movimiento> marcarComoPagado(Movimiento movimiento) async {
    movimiento.marcarComoPagado(); // regla del modelo: rechaza si ya está pagado
    final datos = await _pedir('POST', '/movimientos/${movimiento.id}/pagar');
    return Movimiento.desdeJson(datos['movimiento']);
  }

  // Editar: primero la regla del modelo, luego se guarda en el servidor
  static Future<Movimiento> editar(
      Movimiento original,
      String concepto,
      double monto,
      DateTime fecha,
      CategoriaMovimiento categoria,
      ) async {
    original.editar(concepto: concepto, monto: monto, fecha: fecha, categoria: categoria);
    final datos = await _pedir('PUT', '/movimientos/${original.id}', datos: {
      'concepto': concepto,
      'monto': monto,
      'fecha': Movimiento.fechaParaServidor(fecha),
      'categoria': categoria.name,
    });
    return Movimiento.desdeJson(datos['movimiento']);
  }

  static Future<void> eliminar(Movimiento movimiento) async {
    await _pedir('DELETE', '/movimientos/${movimiento.id}');
  }
}