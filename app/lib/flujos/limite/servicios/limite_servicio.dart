import '../../../comun/servicios/api.dart';

class LimiteServicio {
  // null si el usuario todavía no definió su límite
  static Future<double?> leer(String token) async {
    final datos = await Api.get('/limite', token: token);
    final limite = datos['limite'] as num?;
    return limite?.toDouble();
  }

  static Future<double> guardar(String token, double limite) async {
    final datos = await Api.put('/limite', {'limite': limite}, token: token);
    return (datos['limite'] as num).toDouble();
  }
}
