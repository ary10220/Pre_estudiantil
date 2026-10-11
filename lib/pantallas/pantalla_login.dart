import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../servicios/servicio_acceso.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;

    if (correo.isEmpty || contrasena.isEmpty) {
      mostrarMensaje(context, 'Completa todos los campos', esError: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      await ServicioAcceso.iniciarSesion(correo, contrasena);
      if (!mounted) return;
      // Entramos a la zona privada y borramos el historial de pantallas
      Navigator.pushNamedAndRemoveUntil(context, Rutas.movimientos, (ruta) => false);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
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
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entra para ver tus movimientos.',
                style: TextStyle(fontSize: 16, color: Colores.grisAzulado),
              ),
              const SizedBox(height: 40),
              CampoTexto(
                controlador: _correo,
                etiqueta: 'Correo',
                icono: Icons.mail_outline,
                tipoTeclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _contrasena,
                etiqueta: 'Contraseña',
                icono: Icons.lock_outline,
                esContrasena: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: _cargando
                    ? const Center(
                  child: CircularProgressIndicator(color: Colores.verdeOscuro),
                )
                    : BotonPildora(
                  texto: 'Entrar',
                  icono: Icons.person_outline,
                  alPresionar: _iniciarSesion,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Rutas.recuperar),
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Colores.verdeOscuro),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Rutas.registro),
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colores.verdeOscuro),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}