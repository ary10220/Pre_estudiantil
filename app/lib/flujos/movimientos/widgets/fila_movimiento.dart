import 'package:flutter/material.dart';
import '../../../comun/formato.dart';
import '../../../comun/tema/colores.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../modelos/movimiento.dart';

class FilaMovimiento extends StatelessWidget {
  final Movimiento movimiento;
  final VoidCallback? alMarcarPagado;

  const FilaMovimiento({super.key, required this.movimiento, this.alMarcarPagado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(espacio16),
      decoration: BoxDecoration(
        color: colorSuperficie,
        border: Border.all(color: colorBorde),
        borderRadius: BorderRadius.circular(radioControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(montoEnBs(movimiento.monto), style: Tipografia.monto.copyWith(color: colorGasto)),
            ],
          ),
          const SizedBox(height: espacio8),
          Row(
            children: [
              _ChipEstado(estado: movimiento.estado),
              const Spacer(),
              if (movimiento.esPendiente)
                TextButton(
                  key: const Key('boton_marcar_pagado'),
                  onPressed: alMarcarPagado,
                  child: const Text('Marcar como pagado'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final String estado;

  const _ChipEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final esPendiente = estado == 'pendiente';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: espacio8, vertical: 4),
      decoration: BoxDecoration(
        color: esPendiente ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(espacio32),
        border: Border.all(color: esPendiente ? Colors.orange.shade200 : Colors.green.shade200),
      ),
      child: Text(
        esPendiente ? 'Pendiente' : 'Pagado',
        key: const Key('chip_estado'),
        style: Tipografia.ayuda.copyWith(
          color: esPendiente ? Colors.orange.shade700 : Colors.green.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
