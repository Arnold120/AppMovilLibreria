<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
// ignore_for_file: file_names, use_build_context_synchronously

=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
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
              final confirmar = await showDialog(
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
                  Navigator.pop(context);
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                  context.router.push(const RouteInicioSesion());
=======
                  context.router.push(const PantallaInicioSesion());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                  context.router.push(const PantallaInicioSesion());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                  context.router.push(const PantallaInicioSesion());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a

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

          ExpansionTile(
            title: const Text('Productos', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF2c3e50),
            collapsedBackgroundColor: const Color(0xFF2c3e50),
            textColor: Colors.white,
            iconColor: Colors.white,
            collapsedTextColor: Colors.white,
            children: [
              ListTile(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                title: const Text('Listado', style: TextStyle(color: Color.fromARGB(255, 190, 190, 190))),
                onTap: () {
                  AutoRouter.of(context).push(const RouteProducto());
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
                },
                hoverColor: const Color(0xFF2c3e50),
                tileColor: Colors.white,
              ),
              ListTile(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                title: const Text('Agregar producto', style: TextStyle(color: Color.fromARGB(255, 190, 190, 190))),
=======
                title: const Text('Agregar producto', style: TextStyle(color: Colors.black)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Agregar producto', style: TextStyle(color: Colors.black)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Agregar producto', style: TextStyle(color: Colors.black)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
                onTap: () {
                },
                hoverColor: const Color(0xFF2c3e50),
                tileColor: Colors.white,
              ),
            ],
          ),

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
          // ExpansionTile(
          //   title: const Text('Categorías', style: TextStyle(color: Colors.white)),
          //   backgroundColor: const Color(0xFF2c3e50),
          //   collapsedBackgroundColor: const Color(0xFF2c3e50),
          //   textColor: Colors.white,
          //   iconColor: Colors.white,
          //   collapsedTextColor: Colors.white,
          //   children: [
          //     ListTile(
          //       title: const Text('Listado', style: TextStyle(color: Colors.black)),
          //       onTap: () {
          //         //AutoRouter.of(context).push(const RutaCategoriesPage());
          //       },
          //       hoverColor: const Color(0xFF2c3e50),
          //       tileColor: Colors.white,
          //     ),
          //     ListTile(
          //       title: const Text('Agregar categoría', style: TextStyle(color: Colors.black)),
          //       onTap: () {
          //         //AutoRouter.of(context).push(const RutaCategoriesPage());
          //       },
          //       hoverColor: const Color(0xFF2c3e50),
          //       tileColor: Colors.white,
          //     ),
          //   ],
          // ),

          // ListTile(
          //   title: const Text('Proveedores', style: TextStyle(color: Colors.white)),
          //   onTap: () {
          //     AutoRouter.of(context).push(const ProveedorPantalla());
          //   },
          //   hoverColor: const Color(0xFF2c3e50),
          // ),
          ExpansionTile(
            title: const Text('Proveedores', style: TextStyle(color: Colors.white)),
=======
          ExpansionTile(
            title: const Text('Categorías', style: TextStyle(color: Colors.white)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
          ExpansionTile(
            title: const Text('Categorías', style: TextStyle(color: Colors.white)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
          ExpansionTile(
            title: const Text('Categorías', style: TextStyle(color: Colors.white)),
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
            backgroundColor: const Color(0xFF2c3e50),
            collapsedBackgroundColor: const Color(0xFF2c3e50),
            textColor: Colors.white,
            iconColor: Colors.white,
            collapsedTextColor: Colors.white,
            children: [
              ListTile(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                title: const Text('Listado', style: TextStyle(color: Color.fromARGB(255, 190, 190, 190))),
                onTap: () {
                  AutoRouter.of(context).push(const RouteProveedor());
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Listado', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
                },
                hoverColor: const Color(0xFF2c3e50),
                tileColor: Colors.white,
              ),
              ListTile(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                title: const Text('Agregar proveedor', style: TextStyle(color: Color.fromARGB(255, 190, 190, 190))),
                onTap: () {
=======
                title: const Text('Agregar categoría', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Agregar categoría', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
                title: const Text('Agregar categoría', style: TextStyle(color: Colors.black)),
                onTap: () {
                  //AutoRouter.of(context).push(const RutaCategoriesPage());
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
                },
                hoverColor: const Color(0xFF2c3e50),
                tileColor: Colors.white,
              ),
            ],
          ),
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
          // ListTile(
          //   title: const Text('Clientes', style: TextStyle(color: Colors.white)),
          //   onTap: () {
          //   },
          //   hoverColor: const Color(0xFF2c3e50),
          // ),
          // ListTile(
          //   title: const Text('Marcas', style: TextStyle(color: Colors.white)),
          //   onTap: () {
          //     //AutoRouter.of(context).push(const e());
          //   },
          //   hoverColor: const Color(0xFF2c3e50),
          // ),
=======
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a

          ListTile(
            title: const Text('Proveedores', style: TextStyle(color: Colors.white)),
            onTap: () {
            },
            hoverColor: const Color(0xFF2c3e50),
          ),
          ListTile(
            title: const Text('Clientes', style: TextStyle(color: Colors.white)),
            onTap: () {
            },
            hoverColor: const Color(0xFF2c3e50),
          ),
          ListTile(
            title: const Text('Marcas', style: TextStyle(color: Colors.white)),
            onTap: () {
              //AutoRouter.of(context).push(const RutaBrandsPage());
            },
            hoverColor: const Color(0xFF2c3e50),
          ),
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
=======
>>>>>>> 59d6b5f641ef69c037a952d57e694c74cd42942a
        ],
      ),
    );
  }
}
