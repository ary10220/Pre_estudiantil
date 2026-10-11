import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';

void mostrarMensaje(BuildContext context, String texto, {bool esError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: esError ? Colors.red.shade700 : Colores.verdeOscuro,
        behavior: SnackBarBehavior.floating,
      ),
    );
}