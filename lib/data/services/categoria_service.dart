import 'dart:convert';
import 'package:application_library/data/models/categoria.model.dart';
import 'package:http/http.dart' as http;
import 'autenticacion_servicio_login.dart';
import 'package:application_library/core/utils/environment.dart';

class CategoriaService {
  final String _baseUrl = Environment.instance.apiBaseUrl;

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (AuthService.usuarioActual != null &&
        AuthService.usuarioActual!['token'] != null) {
      headers['Authorization'] = 'Bearer ${AuthService.usuarioActual!['token']}';
    }
    return headers;
  }

  Future<List<Categoria>> obtenerCategorias() async {
    final url = Uri.parse('$_baseUrl/api/Categoria');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Categoria.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener categorias: ${response.statusCode}');
    }
  }
}