import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';

class Sesion {
  static Future<void> guardar(String token, Usuario usuario) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString('token', token);
    await preferencias.setString('usuario', jsonEncode(usuario.aJson()));
  }
}
