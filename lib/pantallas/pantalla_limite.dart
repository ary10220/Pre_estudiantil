import 'package:flutter/material.dart';

import '../configuracion/constantes.dart';
import '../configuracion/rutas.dart';
import '../modelos/limite.dart';
import '../servicios/servicio_acceso.dart';
import '../servicios/servicio_limite.dart';
import '../servicios/servicio_movimientos.dart';
import '../widgets/boton_pildora.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';
import '../modelos/presupuesto_categoria.dart';
import '../servicios/analitica.dart';

class PantallaLimite extends StatefulWidget {
  const PantallaLimite({super.key});

  @override
  State<PantallaLimite> createState() => _PantallaLimiteState();
}

class _PantallaLimiteState extends State<PantallaLimite> {
  final _limite = TextEditingController();
  String? _errorLimite;
  bool _cargando = false;
  ResumenLimite? _resumen;
  // Lo que devolvio el servidor al guardar, mientras exista se muestra la confirmacion
  ResumenLimite? _guardado;

  // tarea 5 presupuesto
  List<PresupuestoCategoria> _presupuestosCategorias = [];

  // tarea 7 mes navegable para ver el presupuesto por categoria
  late String _mesSeleccionado;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mesSeleccionado =
        '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}';
    _cargarLimite();
    // Analitica, usuario abre la gestion de limites
    AnaliticaServicio.track('limite_iniciado', {});
  }

  @override
  void dispose() {
    _limite.dispose();
    super.dispose();
  }

  void _volverAlLogin() {
    Navigator.pushNamedAndRemoveUntil(context, Rutas.login, (ruta) => false);
  }

  // Avanza o retrocede un mes y recarga los datos
  void _navegarMes(int delta) {
    final partes = _mesSeleccionado.split('-');
    var anio = int.parse(partes[0]);
    var mes = int.parse(partes[1]) + delta;
    if (mes < 1) {
      mes = 12;
      anio--;
    } else if (mes > 12) {
      mes = 1;
      anio++;
    }
    setState(() {
      _mesSeleccionado = '$anio-${mes.toString().padLeft(2, '0')}';
    });
    _cargarLimite();
  }

  // Al entrar se pide el limite a la base, asi se ve lo guardado aunque se cierre la app
  Future<void> _cargarLimite() async {
    try {
      final resumen = await ServicioLimite.leer();
      final categorias = await ServicioLimite.leerPorCategoria(
        _mesSeleccionado,
      );
      if (!mounted) return;
      setState(() {
        _resumen = resumen;
        _presupuestosCategorias = categorias;
        if (resumen.tieneLimite) {
          _limite.text = resumen.limite!.toStringAsFixed(2);
        }
      });
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e.mensaje, esError: true);
    }
  }

  Future<void> _editarPresupuesto(PresupuestoCategoria item) async {
    final controlador = TextEditingController(
      text: item.limite != null ? item.limite!.toStringAsFixed(2) : '',
    );

    final mesActual = _mesSeleccionado;

    final guardado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(item.icono, color: Colores.verdeOscuro, size: 22),
            const SizedBox(width: 10),
            Text(
              item.nombreLegible,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colores.azulOscuro,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controlador,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Presupuesto (Bs)',
            hintText: 'Ej.: 200',
            prefixText: 'Bs ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colores.verdeOscuro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              try {
                await ServicioLimite.guardarPorCategoria(
                  categoria: item.categoria,
                  montoTexto: controlador.text,
                  mes: mesActual,
                );
                // Analitica, guardado de presupuesto por categoria
                AnaliticaServicio.track('limite_guardado', {
                  'alcance': 'categoria',
                });
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  mostrarMensaje(ctx, e.toString(), esError: true);
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardado == true) {
      _cargarLimite(); // Recargamos para actualizar las tarjetas y consumos
    }
  }

  Future<void> _guardar() async {
    setState(() => _errorLimite = validarMontoLimite(_limite.text));
    if (_errorLimite != null) return;

    setState(() => _cargando = true);
    try {
      final guardado = await ServicioLimite.guardar(_limite.text);
      if (!mounted) return;
      // Analitica, guardado de presupuesto general mensual
      AnaliticaServicio.track('limite_guardado', {'alcance': 'general'});
      // La pantalla no se cierra, la confirmacion queda junto al boton
      setState(() => _guardado = guardado);
    } on SesionExpirada {
      if (!mounted) return;
      _volverAlLogin();
    } on ErrorAcceso catch (e) {
      // El error del servidor va debajo del campo
      if (!mounted) return;
      setState(() => _errorLimite = e.mensaje);
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() => _errorLimite = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Confirmación de éxito junto al botón (clase 15, hallazgo 1)
  Widget _confirmacion(ResumenLimite r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colores.verdeClaro,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colores.verdeOscuro),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              textoConfirmacionLimite(r),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colores.verdeOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Las reglas del límite, antes de que la persona las descubra con un bloqueo (H10.1)
  Widget _comoFunciona() {
    const reglas = [
      'Si un gasto supera el límite, no se guarda.',
      'Solo cuentan los gastos; los ingresos no.',
      'Es el límite de este mes y no puede ser menor a lo que ya gastaste.',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colores.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colores.verdeOscuro),
              SizedBox(width: 8),
              Text(
                'Cómo funciona',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colores.azulOscuro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final regla in reglas)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• $regla',
                style: const TextStyle(color: Colores.grisAzulado, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  // Navegador de mes
  Widget _selectorMes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colores.azulOscuro),
          onPressed: () => _navegarMes(-1),
          tooltip: 'Mes anterior',
        ),
        Text(
          _etiquetaMes(_mesSeleccionado),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colores.azulOscuro,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colores.azulOscuro),
          onPressed: () => _navegarMes(1),
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }

  // Convierte "2026-10" a "Octubre 2026"
  String _etiquetaMes(String mesAnio) {
    final partes = mesAnio.split('-');
    if (partes.length < 2) return mesAnio;
    final anio = partes[0];
    final mes = int.tryParse(partes[1]) ?? 1;
    const nombres = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${nombres[mes]} $anio';
  }

  // Tarjeta de categoria con barra de progreso y colores semanticos
  Widget _tarjetaCategoria(PresupuestoCategoria item) {
    final texto = item.tieneLimite
        ? (item.excedido
              ? 'Excedido por ${formatearBs(-item.restante!)}'
              : item.enAviso
              ? 'Quedan ${formatearBs(item.restante!)} · Estas cerca del limite'
              : 'Quedan ${formatearBs(item.restante!)}')
        : 'Toca para definir un presupuesto';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _editarPresupuesto(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colores.verdeClaro),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila - icono + nombre + lapiz
              Row(
                children: [
                  Icon(item.icono, color: item.colorEstado, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.nombreLegible,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colores.azulOscuro,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colores.grisAzulado,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progresoBarra,
                  color: item.colorEstado,
                  backgroundColor: Colores.verdeClaro,
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 8),
              // Gastado y porcentaje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gastado ${formatearBs(item.gastado)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colores.grisAzulado,
                    ),
                  ),
                  if (item.tieneLimite)
                    Text(
                      '${item.porcentajeTexto} de ${formatearBs(item.limite!)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: item.colorEstado,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Estado textual
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  color: item.tieneLimite
                      ? item.colorEstado
                      : Colores.grisAzulado,
                  fontStyle: item.tieneLimite
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colores.azulOscuro,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Límite del mes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cuánto quieres gastar como máximo este mes.',
                style: TextStyle(fontSize: 16, color: Colores.grisAzulado),
              ),
              // El limite no puede quedar por debajo de esto
              if (_resumen != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Este mes ya gastaste ${formatearBs(_resumen!.gastado)}.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colores.grisAzulado,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _comoFunciona(),
              const SizedBox(height: 32),
              CampoTexto(
                controlador: _limite,
                etiqueta: 'Límite del mes (Bs)',
                icono: Icons.savings_outlined,
                pista: 'Ej.: 500',
                tipoTeclado: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                error: _errorLimite,
                // Si cambia el monto, se oculta la confirmación y vuelve "Guardar limite"
                alCambiar: (_) => setState(() {
                  _errorLimite = null;
                  _guardado = null;
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 58,
                child: _cargando
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colores.verdeOscuro,
                        ),
                      )
                    : _guardado != null
                    ? BotonPildora(
                        // H4.4: check a la izquierda y la flecha de la derecha
                        texto: 'Listo',
                        icono: Icons.check,
                        alPresionar: () => Navigator.pop(context, true),
                      )
                    : BotonPildora(
                        texto: 'Guardar límite',
                        icono: Icons.check,
                        alPresionar: _guardar,
                      ),
              ),
              if (_guardado != null) ...[
                const SizedBox(height: 16),
                _confirmacion(_guardado!),
              ],
              const SizedBox(height: 24),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Titulo de seccion
              const Text(
                'Presupuesto por categorías',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colores.azulOscuro,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Toca una categoría para definir o cambiar su presupuesto.',
                style: TextStyle(fontSize: 14, color: Colores.grisAzulado),
              ),
              const SizedBox(height: 12),

              // Selector de mes (tarea-7)
              _selectorMes(),
              const SizedBox(height: 12),

              // Tarjeta de cada categoria
              for (final item in _presupuestosCategorias)
                _tarjetaCategoria(item),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
