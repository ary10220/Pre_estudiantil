import 'package:flutter/material.dart';
import '../tema/colores.dart';
import '../tema/espaciado.dart';
import '../tema/tipografia.dart';

class BotonSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback alPresionar;

  const BotonSecundario({super.key, required this.texto, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: alturaControl,
      child: OutlinedButton(
        onPressed: alPresionar,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorMarca,
          backgroundColor: colorSuperficie,
          textStyle: Tipografia.boton,
          side: const BorderSide(color: colorBorde),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radioControl)),
        ),
        child: Text(texto),
      ),
    );
  }
}
