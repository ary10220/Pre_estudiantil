import 'package:flutter/material.dart';

import '../configuracion/constantes.dart';
import '../servicios/analitica.dart';

class PantallaAnalitica extends StatefulWidget {
  const PantallaAnalitica({super.key});

  @override
  State<PantallaAnalitica> createState() => _PantallaAnaliticaState();
}

class _PantallaAnaliticaState extends State<PantallaAnalitica> {
  bool _cargando = true;
  int _iniciados = 0;
  int _guardados = 0;
  double _porcentaje = 0;
  List<dynamic> _ultimos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await AnaliticaServicio.obtenerResumen();
    if (!mounted) return;
    setState(() {
      _iniciados = (datos['iniciados'] as num?)?.toInt() ?? 0;
      _guardados = (datos['guardados'] as num?)?.toInt() ?? 0;
      _porcentaje = (datos['porcentaje'] as num?)?.toDouble() ?? 0.0;
      _ultimos = (datos['ultimos'] as List?) ?? [];
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analítica de interacción'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(color: Colores.verdeOscuro),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Embudo del flujo principal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Medición de usuarios que empiezan y completan un movimiento.',
                    style: TextStyle(color: Colores.grisAzulado, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _tarjetaMetrica(
                    titulo: 'Movimientos iniciados',
                    valor: '$_iniciados',
                    subtitulo: 'Aperturas del formulario',
                    colorValor: Colores.azulOscuro,
                  ),
                  const SizedBox(height: 12),
                  _tarjetaMetrica(
                    titulo: 'Movimientos guardados',
                    valor: '$_guardados',
                    subtitulo: 'Confirmados en la base de datos',
                    colorValor: Colores.verdeOscuro,
                  ),
                  const SizedBox(height: 12),
                  _tarjetaMetrica(
                    titulo: 'Tasa de finalización',
                    valor: '$_porcentaje %',
                    subtitulo: 'Guardados ÷ Iniciados × 100',
                    colorValor: _porcentaje >= 70
                        ? Colores.verdeOscuro
                        : (_porcentaje >= 40 ? Colores.aviso : Colores.rojo),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Últimos eventos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ultimos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aún no hay eventos registrados.',
                        style: TextStyle(color: Colores.grisAzulado),
                      ),
                    )
                  else
                    for (final ev in _ultimos) _filaEvento(ev),
                ],
              ),
      ),
    );
  }

  Widget _tarjetaMetrica({
    required String titulo,
    required String valor,
    required String subtitulo,
    required Color colorValor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colores.grisAzulado,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 12, color: Colores.grisAzulado),
                ),
              ],
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: colorValor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEvento(dynamic ev) {
    final nombre = ev['evento'] as String? ?? '';
    final props = ev['props'] as Map<String, dynamic>? ?? {};
    final fecha = ev['fecha'] as String? ?? '';
    final esExito = nombre == 'movimiento_guardado';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colores.verdeClaro.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            esExito ? Icons.check_circle_outline : Icons.play_circle_outline,
            color: esExito ? Colores.verdeOscuro : Colores.azulOscuro,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colores.azulOscuro,
                  ),
                ),
                Text(
                  'tipo: ${props['tipo'] ?? 'desconocido'} · $fecha',
                  style: const TextStyle(fontSize: 11, color: Colores.grisAzulado),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
