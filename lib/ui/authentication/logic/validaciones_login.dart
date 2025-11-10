import 'package:application_library/core/constants/regex.dart';

class ValidadorDeInicioSesion {
  static String? validarCorreo(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    if (!ExpresionRegular.email.hasMatch(valor)) {
      return 'Introduce un correo electrónico válido';
    }
    return null;
  }

  static String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (valor.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    if (!RegExp(r'[a-z]').hasMatch(valor)) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(valor)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }
}
