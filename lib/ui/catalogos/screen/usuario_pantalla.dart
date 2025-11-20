// ignore_for_file: use_build_context_synchronously


//Esta funcion aun esta en version beta y puede contener errores
//o no funcionar como se espera. Se recomienda compresion profe Danny :)

import 'package:application_library/ui/catalogos/logic/perfil_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:application_library/data/models/usuario_model.dart';
import 'package:application_library/data/models/rol_model.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';

const kIndigo = Color(0xFF0a1051);
const kIndigoLight = Color(0xFF1a237e);

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const InfoChip({super.key, 
    required this.icon,
    required this.label,
    required this.value, 
    required this.color
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Chip(
          label: Text(value, style: const TextStyle(fontSize: 11)),
          backgroundColor: color.withValues(alpha: 0.08),
          side: BorderSide(color: color, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: kIndigo),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorState({super.key, required this.message, required this.onRetry});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 14), 
              label: const Text('Reintentar', style: TextStyle(fontSize: 12)), 
              onPressed: onRetry
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class PantallaAdminUsuarios extends StatefulWidget {
  static const String nombreRuta = 'admin_usuarios';
  const PantallaAdminUsuarios({super.key});

  @override
  State<PantallaAdminUsuarios> createState() => _PantallaAdminUsuariosState();
}

class _PantallaAdminUsuariosState extends State<PantallaAdminUsuarios> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  final int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800)
    );

    final controller = context.read<PerfilController>();
    controller.loadData().then((_) {
      _controller.forward(from: 0);
      controller.startPeriodicUpdates();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //Mejorar la navegación entre pantallas en updates futuras igual para compras
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      switch (index) {
        case 0:
          context.router.replace(const RoutePrincipal());
          break;
        case 1:
          context.router.replace(const RouteVenta());
          break;
        case 2:
          context.router.replace(const RouteCompra());
          break;
        case 3:
          break;
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: kIndigo,
          secondary: kIndigoLight,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kIndigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kIndigo,
          foregroundColor: Colors.white,
          centerTitle: false
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Gestión de Usuarios'),
          leading: null,
          elevation: 0,
          actions: [
            Consumer<PerfilController>(
              builder: (context, controller, child) {
                if (controller.refreshing) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => controller.loadData(),
                  );
                }
              },
            ),
          ],
        ),
        body: Consumer<PerfilController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                _buildFiltros(controller),
                _buildEstadisticas(controller),
                Expanded(
                  child: controller.loading
                      ? _buildLoading()
                      : _buildListaUsuarios(controller),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: kIndigo,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontSize: 9),
            unselectedLabelStyle: const TextStyle(fontSize: 9),
            iconSize: 18,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.point_of_sale_rounded),
                label: 'Ventas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded),
                label: 'Compras',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros(PerfilController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), 
        blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: const Icon(Icons.search, color: kIndigo),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
                borderSide: const BorderSide(color: kIndigo)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kIndigo, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => controller.searchQuery = value,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: controller.filterRol,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kIndigo),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kIndigo, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    labelText: 'Filtrar por rol',
                    labelStyle: const TextStyle(color: kIndigo),
                  ),
                  items: ['Todos', ...controller.roles.map((r) => r.nombreRol).toSet()].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value, 
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => controller.filterRol = value!,
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Solo en línea'),
                selected: controller.soloEnLinea,
                onSelected: (value) => controller.soloEnLinea = value,
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green,
                labelStyle: TextStyle(
                  color: controller.soloEnLinea ? Colors.green : Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas(PerfilController controller) {
    final estadisticas = controller.getEstadisticas();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEstadisticaItem('Total', estadisticas['total'].toString(), Colors.blue),
          _buildEstadisticaItem('En línea', estadisticas['enLinea'].toString(), Colors.green),
          _buildEstadisticaItem('Con sesión', estadisticas['sesionesActivas'].toString(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Text(valor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 4),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50, 
            height: 50, 
            decoration: BoxDecoration(
              color: Colors.grey[300], 
              shape: BoxShape.circle
            )
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(width: 80, height: 12, color: Colors.grey[300]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaUsuarios(PerfilController controller) {
    final usuarios = controller.usuariosFiltrados;
    
    if (usuarios.isEmpty) {
      return _EmptyState(
        icon: Icons.people_outline,
        title: 'No hay usuarios',
        subtitle: controller.searchQuery.isEmpty 
            ? 'No se encontraron usuarios en el sistema'
            : 'No se encontraron usuarios que coincidan con la búsqueda',
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.loadData(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];
          final rol = _getRolUsuario(controller, usuario.usuarioId);
          final enLinea = controller.estaEnLinea(usuario.usuarioId);
          final tieneSesion = controller.tieneSesionActiva(usuario.usuarioId);

          return _buildUsuarioCard(controller, usuario, rol, enLinea, tieneSesion, index);
        },
      ),
    );
  }

  Rol? _getRolUsuario(PerfilController controller, int userId) {
    try {
      final usuarioRoles = controller.usuarios
            .expand((u) => controller.usuarioRoles)
          .firstWhere((r) => r.usuarioId == userId);
      
      return controller.roles.firstWhere(
        (r) => r.rolId == usuarioRoles.rolId,
        orElse: () => Rol(rolId: 0, nombreRol: 'Sin rol', descripcion: ''),
      );
    } catch (e) {
      return Rol(rolId: 0, nombreRol: 'Sin rol', descripcion: '');
    }
  }

  Widget _buildUsuarioCard(PerfilController controller, Usuario usuario, Rol? rol, bool enLinea, bool tieneSesion, int index) {
    final colorEstado = controller.getColorEstado(usuario.usuarioId);
    final textoEstado = controller.getTextoEstado(usuario.usuarioId);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: kIndigo.withValues(alpha: 0.1), width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Stack(
            children: [
              Container(
                width: 54, 
                height: 54,
                decoration: BoxDecoration(
                  color: colorEstado.withValues(alpha: 0.1), 
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.person, color: colorEstado, size: 28),
              ),
              if (enLinea || tieneSesion)
                Positioned(
                  right: 0, 
                  bottom: 0,
                  child: Container(
                    width: 16, 
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorEstado, 
                      shape: BoxShape.circle, 
                      border: Border.all(color: Colors.white, width: 2)
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  usuario.nombreUsuario, 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)
                )
              ),
              if (tieneSesion || enLinea)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    textoEstado, 
                    style: TextStyle(
                      color: colorEstado, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.workspaces, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    rol?.nombreRol ?? 'Sin rol', 
                    style: TextStyle(color: Colors.grey[600])
                  ),
                ]
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    controller.formatearTiempo(usuario.usuarioId), 
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)
                  ),
                ]
              ),
            ],
          ),
          trailing: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kIndigo.withValues(alpha: 0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(Icons.edit, color: kIndigo, size: 18),
            ),
            onPressed: () => _mostrarDialogoCambioRol(controller, usuario, rol),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoCambioRol(PerfilController controller, Usuario usuario, Rol? rolActual) async {
    Rol? seleccionado = rolActual;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Cambiar rol', style: TextStyle(color: kIndigo)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Usuario: ${usuario.nombreUsuario}', 
                style: const TextStyle(fontWeight: FontWeight.w500)
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Rol>(
                initialValue: seleccionado,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kIndigo),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kIndigo, width: 2),
                  ),
                  labelText: 'Selecciona un rol',
                  labelStyle: const TextStyle(color: kIndigo),
                ),
                items: controller.roles.map((r) => 
                  DropdownMenuItem(
                    value: r, 
                    child: Text(r.nombreRol)
                  )
                ).toList(),
                onChanged: (r) => seleccionado = r,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kIndigo, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () async {
                if (seleccionado != null) {
                  try {
                    final success = await controller.cambiarRolUsuario(
                      usuario.usuarioId, 
                      seleccionado!.rolId
                    );
                    Navigator.pop(context);
                    if (success && mounted) {
                      _showSuccessSnackbar('Rol actualizado a ${seleccionado?.nombreRol}');
                    } else if (mounted) {
                      _showErrorSnackbar('Error al actualizar rol');
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    if (mounted) {
                      _showErrorSnackbar('Error al actualizar rol: $e');
                    }
                  }
                }
              },
              child: const Text('Guardar cambios', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}