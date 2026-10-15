import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'configuracion/rutas.dart';
import 'configuracion/tema.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniBudget',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      // H2.2: calendarios y diálogos del sistema en español
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: Rutas.arranque,
      routes: Rutas.mapa,
    );
  }
}