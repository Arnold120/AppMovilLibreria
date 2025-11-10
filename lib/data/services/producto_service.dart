import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';
import 'autenticacion_servicio_login.dart';

class ProductoService {
  final String _baseUrl = 'https://testeoxd.azurewebsites.net';

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (AuthService.usuarioActual != null &&
        AuthService.usuarioActual!['token'] != null) {
      headers['Authorization'] = 'Bearer ${AuthService.usuarioActual!['token']}';
    }
    return headers;
  }

  Future<List<Producto>> obtenerProductos() async {
    final url = Uri.parse('$_baseUrl/api/Producto');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener productos: ${response.statusCode}');
    }
  }

  Future<Producto?> obtenerProductoPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Producto/$id');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Producto.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> crearProducto(Producto producto) async {
    final url = Uri.parse('$_baseUrl/api/Producto');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(producto.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
