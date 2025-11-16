import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_library/data/models/venta_model.dart';
import 'package:application_library/data/services/autenticacion_servicio_login.dart';

class VentaService {
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

  Future<List<Venta>> obtenerVentas() async {
    final url = Uri.parse('$_baseUrl/api/Venta');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      return list.map((e) => Venta.fromJson(e as Map<String, dynamic>)).toList();
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token inválido/expirado');
    } else {
      throw Exception('Error al obtener ventas: ${resp.statusCode}');
    }
  }

  Future<bool> crearVenta(VentaRequest request) async {
    final url = Uri.parse('$_baseUrl/api/Venta');
    final resp = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(request.toJson()),
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }

  Future<Venta> obtenerVentaPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Venta/$id');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      return Venta.fromJson(map);
    } else if (resp.statusCode == 404) {
      throw Exception('Venta #$id no encontrada');
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token inválido/expirado');
    } else {
      throw Exception('Error al obtener venta: ${resp.statusCode}');
    }
  }

    Future<List<DetalleVenta>> obtenerDetallesVenta(int ventaId) async {
    final url = Uri.parse('$_baseUrl/api/Venta/$ventaId');
    final resp = await http.get(url, headers: _getHeaders());
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final List raw = (map['detallesVenta'] as List?) ?? <dynamic>[];
      return raw
          .map((e) => DetalleVenta.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <DetalleVenta>[];
  }
}