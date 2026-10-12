import 'package:flutter/material.dart';
import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/limite.dart';
import '../modelos/movimiento.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_limite.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/mensajes.dart';
import 'pantalla_nuevo_movimiento.dart';

class PantallaMovimientos extends StatefulWidget {
  const PantallaMovimientos({super.key});

  @override
  State<PantallaMovimientos> createState() => _PantallaMovimientosState();
}

class _PantallaMovimientosState extends State<PantallaMovimientos> {
  String? _nombre;
  List<Movimiento> _movimientos = [];
  bool _cargandoLista = true;
  ResumenLimite? _resumen;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  // Protección de la ruta: si no hay sesión válida, vuelve al login
  Future<void> _verificarSesion() async {
    String? nombre;
    try {
      nombre = await ServicioAcceso.obtenerNombreSesion();
    } on ErrorAcceso {
      nombre = null;
    }

    if (!mounted) return;
    if (nombre == null) {
      Navigator.pushReplacementNamed(context, Rutas.login);
      return;
    }
    setState(() => _nombre = nombre);
    await _cargarMovimientos();
  }

  void _volverAlLogin() {
    Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
  }

  // Recuperar: lee lo guardado y actualiza la lista y la tarjeta del límite
  Future<void> _cargarMovimientos() async {
    try {
      final lista = await ServicioMovimientos.listar();
      final resumen = await ServicioLimite.leer();
      if (!mounted) return;
      setState(() {
        _movimientos = lista;
        _resumen = resumen;
        _cargandoLista = false;
      });
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      setState(() => _cargandoLista = false);
      mostrarMensaje(context, e.mensaje, esError: true);
    }
  }

  Future<void> _abrirFormulario() async {
    final creado = await Navigator.pushNamed(context, Rutas.nuevoMovimiento);
    if (creado == true) await _cargarMovimientos();
  }

  Future<void> _abrirLimite() async {
    final guardado = await Navigator.pushNamed(context, Rutas.limite);
    if (guardado == true) await _cargarMovimientos();
  }

  // Editar: abre el mismo formulario con los datos del movimiento
  Future<void> _editar(Movimiento movimiento) async {
    final cambiado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaNuevoMovimiento(movimiento: movimiento),
      ),
    );
    if (cambiado == true) await _cargarMovimientos();
  }

  // Ventana de confirmación reutilizable
  Future<bool> _pedirConfirmacion({
    required String titulo,
    required String mensaje,
    required String textoConfirmar,
    bool esPeligro = false,
  }) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(titulo, style: const TextStyle(color: Colores.azulOscuro)),
        content: Text(
          mensaje,
          style: const TextStyle(color: Colores.grisAzulado, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: const Text('Cancelar', style: TextStyle(color: Colores.verdeOscuro)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            style: FilledButton.styleFrom(
              backgroundColor: esPeligro ? Colors.red.shade700 : Colores.verdeOscuro,
            ),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );
    // Si cierran el diálogo tocando fuera, el resultado es null: se trata como cancelar
    return confirmado ?? false;
  }

  Future<void> _marcarComoPagado(Movimiento movimiento) async {
    final confirmado = await _pedirConfirmacion(
      titulo: 'Marcar como pagado',
      mensaje: '¿Deseas marcar este movimiento como pagado? Esta acción no se puede deshacer.',
      textoConfirmar: 'Confirmar',
    );
    if (!confirmado || !mounted) return;

    try {
      await ServicioMovimientos.marcarComoPagado(movimiento);
      if (!mounted) return;
      mostrarMensaje(context, 'Marcado como pagado');
      await _cargarMovimientos();
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    } on StateError catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.message, esError: true);
    }
  }

  Future<void> _eliminar(Movimiento movimiento) async {
    final confirmado = await _pedirConfirmacion(
      titulo: 'Eliminar movimiento',
      mensaje: '¿Deseas eliminar "${movimiento.concepto}"? Esta acción no se puede deshacer.',
      textoConfirmar: 'Eliminar',
      esPeligro: true,
    );
    if (!confirmado || !mounted) return;

    try {
      await ServicioMovimientos.eliminar(movimiento);
      if (!mounted) return;
      mostrarMensaje(context, 'Movimiento eliminado');
      await _cargarMovimientos();
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    }
  }

  Future<void> _cerrarSesion() async {
    await ServicioAcceso.cerrarSesion();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Rutas.inicio, (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se verifica la sesión no se muestra contenido privado
    if (_nombre == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colores.verdeOscuro)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis movimientos'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
        actions: [
          IconButton(
            tooltip: 'Límite del mes',
            icon: const Icon(Icons.savings_outlined, color: Colores.verdeOscuro),
            onPressed: _abrirLimite,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colores.verdeOscuro),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        backgroundColor: Colores.verdeOscuro,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $_nombre',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colores.azulOscuro,
              ),
            ),
            const SizedBox(height: 16),
            // Sin límite definido no se muestra
            if (_resumen?.tieneLimite ?? false) ...[
              _tarjetaLimite(_resumen!),
              const SizedBox(height: 16),
            ],
            Expanded(child: _lista()),
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    if (_cargandoLista) {
      return const Center(
        child: CircularProgressIndicator(color: Colores.verdeOscuro),
      );
    }
    if (_movimientos.isEmpty) {
      return const Center(
        child: Text(
          'Aún no tienes movimientos.\nCrea el primero con el botón de abajo.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colores.grisAzulado, height: 1.5),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: _movimientos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _tarjeta(_movimientos[i]),
    );
  }

  Widget _tarjetaLimite(ResumenLimite r) {
    final color = r.enAviso ? Colores.aviso : Colores.verdeOscuro;
    final restante = r.restante!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: r.enAviso ? Colores.aviso : Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gastado ${formatearBs(r.gastado)} de ${formatearBs(r.limite!)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colores.azulOscuro,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: r.proporcion,
              minHeight: 8,
              color: color,
              backgroundColor: Colores.verdeClaro,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            restante >= 0
                ? 'Te quedan ${formatearBs(restante)}'
                : 'Te pasaste por ${formatearBs(-restante)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(Movimiento m) {
    final pagado = m.estado == EstadoMovimiento.pagado;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  m.concepto,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colores.azulOscuro,
                  ),
                ),
              ),
              Text(
                m.montoTexto,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colores.verdeOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(m.fechaTexto, style: const TextStyle(color: Colores.grisAzulado)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: pagado ? Colores.verdeClaro : const Color(0xFFFFE9C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pagado ? 'Pagado' : 'Pendiente',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: pagado ? Colores.verdeOscuro : const Color(0xFF8A5A00),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined, color: Colores.verdeOscuro),
                onPressed: () => _editar(m),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: () => _eliminar(m),
              ),
            ],
          ),
          // La acción de pagar solo existe mientras esté pendiente
          if (!pagado)
            TextButton(
              onPressed: () => _marcarComoPagado(m),
              child: const Text(
                'Marcar como pagado',
                style: TextStyle(color: Colores.verdeOscuro),
              ),
            ),
        ],
      ),
    );
  }
}