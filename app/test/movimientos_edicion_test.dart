import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/flujos/movimientos/modelos/movimiento.dart';
import 'package:app/flujos/movimientos/pantallas/pantalla_editar_gasto.dart';
import 'package:app/flujos/movimientos/widgets/confirmacion_eliminar.dart';
import 'package:app/flujos/movimientos/widgets/fila_movimiento.dart';

Movimiento pendiente() {
  return Movimiento.desdeJson({
    'id': 1,
    'tipo': 'gasto',
    'concepto': 'Transporte',
    'monto': 2.5,
    'fecha': '2026-10-04',
    'estado': 'pendiente',
    'pagado_en': null,
  });
}

Movimiento pagado() {
  return Movimiento.desdeJson({
    'id': 1,
    'tipo': 'gasto',
    'concepto': 'Transporte',
    'monto': 2.5,
    'fecha': '2026-10-04',
    'estado': 'pagado',
    'pagado_en': '2026-10-04T17:36:04.380Z',
  });
}

Widget envelopar(Widget hijo) {
  return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: hijo)));
}

Widget enveloparPantalla(Widget pantalla) {
  return MaterialApp(home: pantalla);
}

void main() {
  // Tarea 3: "un movimiento pagado no permite modificar su monto"
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'token-de-prueba'});
  });

  testWidgets('1. con el movimiento pagado el campo monto queda bloqueado', (tester) async {
    await tester.pumpWidget(enveloparPantalla(PantallaEditarGasto(movimiento: pagado())));
    await tester.pumpAndSettle();

    // El campo 0 es concepto, el 1 es monto y el 2 es fecha
    final campoMonto = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(campoMonto.readOnly, isTrue);
    expect(campoMonto.controller!.text, '2.50');

    expect(find.byKey(const Key('ayuda_monto_bloqueado')), findsOneWidget);
    expect(
      find.text('No se puede modificar el monto porque el movimiento ya está pagado.'),
      findsOneWidget,
    );
  });

  testWidgets('2. con el movimiento pendiente el campo monto se puede editar', (tester) async {
    await tester.pumpWidget(enveloparPantalla(PantallaEditarGasto(movimiento: pendiente())));
    await tester.pumpAndSettle();

    final campoMonto = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(campoMonto.readOnly, isFalse);
    expect(find.byKey(const Key('ayuda_monto_bloqueado')), findsNothing);
  });

  testWidgets('3. la fila ofrece Editar y Eliminar en el menú', (tester) async {
    var editado = false;
    var eliminado = false;

    await tester.pumpWidget(envelopar(FilaMovimiento(
      movimiento: pendiente(),
      alEditar: () => editado = true,
      alEliminar: () => eliminado = true,
    )));

    await tester.tap(find.byKey(const Key('boton_opciones_movimiento')));
    await tester.pumpAndSettle();

    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('opcion_editar')));
    await tester.pumpAndSettle();
    expect(editado, isTrue);
    expect(eliminado, isFalse);
  });

  testWidgets('4. elegir Eliminar del menú dispara el callback de eliminar', (tester) async {
    var eliminado = false;

    await tester.pumpWidget(envelopar(FilaMovimiento(
      movimiento: pagado(),
      alEliminar: () => eliminado = true,
    )));

    await tester.tap(find.byKey(const Key('boton_opciones_movimiento')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('opcion_eliminar')));
    await tester.pumpAndSettle();

    expect(eliminado, isTrue);
  });

  testWidgets('5. eliminar pide confirmación antes de borrar', (tester) async {
    bool? resultado;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado = await confirmarEliminarMovimiento(context);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar movimiento'), findsOneWidget);
    expect(
      find.text('¿Seguro que quieres eliminar este movimiento? Esta acción no se puede deshacer.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('boton_confirmar_eliminar')), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(resultado, isFalse);

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('boton_confirmar_eliminar')));
    await tester.pumpAndSettle();
    expect(resultado, isTrue);
  });
}
