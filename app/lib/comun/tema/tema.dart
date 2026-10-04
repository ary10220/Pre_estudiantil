import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colores.dart';
import 'espaciado.dart';
import 'tipografia.dart';

ThemeData crearTema() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: colorMarca,
      primary: colorMarca,
      error: colorError,
      surface: colorFondo,
    ),
    scaffoldBackgroundColor: colorFondo,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    appBarTheme: const AppBarTheme(
      backgroundColor: colorFondo,
      foregroundColor: colorTexto,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorMarca,
        textStyle: Tipografia.etiqueta,
        minimumSize: const Size(espacio48, alturaControl),
        padding: const EdgeInsets.symmetric(horizontal: espacio8),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorTexto,
      contentTextStyle: Tipografia.cuerpo.copyWith(color: colorSuperficie),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radioControl)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorSuperficie,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(espacio16)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: colorSuperficie,
      surfaceTintColor: colorSuperficie,
      headerForegroundColor: colorTexto,
      dividerColor: colorBorde,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(espacio16)),
    ),
  );
}
