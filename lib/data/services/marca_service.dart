import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marca_model.dart';
import 'autenticacion_servicio_login.dart';

class MarcaService {
  final String _baseUrl = 'https://testeoxd.azurewebsites.net';

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (AuthService.usuarioActual != null &&
        AuthService.usuarioActual!['token'] != null) {
      headers['Authorization'] = 'Bearer ${AuthService.usuarioActual!['token']}';
    }
    return headers;
  }

  Future<List<Marca>> obtenerMarcas() async {
    final url = Uri.parse('$_baseUrl/api/Marca');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Marca.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener marcas: ${response.statusCode}');
    }
  }

  Future<Marca?> obtenerMarcaPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Marca/$id');
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      return Marca.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<bool> crearMarca(Marca marca) async {
    final url = Uri.parse('$_baseUrl/api/Marca');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(marca.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

}
