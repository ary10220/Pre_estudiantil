import 'package:flutter/material.dart';
import '../../../comun/servicios/api.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/tema/colores.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../modelos/movimiento.dart';
import '../servicios/movimientos_servicio.dart';
import '../widgets/confirmacion_eliminar.dart';
import '../widgets/confirmacion_pagar.dart';
import '../widgets/fila_movimiento.dart';
import 'pantalla_editar_gasto.dart';

class PantallaMovimientos extends StatefulWidget {
  const PantallaMovimientos({super.key});

  @override
  State<PantallaMovimientos> createState() => _PantallaMovimientosState();
}

class _PantallaMovimientosState extends State<PantallaMovimientos> {
  List<Movimiento> movimientos = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarMovimientos();
  }

  // Siempre se pide la lista al backend: lo que se ve es lo que está guardado en la base
  Future<void> cargarMovimientos() async {
    final token = await leerTokenOIrAlLogin(context);
    if (token == null) return;
    try {
      final lista = await MovimientosServicio.listar(token);
      if (mounted) {
        setState(() {
          movimientos = lista;
          error = null;
        });
      }
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else if (movimientos.isEmpty) {
        setState(() => error = e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // El formulario devuelve true si guardó; recién ahí se vuelve a pedir la lista
  Future<void> abrirNuevoGasto() async {
    final guardado = await Navigator.pushNamed(context, '/movimientos/nuevo');
    if (guardado != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gasto guardado')));
    await cargarMovimientos();
  }

  Future<void> marcarComoPagado(int id) async {
    final token = await leerTokenOIrAlLogin(context);
    if (token == null || !mounted) return;

    if (!mounted) return;
    final confirmado = await confirmarMarcarPagado(context);
    if (!confirmado || !mounted) return;

    try {
      final actualizado = await MovimientosServicio.marcarPagado(token, id);
      if (!mounted) return;
      setState(() {
        final idx = movimientos.indexWhere((m) => m.id == id);
        if (idx >= 0) {
          movimientos[idx] = actualizado;
        } else {
          movimientos = movimientos.map((m) => m.id == id ? actualizado : m).toList();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento marcado como pagado')));
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    }
  }

  Future<void> editarGasto(Movimiento movimiento) async {
    final editado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PantallaEditarGasto(movimiento: movimiento)),
    );
    if (editado != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gasto actualizado')));
    await cargarMovimientos();
  }

  Future<void> eliminarGasto(Movimiento movimiento) async {
    final confirmado = await confirmarEliminarMovimiento(context);
    if (!confirmado || !mounted) return;

    final token = await leerTokenOIrAlLogin(context);
    if (token == null || !mounted) return;

    try {
      await MovimientosServicio.eliminarMovimiento(token, movimiento.id);
      if (!mounted) return;
      setState(() => movimientos.removeWhere((m) => m.id == movimiento.id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento eliminado')));
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    }
  }

  List<Widget> contenido() {
    if (error != null) {
      return [
        Text(error!, style: Tipografia.cuerpo),
        const SizedBox(height: espacio8),
        Text('Deslizá hacia abajo para intentar de nuevo.', style: Tipografia.subtitulo),
      ];
    }
    if (movimientos.isEmpty) {
      return [
        Text('Todavía no registraste movimientos', style: Tipografia.cuerpo),
        const SizedBox(height: espacio16),
        BotonPrincipal(
          texto: 'Registrar gasto',
          textoCargando: 'Registrar gasto',
          alPresionar: abrirNuevoGasto,
        ),
      ];
    }
    return [
      for (final movimiento in movimientos) ...[
        FilaMovimiento(
          movimiento: movimiento,
          alMarcarPagado: () => marcarComoPagado(movimiento.id),
          alEditar: () => editarGasto(movimiento),
          alEliminar: () => eliminarGasto(movimiento),
        ),
        const SizedBox(height: espacio8),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirNuevoGasto,
        tooltip: 'Registrar gasto',
        backgroundColor: colorMarca,
        foregroundColor: colorSuperficie,
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: colorMarca))
          : RefreshIndicator(
              color: colorMarca,
              onRefresh: cargarMovimientos,
              child: ListView(
                // Para poder deslizar aunque la lista esté vacía
                physics: const AlwaysScrollableScrollPhysics(),
                // Abajo deja lugar para el botón +
                padding: const EdgeInsets.fromLTRB(margenLateral, espacio8, margenLateral, espacio48 + espacio32),
                children: [
                  Text('Mis movimientos', style: Tipografia.titulo),
                  const SizedBox(height: espacio8),
                  Text('Tus gastos, del más nuevo al más viejo.', style: Tipografia.subtitulo),
                  const SizedBox(height: espacio24),
                  ...contenido(),
                ],
              ),
            ),
    );
  }
}
