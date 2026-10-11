import 'package:flutter/material.dart';
import 'constantes.dart';

class TemaApp {
  static final ThemeData temaClaro = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colores.verdeOscuro),
    scaffoldBackgroundColor: Colores.fondo,
    useMaterial3: true,
  );
}