class Proveedor {
  final int proveedorId;
  final String nombreEmpresa;
  final String direccion;
  final String telefono;
  final String email;
  final bool aceptaDevoluciones;
  final int tiempoDevolucion;
  final double porcentajeCobertura;

  Proveedor({
    required this.proveedorId,
    required this.nombreEmpresa,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.aceptaDevoluciones,
    required this.tiempoDevolucion,
    required this.porcentajeCobertura,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      proveedorId: json['proveedor_ID'] ?? 0,
      nombreEmpresa: json['nombreEmpresa'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      aceptaDevoluciones: json['aceptaDevoluciones'] == true,
      tiempoDevolucion: json['tiempoDevolucion'] ?? 0,
      porcentajeCobertura: (json['porcentajeCobertura'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proveedor_ID': proveedorId,
      'nombreEmpresa': nombreEmpresa,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'aceptaDevoluciones': aceptaDevoluciones,
      'tiempoDevolucion': tiempoDevolucion,
      'porcentajeCobertura': porcentajeCobertura,
    };
  }
}
