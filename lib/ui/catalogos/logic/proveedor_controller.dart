import 'package:flutter/material.dart';
import 'package:application_library/data/models/proveedor_model.dart';
import 'package:application_library/data/services/proveedor_service.dart';

class ProveedorController with ChangeNotifier {
  final ProveedorService _proveedorService = ProveedorService();

  List<Proveedor> _proveedores = [];
  List<Proveedor> _proveedoresFiltrados = [];
  String _busqueda = '';
  bool _cargando = false;

  List<Proveedor> get proveedoresFiltrados => _proveedoresFiltrados;
  bool get cargando => _cargando;

  Future<void> cargarProveedores() async {
    _cargando = true;
    notifyListeners();

    try {
      _proveedores = await _proveedorService.obtenerProveedores();
      _proveedoresFiltrados = List.from(_proveedores);
    } catch (e) {
      _proveedores = [];
      _proveedoresFiltrados = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void filtrar(String query) {
    _busqueda = query.toLowerCase();
    _proveedoresFiltrados = _proveedores
        .where((p) =>
            p.nombreEmpresa.toLowerCase().contains(_busqueda) ||
            p.email.toLowerCase().contains(_busqueda) ||
            p.telefono.toLowerCase().contains(_busqueda))
        .toList();
    notifyListeners();
  }
}
