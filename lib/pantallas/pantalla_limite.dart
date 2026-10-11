import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/limite.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_limite.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';

class PantallaLimite extends StatefulWidget {
  const PantallaLimite({super.key});

  @override
  State<PantallaLimite> createState() => _PantallaLimiteState();
}

class _PantallaLimiteState extends State<PantallaLimite> {
  final _limite = TextEditingController();
  String? _errorLimite;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarLimite();
  }

  @override
  void dispose() {
    _limite.dispose();
    super.dispose();
  }

  void _volverAlLogin() {
    Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
  }

  // Al entrar se pide el límite a la base: así se ve lo guardado aunque se cierre la app
  Future<void> _cargarLimite() async {
    try {
      final limite = await ServicioLimite.leer();
      if (!mounted || limite == null) return;
      setState(() => _limite.text = limite.toStringAsFixed(2));
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    }
  }

  Future<void> _guardar() async {
    setState(() => _errorLimite = validarLimite(_limite.text));
    if (_errorLimite != null) return;

    setState(() => _cargando = true);
    try {
      await ServicioLimite.guardar(leerLimite(_limite.text));
      if (!mounted) return;
      mostrarMensaje(context, 'Límite guardado');
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      // Si el servidor rechazó el valor, el mensaje va debajo del campo
      if (e.mensaje == mensajeLimiteNoValido) {
        setState(() => _errorLimite = e.mensaje);
      } else {
        mostrarMensaje(context, e.mensaje, esError: true);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Límite del mes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuánto querés gastar como máximo este mes.',
                style: TextStyle(fontSize: 16, color: Colores.grisAzulado),
              ),
              const SizedBox(height: 32),
              CampoTexto(
                controlador: _limite,
                etiqueta: 'Límite del mes (Bs)',
                icono: Icons.savings_outlined,
                pista: 'Ej.: 500',
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                error: _errorLimite,
                alCambiar: (_) => setState(() => _errorLimite = null),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(color: Colores.verdeOscuro),
                )
                    : BotonPildora(
                  texto: 'Guardar límite',
                  icono: Icons.check,
                  alPresionar: _guardar,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
