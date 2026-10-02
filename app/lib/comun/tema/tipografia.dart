import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';

// height = alto de línea / tamaño, así cada línea mide 16, 24 o 32
class Tipografia {
  static final TextStyle titulo = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    color: colorTexto,
  );

  static final TextStyle cuerpo = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: colorTexto,
  );

  static final TextStyle subtitulo = cuerpo.copyWith(color: colorTextoSecundario);

  static final TextStyle etiqueta = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 16 / 14,
    color: colorTexto,
  );

  static final TextStyle boton = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
  );

  static final TextStyle ayuda = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: colorTextoSecundario,
  );

  static final TextStyle error = ayuda.copyWith(color: colorError);

  // Números tabulares: todos los dígitos miden lo mismo y los montos quedan alineados
  static final TextStyle monto = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    color: colorTexto,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
