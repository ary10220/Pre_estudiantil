const List<String> mesesCortos = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

// 1 oct 2026
String fechaCorta(DateTime fecha) {
  return '${fecha.day} ${mesesCortos[fecha.month - 1]} ${fecha.year}';
}

// Bs 25.00
String montoEnBs(double monto) {
  return 'Bs ${monto.toStringAsFixed(2)}';
}
