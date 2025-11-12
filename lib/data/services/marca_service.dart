// lib/data/services/marca_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marca_model.dart';
import 'autenticacion_servicio_login.dart';

class MarcaService {
  final String _baseUrl = 'https://testeoxd.azurewebsites.net';

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final usuario = AuthService.usuarioActual;
    if (usuario != null && usuario['token'] != null) {
      headers['Authorization'] = 'Bearer ${usuario['token']}';
    }
    return headers;
  }

  Future<List<Marca>> obtenerMarcas() async {
    final url = Uri.parse('$_baseUrl/api/Marca');
    try {
      final response = await http.get(url, headers: _getHeaders()).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((j) => Marca.fromJson(j)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado (401). Verifique token.');
      } else {
        throw Exception('Error al obtener marcas: ${response.statusCode} ${response.reasonPhrase}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al conectar con el servidor.');
    } on FormatException {
      throw Exception('Respuesta inválida desde el servidor.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Marca?> obtenerMarcaPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Marca/$id');
    try {
      final response = await http.get(url, headers: _getHeaders()).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return Marca.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener marca: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al obtener la marca.');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> crearMarca(Marca marca) async {
    final url = Uri.parse('$_baseUrl/api/Marca');
    try {
      final body = jsonEncode({
        'NombreMarca': marca.nombreMarca,
        'Activo': marca.activo,
        // normalmente el backend setea FechaRegistro; mandamos por si lo espera:
        'FechaRegistro': marca.fechaRegistro.toIso8601String(),
      });
      final response = await http.post(url, headers: _getHeaders(), body: body).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // intentar obtener mensaje del servidor
        String msg = '';
        try {
          final j = jsonDecode(response.body);
          msg = j['message'] ?? j['error'] ?? '';
        } catch (_) {}
        throw Exception('No se pudo crear marca: ${response.statusCode} ${msg}');
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado al crear la marca.');
    } catch (e) {
      rethrow;
    }
  }

  // (Opcional) implementar actualizar/eliminar si tu API los soporta:
  // Future<bool> actualizarMarca(Marca marca) async { ... }
  // Future<bool> eliminarMarca(int id) async { ... }
}
