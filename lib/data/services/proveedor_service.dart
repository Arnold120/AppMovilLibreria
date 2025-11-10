import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proveedor_model.dart';
import 'autenticacion_servicio_login.dart';

class ProveedorService {
  final String _baseUrl = 'https://testeoxd.azurewebsites.net';

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};

    if (AuthService.usuarioActual != null &&
        AuthService.usuarioActual!['token'] != null) {
      headers['Authorization'] =
          'Bearer ${AuthService.usuarioActual!['token']}';
    }

    return headers;
  }

  Future<List<Proveedor>> obtenerProveedores() async {
    final url = Uri.parse('$_baseUrl/api/Proveedor');

    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Proveedor.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token JWT expirado o inválido');
      } else {
        throw Exception('Error al obtener proveedores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Proveedor?> obtenerProveedorPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Proveedor/$id');

    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Proveedor.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token JWT expirado o inválido');
      } else {
        throw Exception('Error al obtener proveedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> crearProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/Proveedor');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(proveedor.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear proveedor: $e');
    }
  }

  Future<bool> actualizarProveedor(Proveedor proveedor) async {
    final url = Uri.parse('$_baseUrl/api/Proveedor/${proveedor.proveedorId}');

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(proveedor.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar proveedor: $e');
    }
  }

  Future<bool> eliminarProveedor(int id) async {
    final url = Uri.parse('$_baseUrl/api/Proveedor/$id');

    try {
      final response = await http.delete(url, headers: _getHeaders());

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al eliminar proveedor: $e');
    }
  }
}
