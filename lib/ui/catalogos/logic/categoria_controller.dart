import 'package:flutter/foundation.dart';
import 'package:application_library/data/models/categoria_model.dart';
import 'package:application_library/data/services/categoria_service.dart';

class CategoriaController extends ChangeNotifier {
  final CategoriaService service;

  CategoriaController({CategoriaService? service})
      : service = service ?? CategoriaService();

  bool _loading = false;
  String? _error;
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;

  List<Categoria> _items = [];
  List<Categoria> _filtered = [];

  List<Categoria> get items => List.unmodifiable(_items);
  List<Categoria> get filtered => List.unmodifiable(_filtered);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await service.obtenerCategorias();
      _items = data;
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void filter(String q) {
    _query = q;
    _applyFilter();
    notifyListeners();
  }
 
Future<bool> actualizar(Categoria categoria) async {
  final ok = await service.actualizarCategoria(categoria);
  if (ok) {
    await load();
  }
  return ok;
}

Future<bool> eliminar(int id) async {
  try {
    final ok = await service.eliminarCategoria(id);
    if (ok) {
      _items.removeWhere((c) => c.categoriaId == id);
      _applyFilter();
      notifyListeners();
    }
    return ok;
  } catch (e) {
    debugPrint('Error al eliminar categoría: $e');
    return false;
  }
}

  Future<bool> crear(Categoria categoria) async {
    final ok = await service.crearCategoria(categoria);
    if (ok) {
      await load();
    }
    return ok;
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    _filtered = q.isEmpty
        ? _items
        : _items.where((c) =>
            c.nombreCategoria.toLowerCase().contains(q) ||
            c.descripcion.toLowerCase().contains(q)).toList();
  }
}