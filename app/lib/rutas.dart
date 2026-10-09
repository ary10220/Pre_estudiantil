import 'package:flutter/material.dart';
import 'flujos/acceso/pantallas/pantalla_inicio.dart';
import 'flujos/acceso/pantallas/pantalla_bienvenida.dart';
import 'flujos/acceso/pantallas/pantalla_login.dart';
import 'flujos/acceso/pantallas/pantalla_nueva_contrasena.dart';
import 'flujos/acceso/pantallas/pantalla_recuperar.dart';
import 'flujos/acceso/pantallas/pantalla_registro.dart';
import 'flujos/movimientos/pantallas/pantalla_movimientos.dart';
import 'flujos/movimientos/pantallas/pantalla_nuevo_gasto.dart';
import 'flujos/limite/pantallas/pantalla_limite.dart';

final Map<String, WidgetBuilder> rutas = {
  '/': (_) => const PantallaBienvenida(),
  '/login': (_) => const PantallaLogin(),
  '/registro': (_) => const PantallaRegistro(),
  '/recuperar': (_) => const PantallaRecuperar(),
  '/nueva-contrasena': (_) => const PantallaNuevaContrasena(),
  // Privadas: cada pantalla revisa la sesión con comun/servicios/guardia.dart
  '/inicio': (_) => const PantallaInicio(),
  '/movimientos': (_) => const PantallaMovimientos(),
  '/movimientos/nuevo': (_) => const PantallaNuevoGasto(),
  '/limite': (_) => const PantallaLimite(),
};
