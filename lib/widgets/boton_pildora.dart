import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';

class BotonPildora extends StatelessWidget {
  final String texto;
  final IconData icono;
  final bool esRelleno;
  final VoidCallback alPresionar;

  const BotonPildora({
    super.key,
    required this.texto,
    required this.icono,
    required this.alPresionar,
    this.esRelleno = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si es relleno: fondo verde y texto blanco. Si no: solo borde verde.
    final Color colorContenido = esRelleno ? Colors.white : Colores.verdeOscuro;

    return Material(
      color: esRelleno ? Colores.verdeOscuro : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: Colores.verdeOscuro, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: alPresionar,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(icono, color: colorContenido),
                Expanded(
                  child: Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorContenido,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward, color: colorContenido),
              ],
            ),
          ),
        ),
      ),
    );
  }
}