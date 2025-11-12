// lib/ui/catalogos/logic/marca_controller.dart
import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/data/services/marca_service.dart';

class MarcaController {
  final MarcaService _marcaService = MarcaService();

  List<Marca> marcas = [];
  List<Marca> marcasFiltradas = [];

  bool cargando = false;   // para la carga inicial
  bool operando = false;   // para operaciones CUD (crear/editar/eliminar)
  String? error;           // último error si lo querés mostrar

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
    // si no hay marcas cargadas, devolvemos vacío
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
      if (ok) {
        await refrescar();
      }
      return ok;
    } catch (e) {
      rethrow;
    } finally {
      operando = false;
    }
  }

  // agregar actualizar/eliminar si se requiere igual que crearMarca
}
