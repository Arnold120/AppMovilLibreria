import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/data/services/producto_service.dart';

class ProductoController {
  final ProductoService _productoService = ProductoService();

  late List<Producto> productos;
  List<Producto> productosFiltrados = [];

  Future<List<Producto>> cargarProductos() async {
    productos = await _productoService.obtenerProductos();
    productosFiltrados = List.from(productos);
    return productos;
  }
  
  void filtrarProductos(String query) {
    if (query.isEmpty) {
      productosFiltrados = List.from(productos);
    } else {
      productosFiltrados = productos
          .where((p) =>
              p.nombreProducto.toLowerCase().contains(query.toLowerCase()) ||
              p.marca.toLowerCase().contains(query.toLowerCase()) ||
              p.categoria.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }
}
