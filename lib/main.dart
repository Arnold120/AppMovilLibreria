import 'package:application_library/ui/core/routes/app_router.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
import 'package:application_library/ui/catalogos/logic/proveedor_controller.dart';
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a

void main() {
  runApp(AplicacionPrincipal());
}

class AplicacionPrincipal extends StatelessWidget {
<<<<<<< HEAD
  final AppRouter _enrutador = AppRouter();
=======
  final EnrutadorAplicacion _enrutador = EnrutadorAplicacion();
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
  AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProveedorController()),
      ],
      child: MaterialApp.router(
        routerConfig: _enrutador.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
=======
    return MaterialApp.router(routerConfig: _enrutador.config());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
  }
}
