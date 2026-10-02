import 'package:flutter/material.dart';
import '../../../comun/servicios/api.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/validaciones.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final controlNombre = TextEditingController();
  final controlCorreo = TextEditingController();
  final controlContrasena = TextEditingController();
  final controlRepetir = TextEditingController();
  String? errorNombre;
  String? errorCorreo;
  String? errorContrasena;
  String? errorRepetir;
  bool cargando = false;

  @override
  void dispose() {
    controlNombre.dispose();
    controlCorreo.dispose();
    controlContrasena.dispose();
    controlRepetir.dispose();
    super.dispose();
  }

  Future<void> crearCuenta() async {
    setState(() {
      errorNombre = validarObligatorio(controlNombre.text);
      errorCorreo = validarCorreo(controlCorreo.text);
      errorContrasena = validarContrasena(controlContrasena.text);
      errorRepetir = validarRepetida(controlContrasena.text, controlRepetir.text);
    });
    if (errorNombre != null || errorCorreo != null || errorContrasena != null || errorRepetir != null) {
      return;
    }

    setState(() => cargando = true);
    try {
      await AuthServicio.registrar(controlNombre.text, controlCorreo.text, controlContrasena.text);
      if (!mounted) return;
      final mensajero = ScaffoldMessenger.of(context);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (ruta) => ruta.settings.name == '/');
      mensajero.showSnackBar(const SnackBar(content: Text('Cuenta creada, ya podés ingresar')));
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 409 || e.mensaje == 'Escribí un correo válido') {
        setState(() => errorCorreo = e.mensaje);
      } else if (e.mensaje == 'Mínimo 6 caracteres') {
        setState(() => errorContrasena = e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(margenLateral, espacio8, margenLateral, espacio24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Crear cuenta', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('Con tu cuenta vas a poder registrar tus ingresos y gastos.', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
              CampoTexto(
                etiqueta: 'Nombre',
                controlador: controlNombre,
                error: errorNombre,
                alCambiar: (_) => setState(() => errorNombre = null),
                pista: 'Cómo te llamás',
                tipoTeclado: TextInputType.name,
              ),
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Correo',
                controlador: controlCorreo,
                error: errorCorreo,
                alCambiar: (_) => setState(() => errorCorreo = null),
                pista: 'nombre@correo.com',
                tipoTeclado: TextInputType.emailAddress,
              ),
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Contraseña',
                controlador: controlContrasena,
                error: errorContrasena,
                alCambiar: (_) => setState(() => errorContrasena = null),
                ayuda: 'Mínimo 6 caracteres',
                esContrasena: true,
              ),
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Repetir contraseña',
                controlador: controlRepetir,
                error: errorRepetir,
                alCambiar: (_) => setState(() => errorRepetir = null),
                esContrasena: true,
                accionTeclado: TextInputAction.done,
              ),
              const SizedBox(height: espacio32),
              BotonPrincipal(
                texto: 'Crear cuenta',
                textoCargando: 'Guardando…',
                cargando: cargando,
                alPresionar: crearCuenta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
