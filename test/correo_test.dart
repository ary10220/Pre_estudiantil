import 'package:flutter_test/flutter_test.dart';
import 'package:ihcpre_estudiantil2/modelos/correo.dart';

void main() {
  test('permitido: un correo con @ y dominio', () {
    expect(validarCorreo('prueba@correo.com'), null);
    expect(validarCorreo('  ana.perez@uagrm.edu.bo '), null);
  });

  test('rechazado: sin @, sin dominio o con espacios', () {
    for (final valor in ['correo-sin-arroba', 'ana@', 'ana@correo', 'ana perez@correo.com', '']) {
      expect(validarCorreo(valor), mensajeCorreoInvalido);
    }
  });
}
