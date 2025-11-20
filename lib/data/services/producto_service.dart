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
      final productos = data.map((json) => Producto.fromJson(json)).toList();
      productos.sort((a, b) => b.productoId.compareTo(a.productoId));
      
      return productos;
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener productos: ${response.statusCode}');
    }
  }

  Future<List<Producto>> obtenerProductosBasicos() async {
    final url = Uri.parse('$_baseUrl/api/Producto/GET-Producto');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final productos = data.map((json) => Producto.fromJson(json)).toList();
      productos.sort((a, b) => b.productoId.compareTo(a.productoId));
      
      return productos;
    } else if (response.statusCode == 401) {
      throw Exception('No autorizado - Token JWT expirado o inválido');
    } else {
      throw Exception('Error al obtener productos básicos: ${response.statusCode}');
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

  Future<int?> crearProducto(Producto producto) async {
    final url = Uri.parse('$_baseUrl/api/Producto');    
    final Map<String, dynamic> productoJson = {
      'producto_ID': producto.productoId,
      'marca_ID': producto.marcaId,
      'categoria_ID': producto.categoriaId,
      'codigo': producto.codigo,
      'nombreProducto': producto.nombreProducto,
      'unidadMedida': producto.unidadMedida,
      'capacidadUnidad': producto.capacidadUnidad,
      'cantidad': producto.cantidad,
      'activo': producto.activo,
      'fechaRegistro': producto.fechaRegistro.toIso8601String(),
      'marca': producto.marca,
      'categoria': producto.categoria,
      'precioVenta': producto.precioVenta,
      'costoCompra': producto.costoCompra,
      'margenGanancia': producto.margenGanancia,
      'porcentajeMargen': producto.porcentajeMargen,
      'estadoStock': producto.estadoStock,
    };

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(productoJson),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['producto'] != null) {
        final productoId = responseData['producto']['producto_ID'] ?? 
                          responseData['producto']['productoId'] ?? 0;
        if (productoId > 0) {
          return productoId;
        }
       }
      final productos = await obtenerProductosBasicos();
      if (productos.isNotEmpty) {
        final ultimoProducto = productos.first;
        return ultimoProducto.productoId;
      }
    }  
    return null;
  } 
}
