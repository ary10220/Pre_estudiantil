import 'package:flutter/material.dart';
import '../tema/colores.dart';
import '../tema/espaciado.dart';
import '../tema/tipografia.dart';

class BotonPrincipal extends StatelessWidget {
  final String texto;
  final String textoCargando;
  final bool cargando;
  final VoidCallback alPresionar;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.textoCargando,
    required this.alPresionar,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: alturaControl,
      child: FilledButton(
        onPressed: cargando ? null : alPresionar,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((estados) {
            if (estados.contains(WidgetState.disabled)) return colorDeshabilitado;
            if (estados.contains(WidgetState.pressed)) return colorMarcaPresionado;
            return colorMarca;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((estados) {
            if (estados.contains(WidgetState.disabled)) return colorTextoSecundario;
            return colorSuperficie;
          }),
          textStyle: WidgetStatePropertyAll(Tipografia.boton),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radioControl)),
          ),
        ),
        child: cargando
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: espacio16,
                    height: espacio16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorTextoSecundario),
                  ),
                  const SizedBox(width: espacio8),
                  Text(textoCargando),
                ],
              )
            : Text(texto),
      ),
    );
  }
}
