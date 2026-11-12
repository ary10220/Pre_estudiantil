import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Colores {
  static const Color verdeOscuro = Color(0xFF0B6B5F);
  static const Color verdeClaro = Color(0xFFCFE3DE);
  static const Color azulOscuro = Color(0xFF0F1B3D);
  static const Color grisAzulado = Color(0xFF6B7494);
  static const Color fondo = Color(0xFFF7F9F9);
  // El mismo rojo que ya usan los mensajes de error (Colors.red.shade700)
  static const Color rojo = Color(0xFFD32F2F);
  // El mismo ámbar del chip "Pendiente": aviso al pasar el 80 % del límite
  static const Color aviso = Color(0xFF8A5A00);
}

class Servidor {
  // La URL se configura en el .env de la raíz (API_BASE_URL)
  static String get urlBase =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
}
