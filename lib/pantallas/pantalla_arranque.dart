import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../servicios/servicio_acceso.dart';
import '../widgets/boton_pildora.dart';

class PantallaArranque extends StatefulWidget {
  const PantallaArranque({super.key});

  @override
  State<PantallaArranque> createState() => _PantallaArranqueState();
}

class _PantallaArranqueState extends State<PantallaArranque> {
  // Hay sesión guardada pero el servidor no respondió (H9.3)
  bool _sinConexion = false;

  @override
  void initState() {
    super.initState();
    _decidirDestino();
  }

  Future<void> _decidirDestino() async {
    if (_sinConexion) setState(() => _sinConexion = false);
    String? nombre;
    try {
      nombre = await ServicioAcceso.obtenerNombreSesion();
    } on ErrorAcceso {
      // Sin conexión no se sabe si la sesión vale: se avisa en vez de mandar a Inicio
      if (mounted) setState(() => _sinConexion = true);
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      nombre != null ? Rutas.movimientos : Rutas.inicio,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sinConexion) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colores.verdeOscuro)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.wifi_off, size: 56, color: Colores.grisAzulado),
              const SizedBox(height: 16),
              const Text(
                'No se pudo conectar con el servidor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu sesión sigue guardada. Revisa tu conexión e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colores.grisAzulado, height: 1.4),
              ),
              const SizedBox(height: 32),
              BotonPildora(
                texto: 'Reintentar',
                icono: Icons.refresh,
                alPresionar: _decidirDestino,
              ),
            ],
          ),
        ),
      ),
    );
  }
}