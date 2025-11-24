class Cliente {
  final int clienteId;
  final String nombre;
  final String apellido;
  final String direccion;
  final String telefono;
  final String email;
  final bool activo;
  final DateTime fechaRegistro;

  Cliente({
    required this.clienteId,
    required this.nombre,
    required this.apellido,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      clienteId: json['cliente_ID'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      activo: json['activo'] ?? false,
      fechaRegistro: DateTime.tryParse(json['fechaRegistro'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente_ID': clienteId,
      'nombre': nombre,
      'apellido': apellido,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}
