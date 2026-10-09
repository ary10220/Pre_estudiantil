import 'package:flutter/material.dart';
import '../../../comun/modelos/usuario.dart';
import '../../../comun/servicios/api.dart';
import '../servicios/auth_servicio.dart';
import '../../../comun/servicios/guardia.dart';
import '../../../comun/servicios/sesion.dart';
import '../../../comun/tema/colores.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/boton_secundario.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  Usuario? usuario;
  bool saliendo = false;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  // Muestra el usuario guardado y después confirma con el backend que la sesión sigue activa
  Future<void> cargarUsuario() async {
    final guardado = await Sesion.leerUsuario();
    if (mounted) setState(() => usuario = guardado);

    if (!mounted) return;
    final token = await leerTokenOIrAlLogin(context);
    if (token == null) return;
    try {
      final actual = await AuthServicio.usuarioActual(token);
      if (mounted) setState(() => usuario = actual);
    } on ErrorApi catch (e) {
      if (e.codigo == 401 && mounted) {
        mandarAlLogin(context, e.mensaje);
      }
    }
  }

  Future<void> cerrarSesion() async {
    setState(() => saliendo = true);
    final token = await Sesion.leerToken();
    if (token != null) {
      try {
        await AuthServicio.salir(token);
      } on ErrorApi {
        // Aunque el servidor no responda, la sesión se cierra en el celular
      }
    }
    await Sesion.borrar();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (usuario == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: colorMarca)));
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(margenLateral, espacio48, margenLateral, espacio24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hola, ${usuario?.nombre ?? ''}', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text(usuario?.correo ?? '', style: Tipografia.subtitulo),
              const SizedBox(height: espacio24),
              Container(
                padding: const EdgeInsets.all(espacio16),
                decoration: BoxDecoration(
                  color: colorSuperficie,
                  border: Border.all(color: colorBorde),
                  borderRadius: BorderRadius.circular(espacio16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tu presupuesto del mes', style: Tipografia.etiqueta),
                    const SizedBox(height: espacio8),
                    Text(
                      'Anotá tus gastos del día y revisalos cuando quieras.',
                      style: Tipografia.subtitulo,
                    ),
                    const SizedBox(height: espacio16),
                    BotonPrincipal(
                      texto: 'Mis movimientos',
                      textoCargando: 'Mis movimientos',
                      alPresionar: () => Navigator.pushNamed(context, '/movimientos'),
                    ),
                    const SizedBox(height: espacio16),
                    BotonSecundario(
                      texto: 'Límite del mes',
                      alPresionar: () => Navigator.pushNamed(context, '/limite'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: espacio32),
              BotonSecundario(
                texto: saliendo ? 'Cerrando sesión…' : 'Cerrar sesión',
                alPresionar: saliendo ? () {} : cerrarSesion,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
