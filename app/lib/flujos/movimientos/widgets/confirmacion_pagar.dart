import 'package:flutter/material.dart';

/// Diálogo de confirmación antes de marcar un movimiento como pagado.
///
/// Devuelve `true` solo si la persona elige "Confirmar"; con "Cancelar" o
/// cerrando el diálogo devuelve `false` y no se cambia nada.
Future<bool> confirmarMarcarPagado(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: const Text('Marcar como pagado'),
      content: const Text('¿Deseas marcar este movimiento como pagado? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogo, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('boton_confirmar_pagado'),
          onPressed: () => Navigator.pop(dialogo, true),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  return confirmado == true;
}