class Categoria {
  final int categoriaId;
  final String nombreCategoria;
  final bool activo;
  final DateTime fechaRegistro;

  Categoria({
    required this.categoriaId,
    required this.nombreCategoria,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      categoriaId: json['categoria_ID'] ?? 0,
      nombreCategoria: json['nombreCategoria'] ?? '',
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria_ID': categoriaId,
      'nombreCategoria': nombreCategoria,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}