import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'rutas.dart';
import 'comun/servicios/sesion.dart';
import 'comun/tema/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final haySesion = await Sesion.haySesion();
  runApp(MiApp(rutaInicial: haySesion ? '/inicio' : '/'));
}

// Se queda solo con la ruta (/inicio) y si no existe abre la bienvenida
MaterialPageRoute armarRuta(String direccion) {
  var nombre = Uri.parse(direccion).path;
  if (!rutas.containsKey(nombre)) nombre = '/';
  return MaterialPageRoute(builder: rutas[nombre]!, settings: RouteSettings(name: nombre));
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
      // Para que el calendario y los textos de Flutter salgan en español
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: rutaInicial,
      routes: rutas,
      // Sin esto, al arrancar en /inicio Flutter deja la bienvenida debajo
      onGenerateInitialRoutes: (ruta) => [armarRuta(ruta)],
      // Para direcciones como presupuesto://app/inicio
      onGenerateRoute: (ajustes) => armarRuta(ajustes.name ?? '/'),
    );
  }
}
