import 'package:flutter/material.dart';
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
      initialRoute: Rutas.arranque,
      routes: Rutas.mapa,
    );
  }
}