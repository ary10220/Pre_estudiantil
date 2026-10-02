import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';

// Guarda el token del login en el celular para no pedir el login cada vez
class Sesion {
  static Future<void> guardar(String token, Usuario usuario) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('token', token);
    await preferencias.setString('usuario', jsonEncode(usuario.aJson()));
  }

  static Future<String?> leerToken() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString('token');
  }

  static Future<Usuario?> leerUsuario() async {
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString('usuario');
    if (texto == null) return null;
    return Usuario.desdeJson(jsonDecode(texto));
  }

  static Future<bool> haySesion() async {
    return await leerToken() != null;
  }

  static Future<void> borrar() async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove('token');
    await preferencias.remove('usuario');
  }
}
