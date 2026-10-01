import 'package:flutter/material.dart';
import '../../servicios/api.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/sesion.dart';
import '../../servicios/validaciones.dart';
import '../../tema/espaciado.dart';
import '../../tema/tipografia.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/campo_texto.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final controlCorreo = TextEditingController();
  final controlContrasena = TextEditingController();
  String? errorCorreo;
  String? errorContrasena;
  bool cargando = false;

  @override
  void dispose() {
    controlCorreo.dispose();
    controlContrasena.dispose();
    super.dispose();
  }

  Future<void> ingresar() async {
    setState(() {
      errorCorreo = validarCorreo(controlCorreo.text);
      errorContrasena = validarObligatorio(controlContrasena.text);
    });
    if (errorCorreo != null || errorContrasena != null) return;

    setState(() => cargando = true);
    try {
      final respuesta = await AuthServicio.iniciarSesion(controlCorreo.text, controlContrasena.text);
      await Sesion.guardar(respuesta.token, respuesta.usuario);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (ruta) => false);
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
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
              Text('Iniciá sesión', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('Entrá para ver tu presupuesto del mes.', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
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
                esContrasena: true,
                accionTeclado: TextInputAction.done,
              ),
              const SizedBox(height: espacio8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/recuperar'),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: espacio24),
              BotonPrincipal(
                texto: 'Ingresar',
                textoCargando: 'Ingresando…',
                cargando: cargando,
                alPresionar: ingresar,
              ),
              const SizedBox(height: espacio16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿No tenés cuenta?', style: Tipografia.subtitulo),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/registro'),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
