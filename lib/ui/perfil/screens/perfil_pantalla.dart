import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PantallaPerfil extends StatelessWidget {
  static const String nombreRuta = 'perfil';
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil de pantalla'));
  }
}