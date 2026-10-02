// Mismas reglas y mensajes que backend/src/flujos/movimientos/validaciones.js

const String mensajeConceptoVacio = 'Escribí el concepto';
const String mensajeConceptoLargo = 'El concepto debe tener entre 2 y 40 letras';

String? validarConcepto(String valor) {
  final texto = valor.trim();
  if (texto.isEmpty) return mensajeConceptoVacio;
  if (texto.length < 2 || texto.length > 40) return mensajeConceptoLargo;
  return null;
}

// Acepta coma o punto: "25,50" y "25.50" valen lo mismo
String? validarMonto(String valor) {
  final texto = valor.trim().replaceAll(',', '.');
  if (texto.isEmpty) return 'Escribí el monto';
  final numero = double.tryParse(texto);
  if (numero == null || numero <= 0) return 'El monto debe ser un número mayor a 0';
  if (!RegExp(r'^\d*(\.\d{0,2})?$').hasMatch(texto)) return 'Usá como máximo 2 decimales';
  if (numero > 100000) return 'El monto no puede pasar de Bs 100000';
  return null;
}

double leerMonto(String valor) {
  return double.parse(valor.trim().replaceAll(',', '.'));
}
