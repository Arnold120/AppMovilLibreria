// ignore_for_file: file_names, use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';
import 'package:application_library/data/services/autenticacion_servicio_login.dart';

@RoutePage()
class PantallaPrincipal extends StatelessWidget {
  static const String nombreRuta = '/principal';

  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a1051),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Menú Principal',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFe74c3c),
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );

              if (confirmar == true) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                await AuthService.logout();

                if (context.mounted) {
                  Navigator.pop(context); // cierra el loading
                  context.router.push(const RouteInicioSesion());
                }
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFe74c3c),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 20),
        ],
      ),
      drawer: const _SideBarMenu(),
      body: const AutoRouter(),
    );
  }
}

class _SideBarMenu extends StatelessWidget {
  const _SideBarMenu();

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioActual;
    final nombreUsuario = usuario?['nombreUsuario'] ?? 'Danny';

    return Drawer(
      backgroundColor: const Color(0xFF34495e),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF34495e)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/146139954?s=400&u=950e8fd8c9ade1fefdf35e598dece0bc9f101953&v=4',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nombreUsuario,
                  style: const TextStyle(
                    color: Color(0xFFbbdefb),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          // Marcas
          ListTile(
            title: const Text('Marcas', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); // cerrar Drawer
              context.router.push(const RouteMarca()); // ✅ usar RouteMarca
            },
            hoverColor: const Color(0xFF2c3e50),
          ),
        ],
      ),
    );
  }
}
