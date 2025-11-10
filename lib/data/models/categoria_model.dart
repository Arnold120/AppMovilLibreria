class Categoria {
  final int categoriaId;          
  final String nombreCategoria;
  final String descripcion;
  final bool activo;
  final DateTime fechaRegistro;

  Categoria({
    required this.categoriaId,
    required this.nombreCategoria,
    required this.descripcion,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
  DateTime parseFecha(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  return Categoria(
    categoriaId: json['categoria_ID'] ?? 0,
    nombreCategoria: json['nombreCategoria'] ?? '',
    descripcion: json['descripcion'] ?? '',
    activo: json['activo'] ?? true,
    fechaRegistro: parseFecha(json['fechaRegistro']),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'categoria_ID': categoriaId,
      'nombreCategoria': nombreCategoria,
      'descripcion': descripcion,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}