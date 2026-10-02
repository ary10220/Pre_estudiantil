import 'package:flutter/material.dart';
import 'sesion.dart';

// La usan todas las pantallas privadas: si la sesión no vale, al login
const String mensajeSesionTerminada = 'Tu sesión terminó, iniciá sesión de nuevo';

Future<void> mandarAlLogin(BuildContext context, String mensaje) async {
  await Sesion.borrar();
  if (!context.mounted) return;
  final mensajero = ScaffoldMessenger.of(context);
  Navigator.pushNamedAndRemoveUntil(context, '/login', (ruta) => false);
  mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
}

// Devuelve el token guardado; si no hay, manda al login y devuelve null
Future<String?> leerTokenOIrAlLogin(BuildContext context) async {
  final token = await Sesion.leerToken();
  if (token == null && context.mounted) {
    await mandarAlLogin(context, mensajeSesionTerminada);
  }
  return token;
}
