import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/solicitud_usuario_login.dart';

class AuthService {
  static const String _baseUrl = 'https://testeoxd.azurewebsites.net';

  static Map<String, dynamic>? usuarioActual;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/Usuario/Autenticar');

    final body = UsuarioLoginRequest(
      nombreUsuario: email,
      contrasena: password,
    ).toJson();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        usuarioActual = data;

        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Error ${response.statusCode}: ${response.reasonPhrase}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Future<void> logout() async {
    usuarioActual = null;
  }
}
