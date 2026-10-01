import 'package:flutter/material.dart';
import '../../modelos/usuario.dart';
import '../../servicios/api.dart';
import '../../servicios/auth_servicio.dart';
import '../../servicios/sesion.dart';
import '../../tema/colores.dart';
import '../../tema/espaciado.dart';
import '../../tema/tipografia.dart';
import '../../widgets/boton_secundario.dart';

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

    final token = await Sesion.leerToken();
    if (token == null) return irAlLogin('Tu sesión terminó, iniciá sesión de nuevo');
    try {
      final actual = await AuthServicio.usuarioActual(token);
      if (mounted) setState(() => usuario = actual);
    } on ErrorApi catch (e) {
      if (e.codigo == 401) {
        await Sesion.borrar();
        irAlLogin(e.mensaje);
      }
    }
  }

  void irAlLogin(String mensaje) {
    if (!mounted) return;
    final mensajero = ScaffoldMessenger.of(context);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (ruta) => false);
    mensajero.showSnackBar(SnackBar(content: Text(mensaje)));
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
                      'Todavía no registraste ingresos ni gastos. Pronto vas a poder hacerlo desde acá.',
                      style: Tipografia.subtitulo,
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
