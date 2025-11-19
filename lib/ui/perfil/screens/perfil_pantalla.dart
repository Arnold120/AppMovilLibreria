import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
<<<<<<< HEAD
class PantallaPerfil extends StatelessWidget {
  static const String nombreRuta = 'perfil';
  const PantallaPerfil({super.key});
=======
class PerfilPantalla extends StatelessWidget {
  static const String routeName = 'perfil';
  const PerfilPantalla({super.key});
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil de pantalla'));
  }
}