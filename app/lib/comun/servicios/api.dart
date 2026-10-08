import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// En celular real va la IP de la PC, por ejemplo http://192.168.0.10:3000
const String urlBase = 'http://10.0.2.2:3000';

const String mensajeSinConexion = 'No pudimos conectar, revisá tu conexión';

class ErrorApi implements Exception {
  final String mensaje;
  final int codigo;

  ErrorApi(this.mensaje, this.codigo);
}

class Api {
  static Future<Map<String, dynamic>> post(String ruta, Map<String, dynamic> cuerpo, {String? token}) {
    return _enviar(() => http.post(
          Uri.parse('$urlBase$ruta'),
          headers: _cabeceras(token),
          body: jsonEncode(cuerpo),
        ));
  }

  static Future<Map<String, dynamic>> get(String ruta, {String? token}) {
    return _enviar(() => http.get(Uri.parse('$urlBase$ruta'), headers: _cabeceras(token)));
  }

  static Future<Map<String, dynamic>> patch(String ruta, {Map<String, dynamic>? cuerpo, String? token}) {
    return _enviar(() => http.patch(
          Uri.parse('$urlBase$ruta'),
          headers: _cabeceras(token),
          body: cuerpo == null ? null : jsonEncode(cuerpo),
        ));
  }

  static Map<String, String> _cabeceras(String? token) {
    final cabeceras = {'Content-Type': 'application/json'};
    if (token != null) {
      cabeceras['Authorization'] = 'Bearer $token';
    }
    return cabeceras;
  }

  static Future<Map<String, dynamic>> _enviar(Future<http.Response> Function() pedido) async {
    http.Response respuesta;
    try {
      respuesta = await pedido().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw ErrorApi(mensajeSinConexion, 0);
    } on TimeoutException {
      throw ErrorApi(mensajeSinConexion, 0);
    } on http.ClientException {
      throw ErrorApi(mensajeSinConexion, 0);
    }

    final datos = respuesta.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

    if (respuesta.statusCode >= 400) {
      throw ErrorApi(datos['error'] ?? 'Algo salió mal, probá de nuevo', respuesta.statusCode);
    }
    return datos;
  }
  static Future<Map<String, dynamic>> put(String ruta, Map<String, dynamic> cuerpo, {String? token}) {
    return _enviar(() => http.put(
          Uri.parse('$urlBase$ruta'),
          headers: _cabeceras(token),
          body: jsonEncode(cuerpo),
        ));
  }

  static Future<Map<String, dynamic>> delete(String ruta, {String? token}) {
    return _enviar(() => http.delete(Uri.parse('$urlBase$ruta'), headers: _cabeceras(token)));
  }
}
