import 'package:flutter/material.dart';
import 'package:application_library/data/models/usuario_model.dart';
import 'package:application_library/data/models/rol_model.dart';
import 'package:application_library/data/models/usuario_rol_model.dart';
import 'package:application_library/data/services/usuario_service.dart';

class PerfilController with ChangeNotifier {
  final UsuarioService _service = UsuarioService();
  
  bool _loading = true;
  bool _refreshing = false;
  String _searchQuery = '';
  String _filterRol = 'Todos';
  bool _soloEnLinea = false;

  List<Usuario> _usuarios = [];
  List<Rol> _roles = [];
  List<UsuarioRol> _usuarioRoles = [];
  final Map<int, bool> _estadosEnLinea = {};
  final Map<int, bool> _sesionesActivas = {};

  bool get loading => _loading;
  bool get refreshing => _refreshing;
  String get searchQuery => _searchQuery;
  String get filterRol => _filterRol;
  bool get soloEnLinea => _soloEnLinea;
  List<Usuario> get usuarios => _usuarios;
  List<Rol> get roles => _roles;
  List<UsuarioRol> get usuarioRoles => _usuarioRoles;
  List<Usuario> get usuariosFiltrados => _getUsuariosFiltrados();

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  set filterRol(String value) {
    _filterRol = value;
    notifyListeners();
  }

  set soloEnLinea(bool value) {
    _soloEnLinea = value;
    notifyListeners();
  }

  Future<void> loadData() async {
    _setLoading(true);
    try {
      final results = await Future.wait([
        _service.obtenerUsuarios(),
        _service.obtenerRoles(),
        _service.obtenerUsuarioRoles(),
        _service.obtenerEstadosEnLinea(),
      ]);

      final usuarios = results[0] as List<Usuario>;
      final roles = results[1] as List<Rol>;
      final usuarioRoles = results[2] as List<UsuarioRol>;
      final estados = results[3];

      _processEstadosEnLinea(estados);

      _usuarios = usuarios;
      _roles = roles;
      _usuarioRoles = usuarioRoles;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      throw Exception('Error cargando datos: $e');
    }
  }

  Future<void> updateEstadosEnLinea() async {
    if (_refreshing) return;
    
    _setRefreshing(true);
    try {
      final estados = await _service.obtenerEstadosEnLinea();
      _processEstadosEnLinea(estados);
      _setRefreshing(false);
    } catch (e) {
      _setRefreshing(false);
    }
  }

  void startPeriodicUpdates() {
    Future.delayed(const Duration(seconds: 30), () {
      updateEstadosEnLinea();
      startPeriodicUpdates();
    });
  }

  void _processEstadosEnLinea(List<dynamic> estados) {
    _estadosEnLinea.clear();
    _sesionesActivas.clear();
    
    for (var estado in estados) {
      try {
        final usuarioId = estado['usuarioId'];
        final enSesion = estado['enSesion'] == true;
        final estaEnLinea = estado['estaEnLinea'] == true;
        
        _sesionesActivas[usuarioId] = enSesion;
        _estadosEnLinea[usuarioId] = estaEnLinea;
      } catch (e) {
        rethrow;
      }
    }
    notifyListeners();
  }

  List<Usuario> _getUsuariosFiltrados() {
    return _usuarios.where((usuario) {
      final rol = getRolUsuario(usuario.usuarioId);
      final enLinea = estaEnLinea(usuario.usuarioId);
      
      if (_searchQuery.isNotEmpty && 
          !usuario.nombreUsuario.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      
      if (_filterRol != 'Todos' && rol?.nombreRol != _filterRol) {
        return false;
      }
      
      if (_soloEnLinea && !enLinea) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Rol? getRolUsuario(int userId) {
    try {
      final rel = _usuarioRoles.firstWhere(
        (r) => r.usuarioId == userId,
        orElse: () => UsuarioRol(
          usuarioRolId: 0,
          usuarioId: 0,
          rolId: 0,
          fechaAsignacion: DateTime.now(),
        ),
      );

      return _roles.firstWhere(
        (r) => r.rolId == rel.rolId,
        orElse: () => Rol(rolId: 0, nombreRol: 'Sin rol', descripcion: ''),
      );
    } catch (e) {
      return Rol(rolId: 0, nombreRol: 'Sin rol', descripcion: '');
    }
  }

  bool estaEnLinea(int usuarioId) {
    return _estadosEnLinea[usuarioId] ?? false;
  }

  bool tieneSesionActiva(int usuarioId) {
    return _sesionesActivas[usuarioId] ?? false;
  }

  String formatearTiempo(int usuarioId) {
    try {
      final usuario = _usuarios.firstWhere((u) => u.usuarioId == usuarioId);
      if (usuario.ultimaActividad == null) return 'Nunca activo';
      
      final diferencia = DateTime.now().difference(usuario.ultimaActividad!);
      final tieneSesion = tieneSesionActiva(usuarioId);
      final enLinea = estaEnLinea(usuarioId);
      
      if (enLinea) {
        if (diferencia.inSeconds < 60) return 'En línea ahora';
        if (diferencia.inMinutes < 1) return 'Hace ${diferencia.inSeconds} seg';
        if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
        return 'Hace ${diferencia.inHours} h';
      } else if (tieneSesion) {
        if (diferencia.inMinutes < 60) return 'Inactivo ${diferencia.inMinutes} min';
        if (diferencia.inHours < 24) return 'Inactivo ${diferencia.inHours} h';
        return 'Inactivo ${diferencia.inDays} días';
      } else {
        if (diferencia.inMinutes < 60) return 'Visto hace ${diferencia.inMinutes} min';
        if (diferencia.inHours < 24) return 'Visto hace ${diferencia.inHours} h';
        return 'Visto hace ${(diferencia.inDays / 30).round()} meses';
      }
    } catch (e) {
      return 'Sin información';
    }
  }

  Color getColorEstado(int usuarioId) {
    final tieneSesion = tieneSesionActiva(usuarioId);
    final enLinea = estaEnLinea(usuarioId);
    
    if (enLinea) {
      return Colors.green;
    } else if (tieneSesion) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  String getTextoEstado(int usuarioId) {
    final tieneSesion = tieneSesionActiva(usuarioId);
    final enLinea = estaEnLinea(usuarioId);
    
    if (enLinea) {
      return 'En línea';
    } else if (tieneSesion) {
      return 'Inactivo';
    } else {
      return 'Desconectado';
    }
  }

  Map<String, int> getEstadisticas() {
    final usuariosFiltrados = _getUsuariosFiltrados();
    final total = usuariosFiltrados.length;
    final enLinea = usuariosFiltrados.where((u) => estaEnLinea(u.usuarioId)).length;
    final sesionesActivas = usuariosFiltrados.where((u) => tieneSesionActiva(u.usuarioId)).length;
    
    return {
      'total': total,
      'enLinea': enLinea,
      'sesionesActivas': sesionesActivas,
    };
  }

  Future<bool> cambiarRolUsuario(int usuarioId, int rolId) async {
    try {
      final success = await _service.asignarRol(usuarioId, rolId);
      if (success) {
        await loadData();
      }
      return success;
    } catch (e) {
      throw Exception('Error cambiando rol: $e');
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setRefreshing(bool value) {
    _refreshing = value;
    notifyListeners();
  }
}