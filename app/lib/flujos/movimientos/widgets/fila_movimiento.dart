import 'package:flutter/material.dart';
import '../../../comun/formato.dart';
import '../../../comun/tema/colores.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../modelos/movimiento.dart';

class FilaMovimiento extends StatelessWidget {
  final Movimiento movimiento;

  const FilaMovimiento({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(espacio16),
      decoration: BoxDecoration(
        color: colorSuperficie,
        border: Border.all(color: colorBorde),
        borderRadius: BorderRadius.circular(radioControl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movimiento.concepto, style: Tipografia.cuerpo),
                const SizedBox(height: espacio8),
                Text(fechaCorta(movimiento.fecha), style: Tipografia.ayuda),
              ],
            ),
          ),
          const SizedBox(width: espacio16),
          Text('− ${montoEnBs(movimiento.monto)}', style: Tipografia.monto.copyWith(color: colorGasto)),
        ],
      ),
    );
  }
}
