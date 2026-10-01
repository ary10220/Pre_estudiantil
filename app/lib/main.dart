import 'package:flutter/material.dart';
import 'rutas.dart';
import 'servicios/sesion.dart';
import 'tema/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final haySesion = await Sesion.haySesion();
  runApp(MiApp(rutaInicial: haySesion ? '/inicio' : '/'));
}

class MiApp extends StatelessWidget {
  final String rutaInicial;

  const MiApp({super.key, required this.rutaInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presupuesto Estudiantil',
      debugShowCheckedModeBanner: false,
      theme: crearTema(),
      initialRoute: rutaInicial,
      routes: rutas,
      // Sin esto, al arrancar en /inicio Flutter deja la bienvenida debajo
      onGenerateInitialRoutes: (ruta) => [
        MaterialPageRoute(builder: rutas[ruta]!, settings: RouteSettings(name: ruta)),
      ],
    );
  }
}
