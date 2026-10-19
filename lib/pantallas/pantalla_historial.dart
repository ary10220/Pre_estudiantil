import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/evento.dart';
import '../modelos/limite.dart' show formatearBs;
import '../servicios/servicio_historial.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/mensajes.dart';

// Historial de actividad (Tarea 4): lista agrupada por día, filtrable por chip.
// Las 3 decisiones de interacción están en docs/decisiones-interaccion.md.
class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  List<GrupoDia> _grupos = [];
  FiltroHistorial _filtro = FiltroHistorial.todos;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final grupos = await ServicioHistorial.listar(filtro: _filtro);
      if (!mounted) return;
      setState(() {
        _grupos = grupos;
        _cargando = false;
      });
    } on SesionExpirada {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      mostrarMensaje(context, _mensajeError(e), esError: true);
    }
  }

  String _mensajeError(Exception e) {
    final texto = e.toString();
    return texto.startsWith('Instance of ') ? 'No se pudo cargar el historial' : texto;
  }

  Future<void> _cambiarFiltro(FiltroHistorial nuevo) async {
    if (_filtro == nuevo) return;
    setState(() => _filtro = nuevo);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _barraFiltros(),
            const SizedBox(height: 12),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  // Hick: 4 chips mutuamente excluyentes. Ingresos aparecen solo en "Todos".
  Widget _barraFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in FiltroHistorial.values) ...[
            ChoiceChip(
              label: Text(f.etiqueta),
              selected: _filtro == f,
              onSelected: (_) => _cambiarFiltro(f),
              selectedColor: Colores.verdeOscuro,
              backgroundColor: Colores.verdeClaro,
              labelStyle: TextStyle(
                color: _filtro == f ? Colors.white : Colores.verdeOscuro,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colores.verdeOscuro),
      );
    }
    if (_grupos.isEmpty) return _estadoVacio();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _grupos.length,
      itemBuilder: (context, i) => _grupoDia(_grupos[i]),
    );
  }

  Widget _estadoVacio() {
    final sinFiltro = _filtro == FiltroHistorial.todos;
    final texto = sinFiltro
        ? 'Todavía no hay actividad.\nRegistrá tu primer gasto y lo vas a ver acá.'
        : 'No hay actividad para "${_filtro.etiqueta}".';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 72, color: Colores.verdeClaro),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colores.grisAzulado,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (sinFiltro)
            FilledButton.icon(
              onPressed: () async {
                final creado = await Navigator.pushNamed(context, Rutas.nuevoMovimiento);
                if (creado == true) await _cargar();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colores.verdeOscuro,
                minimumSize: const Size(220, 48),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Registrar gasto'),
            )
          else
            TextButton(
              onPressed: () => _cambiarFiltro(FiltroHistorial.todos),
              child: const Text(
                'Ver todos',
                style: TextStyle(color: Colores.verdeOscuro),
              ),
            ),
        ],
      ),
    );
  }

  Widget _grupoDia(GrupoDia grupo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            grupo.titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colores.azulOscuro,
            ),
          ),
        ),
        for (final evento in grupo.eventos) _tarjetaEvento(evento),
      ],
    );
  }

  // Carga cognitiva: ícono + frase completa + monto + hora, en una sola tarjeta.
  // Nada que recordar ni calcular.
  Widget _tarjetaEvento(Evento evento) {
    final estilo = _estiloDeTipo(evento.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: estilo.fondoIcono,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(estilo.icono, color: estilo.colorIcono, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estilo.frase(evento.descripcion),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colores.azulOscuro,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (evento.monto != null)
                      Text(
                        formatearBs(evento.monto!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: estilo.colorMonto,
                        ),
                      ),
                    if (evento.monto != null)
                      const Text(' · ', style: TextStyle(color: Colores.grisAzulado)),
                    Text(
                      evento.hora,
                      style: const TextStyle(fontSize: 14, color: Colores.grisAzulado),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _EstiloEvento _estiloDeTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.gastoRegistrado:
        return _EstiloEvento(
          icono: Icons.trending_down,
          colorIcono: Colores.rojo,
          fondoIcono: const Color(0xFFFFE0E0),
          colorMonto: Colores.rojo,
          frase: (d) => d.isEmpty ? 'Registraste un gasto' : 'Registraste gasto: $d',
        );
      case TipoEvento.ingresoRegistrado:
        return _EstiloEvento(
          icono: Icons.trending_up,
          colorIcono: Colores.verdeOscuro,
          fondoIcono: Colores.verdeClaro,
          colorMonto: Colores.verdeOscuro,
          frase: (d) => d.isEmpty ? 'Registraste un ingreso' : 'Registraste ingreso: $d',
        );
      case TipoEvento.movimientoPagado:
        return _EstiloEvento(
          icono: Icons.check_circle_outline,
          colorIcono: Colores.verdeOscuro,
          fondoIcono: Colores.verdeClaro,
          colorMonto: Colores.azulOscuro,
          frase: (d) => d.isEmpty ? 'Marcaste como pagado un movimiento' : 'Marcaste como pagado: $d',
        );
      case TipoEvento.limiteDefinido:
        return _EstiloEvento(
          icono: Icons.savings_outlined,
          colorIcono: Colores.verdeOscuro,
          fondoIcono: Colores.verdeClaro,
          colorMonto: Colores.azulOscuro,
          frase: (d) => d.isEmpty ? 'Definiste tu límite mensual' : 'Definiste tu límite: $d',
        );
    }
  }
}

class _EstiloEvento {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final Color colorMonto;
  final String Function(String descripcion) frase;

  const _EstiloEvento({
    required this.icono,
    required this.colorIcono,
    required this.fondoIcono,
    required this.colorMonto,
    required this.frase,
  });
}
