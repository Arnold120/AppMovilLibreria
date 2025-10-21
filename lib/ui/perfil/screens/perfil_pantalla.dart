import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PerfilPantalla extends StatelessWidget {
  static const String routeName = 'perfil';
  const PerfilPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Perfil de pantalla'));
  }
}