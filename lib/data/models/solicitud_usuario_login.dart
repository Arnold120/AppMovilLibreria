class UsuarioLoginRequest {
  final String nombreUsuario;
  final String contrasena;

  UsuarioLoginRequest({
    required this.nombreUsuario,
    required this.contrasena,
  });

  Map<String, dynamic> toJson() => {
        'nombreUsuario': nombreUsuario,
        'contraseña': contrasena,
      };
}
