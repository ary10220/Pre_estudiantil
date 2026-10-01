import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tema/colores.dart';
import '../tema/espaciado.dart';
import '../tema/tipografia.dart';

class CampoTexto extends StatefulWidget {
  final String etiqueta;
  final TextEditingController controlador;
  final String? error;
  final String? ayuda;
  final String? pista;
  final bool esContrasena;
  final TextInputType tipoTeclado;
  final TextInputAction accionTeclado;
  final int? largoMaximo;
  final ValueChanged<String>? alCambiar;

  const CampoTexto({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.error,
    this.ayuda,
    this.pista,
    this.esContrasena = false,
    this.tipoTeclado = TextInputType.text,
    this.accionTeclado = TextInputAction.next,
    this.largoMaximo,
    this.alCambiar,
  });

  @override
  State<CampoTexto> createState() => _CampoTextoState();
}

class _CampoTextoState extends State<CampoTexto> {
  bool ocultarTexto = true;

  OutlineInputBorder borde(Color color, double grosor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radioControl),
      borderSide: BorderSide(color: color, width: grosor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hayError = widget.error != null;
    final textoDebajo = widget.error ?? widget.ayuda;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.etiqueta, style: Tipografia.etiqueta),
        const SizedBox(height: espacio8),
        SizedBox(
          height: alturaControl,
          child: TextField(
            controller: widget.controlador,
            obscureText: widget.esContrasena && ocultarTexto,
            keyboardType: widget.tipoTeclado,
            textInputAction: widget.accionTeclado,
            onChanged: widget.alCambiar,
            textAlignVertical: TextAlignVertical.center,
            style: Tipografia.cuerpo,
            cursorColor: colorMarca,
            inputFormatters: widget.largoMaximo == null
                ? null
                : [LengthLimitingTextInputFormatter(widget.largoMaximo)],
            decoration: InputDecoration(
              hintText: widget.pista,
              hintStyle: Tipografia.cuerpo.copyWith(color: colorPlaceholder),
              filled: true,
              fillColor: colorSuperficie,
              contentPadding: const EdgeInsets.symmetric(horizontal: espacio16),
              enabledBorder: borde(hayError ? colorError : colorBorde, 1),
              focusedBorder: borde(hayError ? colorError : colorMarca, 2),
              suffixIcon: widget.esContrasena
                  ? IconButton(
                      icon: Icon(ocultarTexto ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      color: colorTextoSecundario,
                      tooltip: ocultarTexto ? 'Mostrar contraseña' : 'Ocultar contraseña',
                      onPressed: () => setState(() => ocultarTexto = !ocultarTexto),
                    )
                  : null,
            ),
          ),
        ),
        if (textoDebajo != null) ...[
          const SizedBox(height: espacio8),
          Text(textoDebajo, style: hayError ? Tipografia.error : Tipografia.ayuda),
        ],
      ],
    );
  }
}
