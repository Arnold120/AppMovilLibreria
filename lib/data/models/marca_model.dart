class Marca {
  final int marcaId;
  final String nombreMarca;
  final bool activo;
  final DateTime fechaRegistro;

  Marca({
    required this.marcaId,
    required this.nombreMarca,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(
      marcaId: json['marca_ID'] ?? json['Marca_ID'] ?? 0,
      nombreMarca: json['nombreMarca'] ?? json['NombreMarca'] ?? '',
      activo: json['activo'] ?? json['Activo'] ?? true,
      fechaRegistro: DateTime.parse(
        (json['fechaRegistro'] ?? json['FechaRegistro']).toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marca_ID': marcaId,
      'nombreMarca': nombreMarca,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}
