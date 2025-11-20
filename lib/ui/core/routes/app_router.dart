import 'package:application_library/ui/catalogos/screen/compra_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/venta_pantalla.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/ui/authentication/screens/pantalla_usuario.dart';
import 'package:application_library/ui/authentication/screens/pantalla_registro.dart';
import 'package:application_library/ui/core/layouts/diseno_pantalla_principal.dart';
import 'package:application_library/ui/panel/screens/panel_pantalla.dart';
import 'package:application_library/ui/perfil/screens/perfil_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/producto_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/proveedor_pantalla.dart';
import 'package:application_library/ui/catalogos/screen/usuario_pantalla.dart';

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
        AutoRoute(page: RouteAdminUsuarios.page, path: PantallaAdminUsuarios.nombreRuta),
        AutoRoute(page: RouteCompra.page, path: PantallaCompra.nombreRuta),
        AutoRoute(page: RouteVenta.page, path: PantallaVenta.nombreRuta),
      ],
    ),
  ];
}