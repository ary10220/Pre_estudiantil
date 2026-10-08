import 'package:flutter/material.dart';
import '../../../comun/tema/colores.dart';

/// Diálogo de confirmación antes de eliminar un movimiento.
///
/// Devuelve `true` solo si la persona elige "Eliminar"; con "Cancelar" o
/// cerrando el diálogo devuelve `false` y no se borra nada.
Future<bool> confirmarEliminarMovimiento(BuildContext context) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: const Text('Eliminar movimiento'),
      content: const Text('¿Seguro que quieres eliminar este movimiento? Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogo, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('boton_confirmar_eliminar'),
          style: FilledButton.styleFrom(backgroundColor: colorGasto),
          onPressed: () => Navigator.pop(dialogo, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return confirmado == true;
}
