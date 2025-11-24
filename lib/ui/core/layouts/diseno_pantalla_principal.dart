// ignore_for_file: use_build_context_synchronously

//algunas funciones aun estan en version beta y pueden contener errores
//o no funcionar como se espera. Se recomienda compresion profe Danny :)
import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';
import 'package:application_library/data/services/autenticacion_servicio_login.dart';
import 'package:application_library/data/services/usuario_service.dart';

@RoutePage()
class PantallaPrincipal extends StatefulWidget {
  static const String nombreRuta = '/principal';
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  Timer? _activityTimer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _startActivityReporting();
  }

  @override
  void dispose() {
    _activityTimer?.cancel();
    super.dispose();
  }

  void _startActivityReporting() {
    _reportarActividad();
    _activityTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _reportarActividad();
    });
  }

  Future<void> _reportarActividad() async {
    try {
      final usuarioService = UsuarioService(AuthService.token);
      await usuarioService.reportarActividad();
    } catch (e) {
      return;
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: const _SideBarMenu(),
      body: const AutoRouter(),
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: _buildQuickActions(),
),

    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: _buildAppBarGradient(),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: _openDrawer,
      ),
      title: _buildAppBarTitle(),
      elevation: 0,
      shadowColor: Colors.black26,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: _CerrarSesionButton(),
        ),
      ],
    );
  }

  Widget _buildAppBarGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0a1051), Color(0xFF16267d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return const Row(
      children: [
        Icon(Icons.dashboard_rounded, color: Colors.white70, size: 20),
        SizedBox(width: 8),
        Text(
          'Panel Principal',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return FloatingActionButton(
      onPressed: () {
        _showQuickActionsMenu(context);
      },
      backgroundColor: const Color(0xFF0a1051),
      foregroundColor: Colors.white,
      elevation: 30,
      child: const Icon(Icons.bolt_rounded),
      
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 40, left: 6, right: 6, top: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickActionItem(
                icon: Icons.add,
                label: 'Nuevo Producto',
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(const RouteProducto());
                },
              ),
              _buildQuickActionItem(
                icon: Icons.inventory_2,
                label: 'Ver Inventario',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildQuickActionItem(
                icon: Icons.point_of_sale,
                label: 'Nueva Venta',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0a1051).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF0a1051)),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1a237e),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}

class _CerrarSesionButton extends StatefulWidget {
  const _CerrarSesionButton();

  @override
  State<_CerrarSesionButton> createState() => _CerrarSesionButtonState();
}

class _CerrarSesionButtonState extends State<_CerrarSesionButton>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFe74c3c)),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _loading = true);
      _controller.repeat();

      try {
        final resultado = await AuthService.logout();
        
        if (context.mounted) {
          _controller.reset();
          setState(() => _loading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message']),
              backgroundColor: resultado['success'] ? Colors.green : Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          context.router.replace(const RouteInicioSesion());
        }
      } catch (e) {
        if (context.mounted) {
          _controller.reset();
          setState(() => _loading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.8)),
            ),
          )
        : IconButton(
            onPressed: _handleLogout,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFe74c3c).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            ),
            tooltip: 'Cerrar sesión',
          );
  }
}

class _SideBarMenu extends StatefulWidget {
  const _SideBarMenu();

  @override
  State<_SideBarMenu> createState() => _SideBarMenuState();
}

class _SideBarMenuState extends State<_SideBarMenu> {
  final List<bool> _expanded = [false, false, false, false];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioActual;
    final nombreUsuarioRaw = usuario?['nombreUsuario'] ?? 'Usuario Invitado';
    final nombreUsuario = nombreUsuarioRaw.split('@')[0];

    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      width: 280,
      child: Column(
        children: [
          _buildUserHeader(nombreUsuario),
          Expanded(
            child: _buildMenuList(),
          ),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(String nombreUsuario) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A155A), Color(0xFF22347D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                'https://avatars.githubusercontent.com/u/146139954?s=400&v=4',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    child: const Icon(Icons.person, color: Color(0xFF0A155A), size: 40),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nombreUsuario,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Administrador del Sistema',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildMenuTile(
          title: 'Inicio',
          icon: Icons.home_rounded,
          isSelected: _selectedIndex == 0,
          onTap: () {
            setState(() => _selectedIndex = 0);
            Navigator.pop(context);
            context.router.replace(const RouteTablero());
          },
        ),
        _buildExpandableMenu(
          index: 0,
          title: 'Catálogos',
          icon: Icons.dashboard_rounded,
          isExpanded: _expanded[0],
          children: [
            _buildSubMenuTile('Productos', Icons.shopping_bag_outlined, () {
              Navigator.pop(context);
              context.router.push(const RouteProducto());
            }),
            _buildSubMenuTile('Marcas', Icons.label_outlined, () {
              Navigator.pop(context);
              context.router.push(const RouteMarca());
            }),
            _buildSubMenuTile('Categorías', Icons.category_outlined, () {
              Navigator.pop(context);
              context.router.push(const RouteCategoria());
            }),
            _buildSubMenuTile('Proveedores', Icons.local_shipping_outlined, () {
              Navigator.pop(context);
              context.router.push(const RouteProveedor());
            }),
            _buildSubMenuTile('Clientes', Icons.people_outlined, () {
              Navigator.pop(context);
              context.router.push(const RouteCliente());
            }),
          ],
        ),
        _buildExpandableMenu(
          index: 1,
          title: 'Inventario',
          icon: Icons.inventory_2_rounded,
          isExpanded: _expanded[1],
          children: [
            _buildSubMenuTile('Ver existencias', Icons.visibility_outlined, () {}),
            _buildSubMenuTile('Agregar nuevo', Icons.add_box_outlined, () {}),
            _buildSubMenuTile('Actualizar stock', Icons.update_outlined, () {}),
          ],
        ),
        _buildExpandableMenu(
          index: 2,
          title: 'Ventas',
          icon: Icons.point_of_sale_rounded,
          isExpanded: _expanded[2],
          children: [
            _buildSubMenuTile('Registrar venta', Icons.shopping_cart_checkout, () {}),
            _buildSubMenuTile('Historial', Icons.history_rounded, () {}),
            _buildSubMenuTile('Reportes', Icons.bar_chart_rounded, () {}),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuTile(
          title: 'Configuración',
          icon: Icons.settings_rounded,
          isSelected: false,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildExpandableMenu({
    required int index,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        key: PageStorageKey<String>('menu_$index'),
        initiallyExpanded: isExpanded,
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white70,
        childrenPadding: const EdgeInsets.only(left: 8),
        children: children,
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded[index] = expanded;
          });
        },
      ),
    );
  }

  Widget _buildSubMenuTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        visualDensity: const VisualDensity(vertical: -3),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Text(
            'Versión 1.0.0',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}