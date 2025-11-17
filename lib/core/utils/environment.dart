import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  Environment._(); 
  static final Environment _instance = Environment._();
  static Environment get instance => _instance;

  String get environment => String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  String get baseApiUrl => dotenv.env['BASE_API_URL'] ?? '';
  String get otherEnvironmentVariable => dotenv.env['OTHER_ENVIRONMENT_VARIABLE'] ?? '';
  String get pruebaVariable => dotenv.env['PRUEBA_VARIABLE'] ?? '';
  
  String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? '';
    if (url.isEmpty) {
      throw Exception('API_BASE_URL no está configurada en las variables de entorno');
    }
    return url;
  }
}