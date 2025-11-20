// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/solicitud_usuario_login.dart';
import 'usuario_service.dart';

class AuthService {
  static const String _baseUrl = 'https://testeoxd.azurewebsites.net';

  static Map<String, dynamic>? usuarioActual;
  static String? _token;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString('token');
    final usuarioData = _prefs?.getString('usuarioActual');
    if (usuarioData != null) {
      usuarioActual = jsonDecode(usuarioData);
    }
  }

  static String? get token => _token;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/Usuario/Autenticar');

    final body = UsuarioLoginRequest(
      nombreUsuario: email,
      contrasena: password,
    ).toJson();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        usuarioActual = {
          'usuarioId': data['usuarioId'],
          'nombreUsuario': data['nombreUsuario'],
          'token': data['token'],
        };
        
        _token = data['token'];
        
        await _prefs?.setString('token', _token!);
        await _prefs?.setString('usuarioActual', jsonEncode(usuarioActual));
        
        _iniciarReporteActividad();
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error en la autenticación',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  static Timer? _activityTimer;

  static void _iniciarReporteActividad() {
    _activityTimer?.cancel();
    
    _activityTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
    });
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      _activityTimer?.cancel();
      
      if (_token != null) {
        final usuarioService = UsuarioService(_token);
        await usuarioService.cerrarSesion();
      }
      
      usuarioActual = null;
      _token = null;
      
      await _prefs?.remove('token');
      await _prefs?.remove('usuarioActual');
      
      return {
        'success': true,
        'message': 'Sesión cerrada correctamente',
      };
    } catch (e) {
      usuarioActual = null;
      _token = null;
      _activityTimer?.cancel();
      
      await _prefs?.remove('token');
      await _prefs?.remove('usuarioActual');
      
      return {
        'success': false,
        'message': 'Error al cerrar sesión: $e',
      };
    }
  }
}