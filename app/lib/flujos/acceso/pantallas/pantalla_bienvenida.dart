import 'package:flutter/material.dart';
import '../../../comun/tema/colores.dart';
import '../../../comun/tema/espaciado.dart';
import '../../../comun/tema/tipografia.dart';
import '../../../comun/widgets/boton_principal.dart';
import '../../../comun/widgets/boton_secundario.dart';

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(margenLateral, espacio48, margenLateral, espacio24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: espacio48,
                  height: espacio48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorMarcaSuave,
                    borderRadius: BorderRadius.circular(radioControl),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: colorMarca),
                ),
              ),
              const SizedBox(height: espacio24),
              Text('Presupuesto Estudiantil', style: Tipografia.titulo),
              const SizedBox(height: espacio8),
              Text(
                'Anotá tus ingresos y gastos del mes y sabé cuánto te queda para llegar a fin de mes.',
                style: Tipografia.subtitulo,
              ),
              const Spacer(),
              BotonPrincipal(
                texto: 'Crear cuenta',
                textoCargando: 'Crear cuenta',
                alPresionar: () => Navigator.pushNamed(context, '/registro'),
              ),
              const SizedBox(height: espacio16),
              BotonSecundario(
                texto: 'Ya tengo cuenta',
                alPresionar: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
