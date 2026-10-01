import 'package:flutter/material.dart';
import '../../servicios/api.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/validaciones.dart';
import '../../tema/espaciado.dart';
import '../../tema/tipografia.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/campo_texto.dart';

class PantallaNuevaContrasena extends StatefulWidget {
  const PantallaNuevaContrasena({super.key});

  @override
  State<PantallaNuevaContrasena> createState() => _PantallaNuevaContrasenaState();
}

class _PantallaNuevaContrasenaState extends State<PantallaNuevaContrasena> {
  final controlCodigo = TextEditingController();
  final controlNueva = TextEditingController();
  final controlRepetir = TextEditingController();
  String? errorCodigo;
  String? errorNueva;
  String? errorRepetir;
  bool cargando = false;

  @override
  void dispose() {
    controlCodigo.dispose();
    controlNueva.dispose();
    controlRepetir.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    final correo = ModalRoute.of(context)!.settings.arguments as String;

    setState(() {
      errorCodigo = validarCodigo(controlCodigo.text);
      errorNueva = validarContrasena(controlNueva.text);
      errorRepetir = validarRepetida(controlNueva.text, controlRepetir.text);
    });
    if (errorCodigo != null || errorNueva != null || errorRepetir != null) return;

    setState(() => cargando = true);
    try {
      await AuthServicio.cambiarContrasena(correo, controlCodigo.text.trim(), controlNueva.text);
      if (!mounted) return;
      final mensajero = ScaffoldMessenger.of(context);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (ruta) => ruta.settings.name == '/');
      mensajero.showSnackBar(const SnackBar(content: Text('Contraseña actualizada, ya podés ingresar')));
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.mensaje == 'El código no coincide' || e.mensaje == 'El código venció') {
        setState(() => errorCodigo = e.mensaje);
      } else if (e.mensaje == 'Mínimo 6 caracteres') {
        setState(() => errorNueva = e.mensaje);
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
              Text('Nueva contraseña', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('Escribí el código que te dimos y tu contraseña nueva.', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
              CampoTexto(
                etiqueta: 'Código',
                controlador: controlCodigo,
                error: errorCodigo,
                alCambiar: (_) => setState(() => errorCodigo = null),
                pista: '6 dígitos',
                tipoTeclado: TextInputType.number,
                largoMaximo: 6,
              ),
              const SizedBox(height: espacio16),
              CampoTexto(
                etiqueta: 'Contraseña nueva',
                controlador: controlNueva,
                error: errorNueva,
                alCambiar: (_) => setState(() => errorNueva = null),
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
                texto: 'Guardar contraseña',
                textoCargando: 'Guardando…',
                cargando: cargando,
                alPresionar: guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
