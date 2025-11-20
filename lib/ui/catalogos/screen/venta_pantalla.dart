import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PantallaVenta extends StatelessWidget {
  static const String nombreRuta = 'venta';
  const PantallaVenta({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Venta de pantalla'));
  }
}