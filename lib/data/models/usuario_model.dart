class Usuario {
  final int usuarioId;
  final String nombreUsuario;
  final String? contrasena;
  final DateTime fechaRegistro;
  final DateTime? ultimaActividad;
  final bool enSesion;

  Usuario({
    required this.usuarioId,
    required this.nombreUsuario,
    this.contrasena,
    required this.fechaRegistro,
    this.ultimaActividad,
    required this.enSesion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      usuarioId: json['usuario_ID'] ?? json['Usuario_ID'] ?? 0,
      nombreUsuario: (json['nombreUsuario'] ?? json['NombreUsuario'] ?? 'Sin nombre').toString(),
      contrasena: json['contraseña']?.toString(),
      fechaRegistro: DateTime.tryParse(
              (json['fechaRegistro'] ?? json['FechaRegistro'] ?? '').toString()
          ) ?? DateTime.now(),
      ultimaActividad: DateTime.tryParse(
              (json['ultimaActividad'] ?? json['UltimaActividad'] ?? '').toString()
          ),
      enSesion: json['enSesion'] ?? json['EnSesion'] ?? false,
    );
  }
}