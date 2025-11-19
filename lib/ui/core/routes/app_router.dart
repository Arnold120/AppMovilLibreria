import 'package:auto_route/auto_route.dart';
<<<<<<< HEAD
import 'package:application_library/ui/authentication/screens/pantalla_usuario.dart';
import 'package:application_library/ui/authentication/screens/pantalla_registro.dart';
import 'package:application_library/ui/core/layouts/diseño_pantalla_principal.dart';
import 'package:application_library/ui/panel/screens/panel_pantalla.dart';
import 'package:application_library/ui/perfil/screens/perfil_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/producto_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/proveedor_pantalla.dart';

import './app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: "Pantalla,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: RouteInicioSesion.page, path: PantallaInicioSesion.nombreRuta),
    AutoRoute(page: RouteRegistro.page, path: PantallaRegistro.nombreRuta),
    AutoRoute(
      page: RoutePrincipal.page,
      path: PantallaPrincipal.nombreRuta,
      initial: true,
      children: [
        AutoRoute(page: RouteTablero.page, path: PantallaTablero.nombreRuta, initial: true),
        AutoRoute(page: RoutePerfil.page, path: PantallaPerfil.nombreRuta),
        AutoRoute(page: RouteProducto.page, path: PantallaProducto.nombreRuta),
        AutoRoute(page: RouteProveedor.page, path: PantallaProveedor.nombreRuta),
      ],
    ),
  ];
}
=======
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
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
