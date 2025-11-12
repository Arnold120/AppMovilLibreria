// lib/data/models/marca_model.dart
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
    // normalizar keys comunes
    final rawId = json['marca_ID'] ?? json['Marca_ID'] ?? json['id'] ?? 0;
    final nombre = (json['nombreMarca'] ?? json['NombreMarca'] ?? json['nombre'] ?? '').toString();
    final activoRaw = json['activo'] ?? json['Activo'] ?? json['isActive'] ?? true;
    final activo = (activoRaw is bool)
        ? activoRaw
        : (activoRaw.toString() == '1' || activoRaw.toString().toLowerCase() == 'true');

    DateTime fecha = DateTime.now();
    final fr = json['fechaRegistro'] ?? json['FechaRegistro'] ?? json['fecha'] ?? json['createdAt'];
    if (fr != null) {
      fecha = DateTime.tryParse(fr.toString()) ?? DateTime.now();
    }

    final id = (rawId is int) ? rawId : int.tryParse(rawId.toString()) ?? 0;

    return Marca(
      marcaId: id,
      nombreMarca: nombre,
      activo: activo,
      fechaRegistro: fecha,
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
