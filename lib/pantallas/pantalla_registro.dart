import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../servicios/servicio_acceso.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    _confirmacion.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final contrasena = _contrasena.text;

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      mostrarMensaje(context, 'Completa todos los campos', esError: true);
      return;
    }
    if (contrasena.length < 6) {
      mostrarMensaje(context, 'La contraseña debe tener mínimo 6 caracteres', esError: true);
      return;
    }
    if (contrasena != _confirmacion.text) {
      mostrarMensaje(context, 'Las contraseñas no coinciden', esError: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      await ServicioAcceso.registrar(nombre, correo, contrasena);
      if (!mounted) return;
      mostrarMensaje(context, 'Cuenta creada. Ahora inicia sesión');
      // Volvemos al login dejando solo la pantalla de inicio detrás
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.login,
        ModalRoute.withName(Rutas.inicio),
      );
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
                'Crear cuenta',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Empieza a organizar tu dinero.',
                style: TextStyle(fontSize: 16, color: Colores.grisAzulado),
              ),
              const SizedBox(height: 32),
              CampoTexto(
                controlador: _nombre,
                etiqueta: 'Nombre',
                icono: Icons.person_outline,
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              CampoTexto(
                controlador: _confirmacion,
                etiqueta: 'Repetir contraseña',
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
                  texto: 'Registrarse',
                  icono: Icons.person_add_alt_outlined,
                  alPresionar: _registrar,
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