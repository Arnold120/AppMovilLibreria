import 'package:auto_route/auto_route.dart';
import './app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|View,Route')
class EnrutadorAplicacion extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PantallaInicioSesion.page,
      path: '/inicio-sesion',
    ),
    AutoRoute(
      page: PantallaRegistro.page,
      path: '/registro',
    ),
    AutoRoute(
      page: PantallaPrincipal.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(
          page: PantallaTablero.page,
          path: 'tablero',
          initial: true,
        ),
        AutoRoute(
          page: PantallaPerfil.page,
          path: 'perfil',
        ),
      ],
    ),
  ];
}
