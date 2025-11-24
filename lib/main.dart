import 'package:application_library/ui/catalogos/logic/perfil_controller.dart';
import 'package:application_library/ui/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_library/ui/catalogos/logic/proveedor_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(AplicacionPrincipal());
}

class AplicacionPrincipal extends StatelessWidget {
  final AppRouter _enrutador = AppRouter();
  AplicacionPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PerfilController()),
        ChangeNotifierProvider(create: (_) => ProveedorController()),
      ],
      child: MaterialApp.router(
        routerConfig: _enrutador.config(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
