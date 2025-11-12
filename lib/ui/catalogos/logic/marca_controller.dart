// lib/ui/catalogos/logic/marca_controller.dart
import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/data/services/marca_service.dart';

class MarcaController {
  final MarcaService _marcaService = MarcaService();

  List<Marca> marcas = [];
  List<Marca> marcasFiltradas = [];

  bool cargando = false;
  bool operando = false;
  String? error;

  Future<List<Marca>> cargarMarcas() async {
    cargando = true;
    error = null;
    try {
      marcas = await _marcaService.obtenerMarcas();
      marcasFiltradas = List.from(marcas);
    } catch (e) {
      marcas = [];
      marcasFiltradas = [];
      error = e.toString();
      rethrow;
    } finally {
      cargando = false;
    }
    return marcas;
  }

  Future<List<Marca>> refrescar() async {
    return await cargarMarcas();
  }

  void filtrarMarcas(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      marcasFiltradas = List.from(marcas);
      return;
    }
    if (marcas.isEmpty) {
      marcasFiltradas = [];
      return;
    }
    marcasFiltradas = marcas.where((m) => m.nombreMarca.toLowerCase().contains(q)).toList();
  }

  Future<bool> crearMarca(Marca m) async {
    operando = true;
    try {
      final ok = await _marcaService.crearMarca(m);
      if (ok) await refrescar();
      return ok;
    } catch (e) {
      rethrow;
    } finally {
      operando = false;
    }
  }

  Future<bool> actualizarMarca(Marca m) async {
    operando = true;
    try {
      final ok = await _marcaService.actualizarMarca(m);
      if (ok) await refrescar();
      return ok;
    } catch (e) {
      rethrow;
    } finally {
      operando = false;
    }
  }

  Future<bool> eliminarMarca(int id) async {
    operando = true;
    try {
      final ok = await _marcaService.eliminarMarca(id);
      if (ok) await refrescar();
      return ok;
    } catch (e) {
      rethrow;
    } finally {
      operando = false;
    }
  }
}
