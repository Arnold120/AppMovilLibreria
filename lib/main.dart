import 'package:flutter/material.dart';
import 'package:application_library/ui/core/routes/app_router.dart';

void main() {
  runApp(const AplicacionPrincipal());
}

class AplicacionPrincipal extends StatelessWidget {
  const AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final enrutador = AppRouter();
    return MaterialApp.router(
      routerConfig: enrutador.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
