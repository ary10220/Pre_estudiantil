import '../../../comun/modelos/usuario.dart';
import '../../../comun/servicios/api.dart';

class RespuestaLogin {
  final String token;
  final Usuario usuario;

  RespuestaLogin(this.token, this.usuario);
}

class AuthServicio {
  static Future<Usuario> registrar(String nombre, String correo, String contrasena) async {
    final datos = await Api.post('/auth/registro', {
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
    });
    return Usuario.desdeJson(datos['usuario']);
  }

  static Future<RespuestaLogin> iniciarSesion(String correo, String contrasena) async {
    final datos = await Api.post('/auth/login', {
      'correo': correo,
      'contrasena': contrasena,
    });
    return RespuestaLogin(datos['token'], Usuario.desdeJson(datos['usuario']));
  }

  static Future<String> pedirCodigo(String correo) async {
    final datos = await Api.post('/auth/recuperar', {'correo': correo});
    return datos['codigo'];
  }

  static Future<void> cambiarContrasena(String correo, String codigo, String nueva) async {
    await Api.post('/auth/cambiar-contrasena', {
      'correo': correo,
      'codigo': codigo,
      'nueva': nueva,
    });
  }

  static Future<Usuario> usuarioActual(String token) async {
    final datos = await Api.get('/sesion/yo', token: token);
    return Usuario.desdeJson(datos['usuario']);
  }

  static Future<void> salir(String token) async {
    await Api.post('/sesion/salir', {}, token: token);
  }
}
