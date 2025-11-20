import 'dart:convert';
import 'package:application_library/data/models/usuario_model.dart';
import 'package:http/http.dart' as http;
import 'package:application_library/data/models/rol_model.dart';
import 'package:application_library/data/models/usuario_rol_model.dart';

class UsuarioService {
  static const String _baseUrl = 'https://testeoxd.azurewebsites.net';
  final String? token;

  UsuarioService([this.token]);

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<bool> cerrarSesion() async {
    try {
      final url = Uri.parse('$_baseUrl/api/Usuario/CerrarSesion');
      final res = await http.post(
        url,
        headers: _headers,
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final url = Uri.parse('$_baseUrl/api/Usuario');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Usuario.fromJson(e)).toList();
      } else {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Rol>> obtenerRoles() async {
    try {
      final url = Uri.parse('$_baseUrl/api/Rol/ObtenerRoles');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Rol.fromJson(e)).toList();
      } else {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UsuarioRol>> obtenerUsuarioRoles() async {
    try {
      final url = Uri.parse('$_baseUrl/api/UsuarioRol');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => UsuarioRol.fromJson(e)).toList();
      } else {
        throw Exception('Error ${res.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> obtenerEstadosEnLinea() async {
    try {
      final url = Uri.parse('$_baseUrl/api/Usuario/estados-en-linea');
      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> reportarActividad() async {
    try {
      final url = Uri.parse('$_baseUrl/api/Usuario/reportar-actividad');
      final res = await http.post(url, headers: _headers);

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> asignarRol(int usuarioId, int rolId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/UsuarioRol/AsignarRol');
      final body = jsonEncode({
        'Usuario_ID': usuarioId,
        'Rol_ID': rolId
      });

      final res = await http.post(url, headers: _headers, body: body);
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}