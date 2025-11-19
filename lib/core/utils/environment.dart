/// A singleton class to manage environment variable configurations
class Environment {
  Environment._(); // Private constructor to prevent instantiation
  static final Environment _instance = Environment._();
  static Environment get instance => _instance;
}
