import 'package:flutter/material.dart';
import '../../../comun/servicios/api.dart';
import '../servicios/auth_servicio.dart';
import '../servicios/validaciones.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';

class PantallaRecuperar extends StatefulWidget {
  const PantallaRecuperar({super.key});

  @override
  State<PantallaRecuperar> createState() => _PantallaRecuperarState();
}

class _PantallaRecuperarState extends State<PantallaRecuperar> {
  final controlCorreo = TextEditingController();
  String? errorCorreo;
  bool cargando = false;

  @override
  void dispose() {
    controlCorreo.dispose();
    super.dispose();
  }

  Future<void> pedirCodigo() async {
    setState(() => errorCorreo = validarCorreo(controlCorreo.text));
    if (errorCorreo != null) return;

    setState(() => cargando = true);
    try {
      final codigo = await AuthServicio.pedirCodigo(controlCorreo.text);
      if (!mounted) return;
      await mostrarCodigo(codigo);
      if (!mounted) return;
      Navigator.pushNamed(context, '/nueva-contrasena', arguments: controlCorreo.text.trim());
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 404) {
        setState(() => errorCorreo = e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> mostrarCodigo(String codigo) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contexto) => AlertDialog(
        title: Text('Tu código es $codigo', style: Tipografia.titulo),
        content: Text('Usalo en la siguiente pantalla. Vence en 15 minutos.', style: Tipografia.subtitulo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
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
              Text('Recuperar contraseña', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text(
                'Escribí el correo de tu cuenta y te damos un código para crear una contraseña nueva.',
                style: Tipografia.subtitulo,
              ),
              const SizedBox(height: espacio24),
              CampoTexto(
                etiqueta: 'Correo',
                controlador: controlCorreo,
                error: errorCorreo,
                alCambiar: (_) => setState(() => errorCorreo = null),
                pista: 'nombre@correo.com',
                tipoTeclado: TextInputType.emailAddress,
                accionTeclado: TextInputAction.done,
              ),
              const SizedBox(height: espacio32),
              BotonPrincipal(
                texto: 'Pedir código',
                textoCargando: 'Buscando…',
                cargando: cargando,
                alPresionar: pedirCodigo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
