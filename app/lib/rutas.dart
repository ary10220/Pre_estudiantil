import 'package:flutter/material.dart';
import 'pantallas/privadas/pantalla_inicio.dart';
import 'pantallas/publicas/pantalla_bienvenida.dart';
import 'pantallas/publicas/pantalla_login.dart';
import 'pantallas/publicas/pantalla_nueva_contrasena.dart';
import 'pantallas/publicas/pantalla_recuperar.dart';
import 'pantallas/publicas/pantalla_registro.dart';

final Map<String, WidgetBuilder> rutas = {
  '/': (_) => const PantallaBienvenida(),
  '/login': (_) => const PantallaLogin(),
  '/registro': (_) => const PantallaRegistro(),
  '/recuperar': (_) => const PantallaRecuperar(),
  '/nueva-contrasena': (_) => const PantallaNuevaContrasena(),
  '/inicio': (_) => const PantallaInicio(),
};
