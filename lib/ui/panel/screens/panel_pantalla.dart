import 'package:application_library/data/services/producto_service.dart';
import 'package:application_library/data/services/venta_service.dart';
import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/data/models/venta_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class PantallaTablero extends StatefulWidget {
  static const String nombreRuta = 'tablero';
  const PantallaTablero({super.key});

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final ProductoService _productoService = ProductoService();
  final VentaService _ventaService = VentaService();

  List<Producto> _productos = [];
  List<Venta> _ventas = [];
  bool _loading = true;
  String _errorMessage = '';

  int _totalProductos = 0;
  int _ventasHoy = 0;
  int _stockBajo = 0;
  double _ingresosMensuales = 0.0;

  final List<PageRouteInfo> _routes = [
    const RoutePrincipal(),
    const RouteVenta(),
    const RouteCompra(),
    const RouteAdminUsuarios(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _cargarProductos(),
        _cargarVentas(),
        _cargarCompras(),
      ]);
      _calcularEstadisticas();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _cargarProductos() async {
    try {
      _productos = await _productoService.obtenerProductos();
    } catch (e) {
      throw Exception('Error cargando productos');
    }
  }

  Future<void> _cargarVentas() async {
    try {
      _ventas = await _ventaService.obtenerVentas();
    } catch (e) {
      throw Exception('Error cargando ventas');
    }
  }

  Future<void> _cargarCompras() async {
    try {
    } catch (e) {
      throw Exception('Error cargando compras');
    }
  }

  void _calcularEstadisticas() {
    _totalProductos = _productos.length;

    final hoy = DateTime.now();
    _ventasHoy = _ventas.where((venta) {
      return venta.fechaVenta.year == hoy.year &&
          venta.fechaVenta.month == hoy.month &&
          venta.fechaVenta.day == hoy.day;
    }).length;

    _stockBajo = _productos.where((producto) => producto.cantidad < 10).length;

    _ingresosMensuales = _ventas
        .where((venta) =>
            venta.fechaVenta.month == hoy.month &&
            venta.fechaVenta.year == hoy.year)
        .fold(0.0, (sum, venta) => sum + venta.total);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    AutoRouter.of(context).replace(_routes[index]);
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      _mostrarBusquedaTemporal(query);
    }
  }

  void _mostrarBusquedaTemporal(String query) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Búsqueda'),
        content: Text('Buscando: "$query"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 375;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  if (_errorMessage.isNotEmpty) _buildErrorWidget(),
                  _buildStatsGrid(isSmallPhone),
                  _buildLowStockSection(),
                  _buildRecentSalesSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0a1051), Color(0xFF16267d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '¿Qué necesitas hoy?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search_rounded, color: Colors.grey, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: _performSearch,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[600], size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red[800], fontSize: 11),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.red[600], size: 14),
            onPressed: _cargarDatos,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isSmallPhone) {
    if (_loading) {
      return _buildStatsShimmer(isSmallPhone);
    }

    return Container(
      margin: const EdgeInsets.all(10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            title: 'Productos',
            value: _totalProductos.toString(),
            icon: Icons.inventory_2_rounded,
            gradient: const [Color(0xFF2196F3), Color(0xFF21CBF3)],
          ),
          _buildStatCard(
            title: 'Ventas Hoy',
            value: _ventasHoy.toString(),
            icon: Icons.trending_up_rounded,
            gradient: const [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
          _buildStatCard(
            title: 'Stock Bajo',
            value: _stockBajo.toString(),
            icon: Icons.warning_rounded,
            gradient: const [Color(0xFFFF9800), Color(0xFFFFC107)],
          ),
          _buildStatCard(
            title: 'Ingresos',
            value: '\$${_ingresosMensuales.toStringAsFixed(0)}',
            icon: Icons.attach_money_rounded,
            gradient: const [Color(0xFF9C27B0), Color(0xFFE91E63)],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer(bool isSmallPhone) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.2,
        children: List.generate(4, (index) => _buildStatShimmer()),
      ),
    );
  }

  Widget _buildStatShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 10,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock Bajo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a237e),
                ),
              ),
              if (_stockBajo > 0)
                TextButton(
                  onPressed: () {
                    context.router.push(const RouteCompra());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Ver todo',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 70,
          child: _buildLowStockHorizontal(),
        ),
      ],
    );
  }

  Widget _buildLowStockHorizontal() {
    if (_loading) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 2,
        itemBuilder: (context, index) => _buildLowStockShimmer(),
      );
    }

    final productosStockBajo = _productos.where((p) => p.cantidad < 10).toList();

    if (productosStockBajo.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inventory_2_rounded,
        message: 'Stock óptimo',
        height: 70,
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: productosStockBajo.length,
      itemBuilder: (context, index) {
        final producto = productosStockBajo[index];
        return _buildLowStockItem(producto);
      },
    );
  }

  Widget _buildLowStockItem(Producto producto) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red, size: 16),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    producto.nombreProducto,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a237e),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${producto.cantidad} und',
                    style: TextStyle(
                      fontSize: 8,
                      color: producto.cantidad < 5 ? Colors.red : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 8,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ventas Recientes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a237e),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.router.push(const RouteVenta());
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildRecentSalesList(),
      ],
    );
  }

  Widget _buildRecentSalesList() {
    if (_loading) {
      return Column(
        children: List.generate(2, (index) => _buildSaleShimmer()),
      );
    }

    final ventasRecientes = _ventas.take(2).toList();

    if (ventasRecientes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.point_of_sale_rounded,
        message: 'No hay ventas recientes',
        height: 80,
      );
    }

    return Column(
      children: ventasRecientes.map((venta) => _buildSaleItem(venta)).toList(),
    );
  }

  Widget _buildSaleItem(Venta venta) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        minLeadingWidth: 0,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.shopping_bag_rounded, color: Colors.green, size: 16),
        ),
        title: Text(
          'Venta #${venta.ventaId}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${venta.cantidadTotal} productos',
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${venta.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 12,
              ),
            ),
            Text(
              _formatTime(venta.fechaVenta),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 8,
              ),
            ),
          ],
        ),
        onTap: () {
        },
      ),
    );
  }

  Widget _buildSaleShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          leading: CircleAvatar(backgroundColor: Colors.white, radius: 16),
          title: SizedBox(height: 12, child: ColoredBox(color: Colors.white)),
          subtitle: SizedBox(height: 10, child: ColoredBox(color: Colors.white)),
          trailing: SizedBox(
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10, child: ColoredBox(color: Colors.white)),
                SizedBox(height: 6, child: ColoredBox(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required double height,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey[400]),
          const SizedBox(height: 6),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildQuickActions(),
        );
      },
      backgroundColor: const Color(0xFF0a1051),
      foregroundColor: Colors.white,
      elevation: 3,
      child: const Icon(Icons.add_rounded, size: 20),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickActionItem(
              icon: Icons.add_circle_rounded,
              label: 'Nuevo Producto',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                context.router.push(const RouteProducto());
              },
            ),
            _buildQuickActionItem(
              icon: Icons.point_of_sale_rounded,
              label: 'Nueva Venta',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                context.router.push(const RouteVenta());
              },
            ),
            _buildQuickActionItem(
              icon: Icons.shopping_cart_rounded,
              label: 'Nueva Compra',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                context.router.push(const RouteCompra());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
        selectedItemColor: const Color(0xFF0a1051),
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
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}