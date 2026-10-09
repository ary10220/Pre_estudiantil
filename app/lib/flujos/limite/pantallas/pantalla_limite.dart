import 'package:flutter/material.dart';
import '../../../comun/servicios/api.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/campo_texto.dart';
import '../servicios/limite_servicio.dart';
import '../servicios/validaciones.dart';

class PantallaLimite extends StatefulWidget {
  const PantallaLimite({super.key});

  @override
  State<PantallaLimite> createState() => _PantallaLimiteState();
}

class _PantallaLimiteState extends State<PantallaLimite> {
  final controlLimite = TextEditingController();
  String? errorLimite;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarLimite();
  }

  @override
  void dispose() {
    controlLimite.dispose();
    super.dispose();
  }

  // Al entrar se pide el límite a la base: así se ve lo guardado aunque se cierre la app
  Future<void> cargarLimite() async {
    final token = await leerTokenOIrAlLogin(context);
    if (token == null) return;
    try {
      final limite = await LimiteServicio.leer(token);
      if (mounted && limite != null) {
        setState(() => controlLimite.text = limite.toStringAsFixed(2));
      }
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    }
  }

  Future<void> guardarLimite() async {
    setState(() => errorLimite = validarLimite(controlLimite.text));
    if (errorLimite != null) return;

    final token = await leerTokenOIrAlLogin(context);
    if (token == null || !mounted) return;

    setState(() => guardando = true);
    try {
      await LimiteServicio.guardar(token, leerLimite(controlLimite.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Límite guardado')));
    } on ErrorApi catch (e) {
      if (!mounted) return;
      if (e.codigo == 401) {
        mandarAlLogin(context, e.mensaje);
      } else if (e.codigo == 400) {
        setState(() => errorLimite = e.mensaje);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensaje)));
      }
    } finally {
      if (mounted) setState(() => guardando = false);
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
              Text('Límite del mes', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text('Cuánto querés gastar como máximo este mes.', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
              CampoTexto(
                etiqueta: 'Límite del mes (Bs)',
                controlador: controlLimite,
                error: errorLimite,
                alCambiar: (_) => setState(() => errorLimite = null),
                pista: 'Ej.: 500',
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                accionTeclado: TextInputAction.done,
              ),
              const SizedBox(height: espacio32),
              BotonPrincipal(
                texto: 'Guardar límite',
                textoCargando: 'Guardando…',
                cargando: guardando,
                alPresionar: guardarLimite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
