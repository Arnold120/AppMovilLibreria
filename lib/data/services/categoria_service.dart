import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_model.dart';
import 'autenticacion_servicio_login.dart';

class CategoriaService {
  final String _baseUrl = 'https://testeoxd.azurewebsites.net';

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final user = AuthService.usuarioActual;
    final token = (user != null) ? user['token'] : null;

    if (token != null && token.toString().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<Categoria>> obtenerCategorias() async {
    final url = Uri.parse('$_baseUrl/api/Categoria');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => Categoria.fromJson(e)).toList();
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener categorías: ${resp.statusCode}');
    }
  }

  Future<Categoria?> obtenerCategoriaPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Categoria/$id');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return Categoria.fromJson(data);
    } else if (resp.statusCode == 404) {
      return null; 
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener categoría: ${resp.statusCode}');
    }
  }

  Future<bool> crearCategoria(Categoria categoria) async {
    final url = Uri.parse('$_baseUrl/api/Categoria');
    final resp = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(categoria.toJson()),
    );
    return resp.statusCode == 201 || resp.statusCode == 200;
  }

  Future<bool> actualizarCategoria(Categoria categoria) async {
    final url = Uri.parse('$_baseUrl/api/Categoria/${categoria.categoriaId}');
    final resp = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(categoria.toJson()),
    );
    return resp.statusCode == 200 || resp.statusCode == 204;
  }

  Future<bool> eliminarCategoria(int id) async {
    final url = Uri.parse('$_baseUrl/api/Categoria/$id');
    final resp = await http.delete(url, headers: _getHeaders());
    return resp.statusCode == 200 || resp.statusCode == 204;
  }
}