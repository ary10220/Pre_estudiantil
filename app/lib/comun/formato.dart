const List<String> mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

// 1 oct 2026
String fechaCorta(DateTime fecha) {
  return '${fecha.day} ${mesesCortos[fecha.month - 1]} ${fecha.year}';
}

// 2026-10-01, como la guarda la base
String fechaParaApi(DateTime fecha) {
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year}-$mes-$dia';
}

// Bs 25.00
String montoEnBs(double monto) {
  return 'Bs ${monto.toStringAsFixed(2)}';
}
