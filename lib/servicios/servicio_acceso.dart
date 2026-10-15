import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../configuracion/constantes.dart';

// Error con un mensaje listo para mostrar al usuario
class ErrorAcceso implements Exception {
  final String mensaje;
  // Código HTTP de la respuesta (null si ni siquiera hubo conexión). 422 = gasto bloqueado por el límite
  final int? codigo;
  ErrorAcceso(this.mensaje, [this.codigo]);
}

class ServicioAcceso {
  static const _claveToken = 'token';

  // ---------- Petición genérica al servidor ----------
  static Future<http.Response> llamar(
      String metodo,
      String ruta, {
        Map<String, dynamic>? datos,
        String? token,
      }) async {
    final url = Uri.parse('${Servidor.urlBase}$ruta');
    final cabeceras = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      switch (metodo) {
        case 'GET':
          return await http.get(url, headers: cabeceras);
        case 'PUT':
          return await http.put(url, headers: cabeceras, body: jsonEncode(datos ?? {}));
        case 'DELETE':
          return await http.delete(url, headers: cabeceras);
        default:
          return await http.post(url, headers: cabeceras, body: jsonEncode(datos ?? {}));
      }
    } on SocketException {
      throw ErrorAcceso('No se pudo conectar con el servidor');
    }
  }

  // Si el servidor respondió con error, lanza su mensaje
  static Map<String, dynamic> leer(http.Response respuesta) {
    final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
    if (respuesta.statusCode >= 400) {
      throw ErrorAcceso(cuerpo['error'] ?? 'Error desconocido', respuesta.statusCode);
    }
    return cuerpo;
  }

  // ---------- Registro ----------
  static Future<void> registrar(String nombre, String correo, String contrasena) async {
    final respuesta = await llamar('POST', '/registro', datos: {
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
    });
    leer(respuesta);
  }

  // ---------- Inicio de sesión: guarda el token en el celular ----------
  static Future<void> iniciarSesion(String correo, String contrasena) async {
    final respuesta = await llamar('POST', '/login', datos: {
      'correo': correo,
      'contrasena': contrasena,
    });
    final datos = leer(respuesta);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, datos['token']);
  }

  // ---------- Sesión guardada: devuelve el nombre, o null si no hay sesión ----------
  static Future<String?> obtenerNombreSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_claveToken);
    if (token == null) return null;

    final respuesta = await llamar('GET', '/perfil', token: token);

    // El servidor dice que el token ya no vale: limpiamos y no hay sesión
    if (respuesta.statusCode == 401) {
      await prefs.remove(_claveToken);
      return null;
    }
    return leer(respuesta)['nombre'];
  }

  // ---------- Cierre de sesión ----------
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_claveToken);

    try {
      if (token != null) await llamar('POST', '/logout', token: token);
    } on ErrorAcceso {
      // Sin conexión: igual cerramos la sesión en el celular
    }
    await prefs.remove(_claveToken);
  }

  // ---------- Recuperación de contraseña ----------
  // Devuelve el código de 6 dígitos (no se envía correo real)
  static Future<String> pedirCodigo(String correo) async {
    final respuesta = await llamar('POST', '/recuperar', datos: {'correo': correo});
    return leer(respuesta)['codigo'];
  }

  static Future<void> cambiarContrasena(String correo, String codigo, String nueva) async {
    final respuesta = await llamar('POST', '/cambiar-contrasena', datos: {
      'correo': correo,
      'codigo': codigo,
      'nuevaContrasena': nueva,
    });
    leer(respuesta);
  }

  // Token guardado en el celular (null si no hay sesión)
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_claveToken);
  }
}