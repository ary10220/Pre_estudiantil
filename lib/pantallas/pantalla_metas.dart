import 'package:flutter/material.dart';

import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/meta_ahorro.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_metas.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/resumen_metas_card.dart';
import 'pantalla_detalle_meta.dart';
import 'pantalla_nueva_meta.dart';

class PantallaMetas extends StatefulWidget {
  const PantallaMetas({super.key});

  @override
  State<PantallaMetas> createState() => _PantallaMetasState();
}

class _PantallaMetasState extends State<PantallaMetas> {
  List<MetaAhorro> _metas = [];
  ResumenMetas? _resumen;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await ServicioMetas.listar();
      if (!mounted) return;
      setState(() {
        _metas = resultado.metas;
        _resumen = resultado.resumen;
        _cargando = false;
      });
    } on SesionExpirada {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _abrirNuevaMeta() async {
    final creada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PantallaNuevaMeta()),
    );
    if (creada == true) await _cargar();
  }

  Future<void> _abrirDetalle(MetaAhorro meta) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaDetalleMeta(meta: meta)),
    );
    if (mounted) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de ahorro'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevaMeta,
        backgroundColor: Colores.verdeOscuro,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva meta'),
      ),
      body: SafeArea(child: _contenido()),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colores.verdeOscuro),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colores.grisAzulado),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _cargar,
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colores.verdeOscuro),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final resumen = _resumen;
    if (resumen == null) {
      return const Center(
        child: Text(
          'No se pudo cargar el resumen de metas.',
          style: TextStyle(color: Colores.grisAzulado),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
      children: [
        ResumenMetasCard(resumen: resumen),
        const SizedBox(height: 16),
        if (_metas.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Text(
              'Aún no tienes metas de ahorro.\nCrea la primera con el botón de abajo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colores.grisAzulado,
                height: 1.5,
              ),
            ),
          )
        else
          for (final meta in _metas) _tarjetaMeta(meta),
      ],
    );
  }

  Widget _tarjetaMeta(MetaAhorro meta) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _abrirDetalle(meta),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colores.verdeClaro),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colores.azulOscuro,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colores.grisAzulado),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${meta.montoReservadoTexto} de ${meta.montoObjetivoTexto}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colores.verdeOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: meta.progreso.clamp(0, 1).toDouble(),
                    minHeight: 8,
                    color: Colores.verdeOscuro,
                    backgroundColor: Colores.verdeClaro,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Falta ${meta.restanteTexto} · ${meta.fechaTexto}',
                  style: const TextStyle(color: Colores.grisAzulado),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
