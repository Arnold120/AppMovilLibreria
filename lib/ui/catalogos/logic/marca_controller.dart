import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/data/services/marca_service.dart';

class MarcaController {
  final MarcaService _marcaService = MarcaService();

  late List<Marca> marcas;
  List<Marca> marcasFiltradas = [];

  Future<List<Marca>> cargarMarcas() async {
    marcas = await _marcaService.obtenerMarcas();
    marcasFiltradas = List.from(marcas);
    return marcas;
  }

  void filtrarMarcas(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      marcasFiltradas = List.from(marcas);
    } else {
      marcasFiltradas = marcas.where((m) =>
        m.nombreMarca.toLowerCase().contains(q)
      ).toList();
    }
  }
}
