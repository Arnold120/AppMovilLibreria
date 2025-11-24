class Rol {
  final int rolId;
  final String nombreRol;
  final String descripcion;

  Rol({
    required this.rolId,
    required this.nombreRol,
    required this.descripcion,
  });

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
        rolId: json['rol_ID'] ?? json['Rol_ID'] ?? 0,
        nombreRol: json['nombreRol'] ?? json['NombreRol'] ?? 'Sin rol',
        descripcion: json['descripcion'] ?? json['Descripcion'] ?? '',
      );
}
