import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PantallaRegistro extends StatelessWidget {
  static const String nombreRuta = '/registro';

  const PantallaRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Pantalla de Registro'),
      ),
    );
  }
}