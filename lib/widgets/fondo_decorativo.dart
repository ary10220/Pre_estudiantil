import 'dart:math';
import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';

class FondoDecorativo extends StatelessWidget {
  const FondoDecorativo({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _PintorEsquinas(),
    );
  }
}

class _PintorEsquinas extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Esquina superior izquierda
    _dibujarEsquina(canvas, size);

    // Esquina inferior derecha: es la misma forma girada 180 grados
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(pi);
    _dibujarEsquina(canvas, size);
    canvas.restore();
  }

  void _dibujarEsquina(Canvas canvas, Size size) {
    final ancho = size.width;
    final alto = size.height;

    // Franja clara (atrás)
    final pinturaClara = Paint()..color = Colores.verdeClaro;
    final formaClara = Path()
      ..moveTo(0, 0)
      ..lineTo(ancho * 0.38, 0)
      ..quadraticBezierTo(ancho * 0.30, alto * 0.12, 0, alto * 0.17)
      ..close();
    canvas.drawPath(formaClara, pinturaClara);

    // Forma oscura (adelante)
    final pinturaOscura = Paint()..color = Colores.verdeOscuro;
    final formaOscura = Path()
      ..moveTo(0, 0)
      ..lineTo(ancho * 0.32, 0)
      ..cubicTo(ancho * 0.25, alto * 0.07, ancho * 0.12, alto * 0.09, 0, alto * 0.13)
      ..close();
    canvas.drawPath(formaOscura, pinturaOscura);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}