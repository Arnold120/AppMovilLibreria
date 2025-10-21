import 'package:application_library/ui/core/routes/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(AplicacionPrincipal());
}

class AplicacionPrincipal extends StatelessWidget {
  final EnrutadorAplicacion _enrutador = EnrutadorAplicacion();
  AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _enrutador.config());
  }
}
