class UsuarioRol {
  final int usuarioRolId;
  final int usuarioId;
  final int rolId;
  final DateTime fechaAsignacion;

  UsuarioRol({
    required this.usuarioRolId,
    required this.usuarioId,
    required this.rolId,
    required this.fechaAsignacion,
  });

  factory UsuarioRol.fromJson(Map<String, dynamic> json) => UsuarioRol(
        usuarioRolId: json['usuarioRol_ID'],
        usuarioId: json['usuario_ID'],
        rolId: json['rol_ID'],
        fechaAsignacion: DateTime.parse(json['fechaAsignacion']),
      );
}