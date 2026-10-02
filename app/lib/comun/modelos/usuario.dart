class Usuario {
  final int id;
  final String nombre;
  final String correo;

  Usuario({required this.id, required this.nombre, required this.correo});

  factory Usuario.desdeJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
    );
  }

  Map<String, dynamic> aJson() {
    return {'id': id, 'nombre': nombre, 'correo': correo};
  }
}
