import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/flujos/movimientos/modelos/movimiento.dart';
import 'package:app/flujos/movimientos/widgets/confirmacion_pagar.dart';
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

void main() {
  test('1. el modelo lee estado pendiente y pagado_en vacío', () {
    final m = pendiente();
    expect(m.estado, 'pendiente');
    expect(m.pagadoEn, isNull);
    expect(m.esPendiente, isTrue);
  });

  test('2. el modelo lee estado pagado y pagado_en con fecha', () {
    final m = pagado();
    expect(m.estado, 'pagado');
    expect(m.pagadoEn, isNotNull);
    expect(m.esPendiente, isFalse);
    expect(m.pagadoEn!.toUtc().hour, 17);
  });

  test('3. si el backend no manda estado, se toma como pendiente', () {
    final m = Movimiento.desdeJson({
      'id': 7,
      'tipo': 'gasto',
      'concepto': 'Almuerzo',
      'monto': 25,
      'fecha': '2026-10-05',
    });
    expect(m.estado, 'pendiente');
    expect(m.pagadoEn, isNull);
  });

  testWidgets('4. un pendiente muestra chip Pendiente y el botón Marcar como pagado', (tester) async {
    var presionado = false;
    await tester.pumpWidget(envelopar(FilaMovimiento(
      movimiento: pendiente(),
      alMarcarPagado: () => presionado = true,
    )));

    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Marcar como pagado'), findsOneWidget);
    expect(find.byKey(const Key('boton_marcar_pagado')), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton_marcar_pagado')));
    expect(presionado, isTrue);
  });

  testWidgets('5. un pagado muestra chip Pagado y ya no ofrece el botón', (tester) async {
    await tester.pumpWidget(envelopar(FilaMovimiento(movimiento: pagado())));

    expect(find.text('Pagado'), findsOneWidget);
    expect(find.text('Pendiente'), findsNothing);
    expect(find.text('Marcar como pagado'), findsNothing);
    expect(find.byKey(const Key('boton_marcar_pagado')), findsNothing);
  });

  testWidgets('6. al marcar como pagado, la fila cambia a Pagado sin botón', (tester) async {
    var actual = pendiente();
    await tester.pumpWidget(envelopar(StatefulBuilder(builder: (context, setState) {
      return FilaMovimiento(
        movimiento: actual,
        alMarcarPagado: () => setState(() => actual = pagado()),
      );
    })));

    expect(find.text('Pendiente'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton_marcar_pagado')));
    await tester.pumpAndSettle();

    expect(find.text('Pagado'), findsOneWidget);
    expect(find.text('Marcar como pagado'), findsNothing);
  });

  testWidgets('7. la confirmación pide Confirmar o Cancelar y avisa que no se deshace', (tester) async {
    bool? resultado;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado = await confirmarMarcarPagado(context);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Marcar como pagado'), findsOneWidget);
    expect(
      find.text('¿Deseas marcar este movimiento como pagado? Esta acción no se puede deshacer.'),
      findsOneWidget,
    );
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.byKey(const Key('boton_confirmar_pagado')), findsOneWidget);

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(resultado, isTrue);
  });

  testWidgets('8. con Cancelar no se marca como pagado', (tester) async {
    bool? resultado;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              resultado = await confirmarMarcarPagado(context);
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(resultado, isFalse);
  });

  test('9. un gasto recién creado nace Pendiente y sin pagado_en', () {
    // Así es exactamente la respuesta del backend al crear un movimiento
    final m = Movimiento.desdeJson({
      'id': 42,
      'tipo': 'gasto',
      'concepto': 'Café',
      'monto': 15.5,
      'fecha': '2026-10-05',
      'estado': 'pendiente',
      'pagado_en': null,
    });

    expect(m.estado, 'pendiente');
    expect(m.esPendiente, isTrue);
    expect(m.esPagado, isFalse);
    expect(m.pagadoEn, isNull);
  });

  testWidgets('10. al marcar como pagado se conservan los demás datos', (tester) async {
    var actual = Movimiento.desdeJson({
      'id': 42,
      'tipo': 'gasto',
      'concepto': 'Café',
      'monto': 15.5,
      'fecha': '2026-10-05',
      'estado': 'pendiente',
      'pagado_en': null,
    });

    await tester.pumpWidget(envelopar(StatefulBuilder(builder: (context, setState) {
      return FilaMovimiento(
        movimiento: actual,
        alMarcarPagado: () => setState(
          () => actual = actual.copyWith(
            estado: 'pagado',
            pagadoEn: DateTime.utc(2026, 10, 5, 18, 16),
          ),
        ),
      );
    })));

    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Bs 15.50'), findsOneWidget);
    expect(find.text('5 oct 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton_marcar_pagado')));
    await tester.pumpAndSettle();

    // Solo cambió el estado: el resto sigue igual
    expect(find.text('Pagado'), findsOneWidget);
    expect(find.text('Café'), findsOneWidget);
    expect(find.text('Bs 15.50'), findsOneWidget);
    expect(find.text('5 oct 2026'), findsOneWidget);

    expect(actual.id, 42);
    expect(actual.concepto, 'Café');
    expect(actual.monto, 15.5);
    expect(actual.fecha, DateTime(2026, 10, 5));
    expect(actual.pagadoEn, DateTime.utc(2026, 10, 5, 18, 16));
  });
}