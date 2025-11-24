import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_library/data/models/compra_model.dart';
import 'package:application_library/data/services/autenticacion_servicio_login.dart';
import 'package:application_library/core/utils/environment.dart';

class CompraService {
  final String _baseUrl = Environment.instance.apiBaseUrl;

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final user = AuthService.usuarioActual;
    final token = (user != null) ? user['token'] : null;
    if (token != null && token.toString().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<Compra>> obtenerCompras() async {
    final url = Uri.parse('$_baseUrl/api/Compra');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      return list.map((e) => Compra.fromJson(e as Map<String, dynamic>)).toList();
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token inválido/expirado');
    } else {
      throw Exception('Error al obtener compras: ${resp.statusCode}');
    }
  }

  Future<Compra?> crearCompra(Map<String, dynamic> compraData) async {
    final url = Uri.parse('$_baseUrl/api/Compra');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(compraData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);

      if (responseData['detallesCompra'] != null) {
        for (var detalle in responseData['detallesCompra']) {
          if (detalle['precioUnitario'] == 0) {
            final itemIndex = responseData['detallesCompra'].indexOf(detalle);
            if (itemIndex < compraData['detallesCompra'].length) {
              detalle['precioUnitario'] =
                  compraData['detallesCompra'][itemIndex]['precioUnitario'];
            }
          }
        }
      }

      return Compra.fromJson(responseData);
    }
    return null;
  }
  
  Future<Compra> obtenerCompraPorId(int id) async {
    final url = Uri.parse('$_baseUrl/api/Compra/$id');
    final resp = await http.get(url, headers: _getHeaders());

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      return Compra.fromJson(map);
    } else if (resp.statusCode == 404) {
      throw Exception('Compra #$id no encontrada');
    } else if (resp.statusCode == 401) {
      throw Exception('No autorizado - Token inválido/expirado');
    } else {
      throw Exception('Error al obtener compra: ${resp.statusCode}');
    }
  }

  Future<List<DetalleCompra>> obtenerDetallesCompra(int compraId) async {
    final url = Uri.parse('$_baseUrl/api/Compra/$compraId');
    final resp = await http.get(url, headers: _getHeaders());
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      final List raw = (map['detallesCompra'] as List?) ?? <dynamic>[];
      return raw
          .map((e) => DetalleCompra.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <DetalleCompra>[];
  }
}
