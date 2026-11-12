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
  Map<String, dynamic> _datos = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await AnaliticaServicio.obtenerResumen();
    if (!mounted) return;
    setState(() {
      _datos = datos;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mov = _datos['movimientos'] as Map<String, dynamic>? ?? {};
    final metas = _datos['metas'] as Map<String, dynamic>? ?? {};
    final limites = _datos['limites'] as Map<String, dynamic>? ?? {};
    final aviso = _datos['avisoLimite'] as Map<String, dynamic>? ?? {};
    final errores = _datos['erroresFormulario'] as Map<String, dynamic>? ?? {};
    final busquedasSinRes = _datos['busquedasSinResultado'] as int? ?? 0;
    final ultimos = _datos['ultimos'] as List<dynamic>? ?? [];

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
                    'Embudos de los flujos principales',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Monitoreo de conversion y caida por flujo (inicio -> exito)',
                    style: TextStyle(color: Colores.grisAzulado, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // 1. Embudo Movimientos
                  _tarjetaEmbudo(
                    titulo: '1. Registrar movimiento',
                    pasoInicio: 'Iniciados: ${mov['iniciados'] ?? 0}',
                    pasoExito: 'Guardados: ${mov['guardados'] ?? 0}',
                    tasaConversion: '${mov['conversion'] ?? 0.0} %',
                    tasaCaida: '${mov['caida'] ?? 0.0} %',
                    icono: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 12),

                  // 2. Embudo metas
                  _tarjetaEmbudo(
                    titulo: '2. Crear Meta de Ahorro',
                    pasoInicio: 'Iniciadas: ${metas['iniciadas'] ?? 0}',
                    pasoExito: 'Guardadas: ${metas['guardadas'] ?? 0}',
                    tasaConversion: '${metas['conversion'] ?? 0.0} %',
                    tasaCaida: '${metas['caida'] ?? 0.0} %',
                    detalleExtra:
                        'Operaciones de fondos: ${metas['fondosOperados'] ?? 0}',
                    icono: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 12),

                  // 3. Embudo limites
                  _tarjetaEmbudo(
                    titulo: '3. Fijar Presupuesto / Limite',
                    pasoInicio: 'Aperturas: ${limites['iniciados'] ?? 0}',
                    pasoExito: 'Guardados: ${limites['guardados'] ?? 0}',
                    tasaConversion: '${limites['conversion'] ?? 0.0} %',
                    tasaCaida: '${limites['caida'] ?? 0.0} %',
                    icono: Icons.savings_outlined,
                  ),
                  const SizedBox(height: 20),

                  // 4 Efectividad del aviso de limite (Parte B)
                  const Text(
                    'Efectividad del aviso de limite (Parte B)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _tarjetaAviso(aviso),
                  const SizedBox(height: 20),

                  // 5 Puntos de friccion
                  const Text(
                    'Puntos de fricción y busquedas en blanco',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _tarjetaFriccion(errores, busquedasSinRes),
                  const SizedBox(height: 24),

                  // 6 Ultimos Eventos
                  const Text(
                    'Ultimos eventos registrados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colores.azulOscuro,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (ultimos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aun no hay eventos registrados.',
                        style: TextStyle(color: Colores.grisAzulado),
                      ),
                    )
                  else
                    for (final ev in ultimos) _filaEvento(ev),
                ],
              ),
      ),
    );
  }

  Widget _tarjetaEmbudo({
    required String titulo,
    required String pasoInicio,
    required String pasoExito,
    required String tasaConversion,
    required String tasaCaida,
    String? detalleExtra,
    required IconData icono,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: Colores.verdeOscuro, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colores.azulOscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pasoInicio,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colores.grisAzulado,
                ),
              ),
              Text(
                pasoExito,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colores.azulOscuro,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Caida: $tasaCaida',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colores.rojo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colores.verdeClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Exito: $tasaConversion',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colores.verdeOscuro,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (detalleExtra != null) ...[
            const SizedBox(height: 6),
            Text(
              detalleExtra,
              style: const TextStyle(
                fontSize: 12,
                color: Colores.grisAzulado,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaAviso(Map<String, dynamic> aviso) {
    final mostrados = aviso['mostrados'] ?? 0;
    final cancelados = aviso['cancelados'] ?? 0;
    final confirmados = aviso['confirmados'] ?? 0;
    final disuasion = aviso['tasaDisuasion'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avisos mostrados: $mostrados',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colores.azulOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '• Cancelados (evito gasto): $cancelados\n• Confirmados (asumio exceso): $confirmados',
            style: const TextStyle(
              fontSize: 13,
              color: Colores.grisAzulado,
              height: 1.4,
            ),
          ),
          Text(
            'Disuasion: $disuasion %',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colores.verdeOscuro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaFriccion(Map<String, dynamic> errores, int busquedasSinRes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Búsquedas sin resultados: $busquedasSinRes',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colores.azulOscuro,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Errores que frenaron el formulario:',
            style: TextStyle(fontSize: 13, color: Colores.grisAzulado),
          ),
          const SizedBox(height: 4),
          if (errores.length <= 1)
            const Text(
              'Sin errores registrados',
              style: TextStyle(
                fontSize: 12,
                color: Colores.grisAzulado,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (final entry in errores.entries)
              Text(
                '• ${entry.key}: ${entry.value}',
                style: const TextStyle(fontSize: 12, color: Colores.rojo),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colores.grisAzulado,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
