import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cliente_model.dart';
import 'autenticacion_servicio_login.dart';
import 'package:application_library/core/utils/environment.dart';

class ClienteService {
  final String _baseUrl = Environment.instance.apiBaseUrl;

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (AuthService.usuarioActual != null &&
        AuthService.usuarioActual!['token'] != null) {
      headers['Authorization'] = 'Bearer ${AuthService.usuarioActual!['token']}';
    }
    return headers;
  }

  Future<List<Cliente>> obtenerClientes() async {
    final url = Uri.parse('$_baseUrl/api/Cliente');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Cliente.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado - Token JWT expirado o inválido');
      } else {
        throw Exception('Error al obtener clientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Cliente> obtenerClientePorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Cliente/$id');
    try {
      final response = await http.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Cliente.fromJson(data);
      } else {
        throw Exception('Error al obtener cliente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> crearCliente(Cliente cliente) async {
    final url = Uri.parse('$_baseUrl/api/Cliente');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(cliente.toJson()),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> actualizarCliente(Cliente cliente) async {
    final url = Uri.parse('$_baseUrl/api/Cliente/${cliente.clienteId}');
    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(cliente.toJson()),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> eliminarCliente(int id) async {
    final url = Uri.parse('$_baseUrl/api/Cliente/$id');
    try {
      final response = await http.delete(url, headers: _getHeaders());
      if (response.statusCode == 204) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
