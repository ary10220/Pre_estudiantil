import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/boton_pildora.dart';
import '../configuracion/rutas.dart';

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Capa 1: curvas decorativas
          const Positioned.fill(child: FondoDecorativo()),

          // Capa 2: contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),
                  _logo(),
                  const SizedBox(height: 16),
                  const Text(
                    'TU DINERO, TUS METAS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colores.grisAzulado,
                      fontSize: 13,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Organiza tus ingresos, gastos\ny mantén el control de tu presupuesto\ncomo estudiante universitario.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colores.grisAzulado,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  BotonPildora(
                    texto: 'Iniciar sesión',
                    icono: Icons.person_outline,
                    alPresionar: () => Navigator.pushNamed(context, Rutas.login),
                  ),
                  const SizedBox(height: 16),
                  BotonPildora(
                    texto: 'Registrarse',
                    icono: Icons.person_add_alt_outlined,
                    esRelleno: false,
                    alPresionar: () => Navigator.pushNamed(context, Rutas.registro),
                  ),
                  const Spacer(flex: 2),
                  _enlaceOlvidaste(context),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logo: "Uni" en azul oscuro y "Budget" en verde
  Widget _logo() {
    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 54,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(text: 'Uni', style: TextStyle(color: Colores.azulOscuro)),
          TextSpan(text: 'Budget', style: TextStyle(color: Colores.verdeOscuro)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _enlaceOlvidaste(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushNamed(context, Rutas.recuperar),
      icon: const Icon(Icons.lock_outline, color: Colores.verdeOscuro),
      label: const Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(color: Colores.verdeOscuro, fontSize: 14),
      ),
    );
  }
}