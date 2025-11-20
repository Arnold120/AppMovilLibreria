// ignore_for_file: use_build_context_synchronously

import 'package:application_library/data/models/categoria.model.dart';
import 'package:application_library/data/models/compra_model.dart';
import 'package:application_library/data/models/marca_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/catalogos/logic/compra_controller.dart';
import 'package:application_library/data/models/proveedor_model.dart';
import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';

const kGreen = Color(0xFF2E7D32);
const kGreenLight = Color(0xFF4CAF50);

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: kGreen),
        const SizedBox(width: 6),
        Icon(icon, color: kGreen, size: 16),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _AmountChip({required this.label, required this.value, this.bold = false});
  
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: \$${value.toStringAsFixed(2)}', 
          style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : null)),
      backgroundColor: kGreen.withValues(alpha: 0.05),
      side: const BorderSide(color: kGreen, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _BottomSummaryBarCompact extends StatelessWidget {
  final double subtotal;
  final double iva;
  final double total;
  final bool puedeConfirmar;
  final VoidCallback onConfirmar;
  
  const _BottomSummaryBarCompact({
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.puedeConfirmar,
    required this.onConfirmar,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _AmountChip(label: 'Sub', value: subtotal),
                    const SizedBox(width: 4),
                    _AmountChip(label: 'IVA', value: iva),
                    const SizedBox(width: 4),
                    _AmountChip(label: 'Total', value: total, bold: true),
                  ]),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: puedeConfirmar ? onConfirmar : null,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Confirmar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
      ),
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
            Icon(icon, size: 48, color: kGreen),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  
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

class _RowTotal extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _RowTotal(this.label, this.value, {this.bold = false});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final String label;

  const _DatePickerField({
    required this.selectedDate,
    required this.onDateChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: kGreen,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          onDateChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, color: kGreen),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

@RoutePage()
class PantallaCompra extends StatefulWidget {
  static const String nombreRuta = 'compras';
  const PantallaCompra({super.key});

  @override
  State<PantallaCompra> createState() => _PantallaCompraState();
}

class _PantallaCompraState extends State<PantallaCompra> with SingleTickerProviderStateMixin {
  late final CompraController controller;
  TabController? tabCtrl;
  bool _creandoCompra = false;
  final int _selectedIndex = 0;

  final TextEditingController _provText = TextEditingController();
  final TextEditingController _histSearchCtrl = TextEditingController();
  final TextEditingController _productoSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = CompraController()..load();
    controller.loadProveedores();
    controller.loadProductos();
    controller.loadMarcas();
    controller.loadCategorias();
  }

  @override
  void dispose() {
    tabCtrl?.dispose();
    controller.dispose();
    _provText.dispose();
    _histSearchCtrl.dispose();
    _productoSearchCtrl.dispose();
    super.dispose();
  }

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
          break;
        case 3:
          context.router.replace(const RouteAdminUsuarios());
          break;
      }
    }
  }

  void _startCrearCompra() {
    setState(() {
      _creandoCompra = true;
      tabCtrl?.dispose();
      tabCtrl = TabController(length: 3, vsync: this);
    });
  }

  void _mostrarDetallesCompra(BuildContext context, Compra compra) async {
    final detalles = await controller.loadDetalles(compra.compraId, force: true);
    final proveedorNombre = controller.getProveedorNombreById(compra.proveedorId);
  
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: kGreen, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Compra #${compra.compraId}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildInfoRow('Proveedor:', proveedorNombre),
              _buildInfoRow('Fecha:', _formatearFecha(compra.fechaRegistro)),
              _buildInfoRow('Usuario ID:', compra.usuarioId.toString()),
              
              const SizedBox(height: 16),
              const Text(
                'Resumen Financiero',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGreen),
              ),
              const SizedBox(height: 8),
              
              _buildTotalRow('Cantidad Total:', compra.cantidadTotal.toString(), isTotal: false),
              _buildTotalRow('SubTotal:', '\$${compra.subTotal.toStringAsFixed(2)}', isTotal: false),
              _buildTotalRow('IVA Total:', '\$${compra.ivaTotal.toStringAsFixed(2)}', isTotal: false),
              _buildTotalRow('Monto Total:', '\$${compra.montoTotal.toStringAsFixed(2)}', isTotal: false),
              _buildTotalRow('TOTAL FINAL:', '\$${compra.total.toStringAsFixed(2)}', isTotal: true),
              
              const SizedBox(height: 20),
              const Text(
                'Detalles de Productos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGreen),
              ),
              const SizedBox(height: 8),
              
              if (detalles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay detalles disponibles',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: detalles.length,
                    itemBuilder: (context, index) {
                      final detalle = detalles[index];
                      return _buildProductoDetalle(detalle, index);
                    },
                  ),
                ),
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? kGreen : Colors.black87,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? kGreen : Colors.black87,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoDetalle(DetalleCompra detalle, int index) {
    final subtotal = detalle.precioUnitario * detalle.cantidadUnitaria;
    final ivaCalculado = subtotal * (detalle.iva / 100);
    final totalDetalle = subtotal + ivaCalculado;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detalle.productoNombre,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 4,
              children: [
                _buildDetalleItem('Cantidad', '${detalle.cantidadUnitaria} unidades'),
                _buildDetalleItem('Precio Unitario', '\$${detalle.precioUnitario.toStringAsFixed(2)}'),
                _buildDetalleItem('Monto Unitario', '\$${detalle.montoUnitario.toStringAsFixed(2)}'),
                _buildDetalleItem('IVA', '${detalle.iva.toStringAsFixed(1)}%'),
                _buildDetalleItem('SubTotal', '\$${subtotal.toStringAsFixed(2)}'),
                _buildDetalleItem('IVA Calculado', '\$${ivaCalculado.toStringAsFixed(2)}'),
              ],
            ),
            
            const SizedBox(height: 8),
            const Divider(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total del Producto:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: kGreen),
                ),
                Text(
                  '\$${totalDetalle.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _cancelCrearCompra() {
    setState(() {
      _creandoCompra = false;
      tabCtrl?.dispose();
      tabCtrl = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.limpiarCarritoCompleto();
    });
  }

  String _dd(int x) => x.toString().padLeft(2, '0');

  void showSnack(BuildContext context, String msg, {Color? bg, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg, action: action)
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greenTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: kGreen, secondary: kGreenLight),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kGreen, width: 2)),
        prefixIconColor: kGreen,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: kGreen, foregroundColor: Colors.white, centerTitle: false),
    );

    return Theme(
      data: greenTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_creandoCompra ? 'Nueva compra' : 'Compras'),
          leading: _creandoCompra 
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _cancelCrearCompra,
                )
              : null,
          bottom: _creandoCompra
              ? TabBar(
                  controller: tabCtrl,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(icon: Icon(Icons.business_outlined), text: 'Proveedor'),
                    Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Productos'),
                    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Resumen'),
                  ],
                )
              : null,
          actions: [
            if (_creandoCompra)
              IconButton(
                tooltip: 'Cancelar', 
                icon: const Icon(Icons.close), 
                onPressed: _cancelCrearCompra
              ),
            if (!_creandoCompra)
              IconButton(
                tooltip: 'Refrescar compras', 
                icon: const Icon(Icons.refresh), 
                onPressed: () {
                  controller.load();
                  controller.loadProveedores();
                  controller.loadProductos();
                  controller.loadMarcas();
                  controller.loadCategorias();
                }
              ),
          ],
        ),
        floatingActionButton: _creandoCompra
            ? null
            : FloatingActionButton.extended(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                onPressed: _startCrearCompra,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Crear compra'),
              ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            if (!_creandoCompra) return _viewHistorial(context);

            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: tabCtrl,
                    children: [
                      _tabProveedor(context),
                      _tabProductos(context),
                      _tabResumen(context),
                    ],
                  ),
                ),
                _BottomSummaryBarCompact(
                  subtotal: controller.subTotal,
                  iva: controller.ivaTotal,
                  total: controller.total,
                  puedeConfirmar: controller.puedeConfirmar,
                  onConfirmar: _confirmar,
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
        ),
      ),
    );
  }

  Widget _tabProveedor(BuildContext context) {
    if (controller.proveedorId != null && _provText.text.isEmpty) {
      final proveedor = controller.proveedores.firstWhere(
        (p) => p.proveedorId == controller.proveedorId,
        orElse: () => Proveedor(
          proveedorId: 0,
          nombreEmpresa: '',
          direccion: '',
          telefono: '',
          email: '',
          aceptaDevoluciones: false,
          tiempoDevolucion: 0,
          porcentajeCobertura: 0,
        ),
      );
      if (proveedor.proveedorId != 0) {
        _provText.text = proveedor.nombreEmpresa;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _SectionTitle(icon: Icons.business, title: 'Proveedor'),
          const SizedBox(height: 16),
          
          Autocomplete<Proveedor>(
            displayStringForOption: (proveedor) => proveedor.nombreEmpresa,
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Proveedor>.empty();
              }
              return controller.proveedores.where((Proveedor proveedor) {
                return proveedor.nombreEmpresa
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Buscar proveedor',
                  hintText: 'Escribe el nombre del proveedor...',
                  prefixIcon: Icon(Icons.business_outlined),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.setProveedor(null);
                  }
                },
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Proveedor option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.nombreEmpresa),
                          subtitle: Text(option.telefono.isNotEmpty ? option.telefono : option.email),
                          onTap: () {
                            onSelected(option);
                            controller.setProveedor(option.proveedorId);
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (Proveedor selection) {
              controller.setProveedor(selection.proveedorId);
            },
          ),

          const SizedBox(height: 16),
          
          _DatePickerField(
            selectedDate: controller.fechaRegistro,
            onDateChanged: (newDate) {
              controller.setFechaRegistro(newDate);
            },
            label: 'Fecha de compra',
          ),

          const SizedBox(height: 16),
          
          if (controller.proveedorId != null) ...[
            Card(
             color: kGreen.withValues(alpha: 0.1),              
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proveedor seleccionado:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: kGreen),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<Proveedor?>(
                      future: _getProveedorSeleccionado(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final proveedor = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Empresa: ${proveedor.nombreEmpresa}'),
                              Text('Teléfono: ${proveedor.telefono}'),
                              Text('Email: ${proveedor.email}'),
                              Text('Acepta devoluciones: ${proveedor.aceptaDevoluciones ? 'Sí' : 'No'}'),
                            ],
                          );
                        }
                        return const Text('Cargando información...');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<Proveedor?> _getProveedorSeleccionado() async {
    if (controller.proveedorId == null) return null;
    try {
      return controller.proveedores.firstWhere(
        (p) => p.proveedorId == controller.proveedorId,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _tabProductos(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _productoSearchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _dialogAddItem(context),
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: controller.items.isEmpty
                ? const _EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Sin productos',
                    subtitle: 'Toca "Agregar" para añadir productos al carrito de la compra.',
                  )
                : Column(
                    children: [
                      Text(
                        'Productos en el carrito (${controller.items.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final it = controller.items[index];
                            final monto = it.precioUnitario * it.cantidadUnitaria;
                            final iva = monto * it.iva;
                            final tot = monto + iva;
                            final productoNombre = controller.getProductoNombreById(it.productoId);
                            
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: kGreen, width: 0.5),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: kGreen,
                                  foregroundColor: Colors.white,
                                  child: Text((index + 1).toString()),
                                ),
                                title: Text(
                                  productoNombre,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Precio: \$${it.precioUnitario.toStringAsFixed(2)} • '
                                      'Cantidad: ${it.cantidadUnitaria}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Subtotal: \$${monto.toStringAsFixed(2)} • '
                                      'IVA: \$${iva.toStringAsFixed(2)} • '
                                      'Total: \$${tot.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => controller.removeAt(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogAddItem(BuildContext context) async {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final cantCtrl = TextEditingController(text: '1');
    double ivaSel = controller.ivaTasa;
    Producto? productoSeleccionado;
    bool esNuevoProducto = false;

    final nuevoNombreCtrl = TextEditingController();
    Marca? marcaSeleccionada;
    Categoria? categoriaSeleccionada;

    List<Producto> productosFiltrados = controller.productos.where((producto) {
      final searchText = _productoSearchCtrl.text.toLowerCase();
      if (searchText.isEmpty) return true;
      return producto.nombreProducto.toLowerCase().contains(searchText) ||
             producto.codigo.toString().contains(searchText);
    }).toList();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Agregar producto a la compra'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Producto existente'),
                          selected: !esNuevoProducto,
                          onSelected: (_) => setStateDialog(() => esNuevoProducto = false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Nuevo producto'),
                          selected: esNuevoProducto,
                          onSelected: (_) => setStateDialog(() => esNuevoProducto = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (!esNuevoProducto) ...[
                    if (productosFiltrados.isNotEmpty) ...[
                      const Text('Selecciona un producto existente:'),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            return ListTile(
                              leading: const Icon(Icons.inventory_2, color: kGreen),
                              title: Text(producto.nombreProducto),
                              subtitle: Text(
                                'Código: ${producto.codigo} • '
                                'Precio: \$${producto.precioVenta.toStringAsFixed(2)} • '
                                'Stock: ${producto.cantidad}',
                              ),
                              trailing: productoSeleccionado?.productoId == producto.productoId
                                  ? const Icon(Icons.check_circle, color: kGreen)
                                  : null,
                              onTap: () {
                                setStateDialog(() {
                                  productoSeleccionado = producto;
                                  nombreCtrl.text = producto.nombreProducto;
                                  precioCtrl.text = producto.precioVenta.toStringAsFixed(2);
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Text('No hay productos disponibles'),
                      const SizedBox(height: 16),
                    ],
                  ] else ...[
                    const Text('Crear nuevo producto:'),
                    const SizedBox(height: 12),

                    TextField(
                      controller: nuevoNombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del nuevo producto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<Marca>(
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: marcaSeleccionada,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Selecciona una marca'),
                        ),
                        ...controller.marcas.map((marca) {
                          return DropdownMenuItem(
                            value: marca,
                            child: Text(marca.nombreMarca),
                          );
                        }),
                      ],
                      onChanged: (Marca? nuevaMarca) {
                        setStateDialog(() {
                          marcaSeleccionada = nuevaMarca;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<Categoria>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: categoriaSeleccionada,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Selecciona una categoría'),
                        ),
                        ...controller.categorias.map((categoria) {
                          return DropdownMenuItem(
                            value: categoria,
                            child: Text(categoria.nombreCategoria),
                          );
                        }),
                      ],
                      onChanged: (Categoria? nuevaCategoria) {
                        setStateDialog(() {
                          categoriaSeleccionada = nuevaCategoria;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    Card(
                      color: kGreen.withValues(alpha: 0.1),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del nuevo producto:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: kGreen),
                            ),
                            SizedBox(height: 4),
                            Text('• Unidad de medida: UNIDAD'),
                            Text('• Capacidad por unidad: 1'),
                            Text('• Activo: Sí'),
                            Text('• Fecha de registro: Fecha actual'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio unitario de compra',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cantCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad a comprar',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('IVA:'),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('0%'),
                        selected: ivaSel == 0.0,
                        onSelected: (_) => setStateDialog(() => ivaSel = 0.0),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('15%'),
                        selected: ivaSel == 0.15,
                        onSelected: (_) => setStateDialog(() => ivaSel = 0.15),
                      ),
                    ],
                  ),

                  if (esNuevoProducto && 
                      (nuevoNombreCtrl.text.isEmpty || 
                       marcaSeleccionada == null || 
                       categoriaSeleccionada == null))
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Complete todos los campos para el nuevo producto',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (esNuevoProducto) {
                  if (nuevoNombreCtrl.text.isEmpty || 
                      marcaSeleccionada == null || 
                      categoriaSeleccionada == null) {
                    return;
                  }
                } else {
                  if (productoSeleccionado == null) {
                    return;
                  }
                }
                Navigator.pop(context, true);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      final precio = double.tryParse(precioCtrl.text);
      final cantidad = int.tryParse(cantCtrl.text);
      
      if (precio != null && cantidad != null && cantidad > 0) {
        if (esNuevoProducto) {
        final nuevoProducto = await controller.crearNuevoProducto(
          nombre: nuevoNombreCtrl.text,
          marca: marcaSeleccionada!,
          categoria: categoriaSeleccionada!,
          precioCompra: precio,
          cantidad: cantidad,
        );
        
        if (nuevoProducto != null) {
          controller.addItem(
            productoId: nuevoProducto.productoId,
            nombre: nuevoProducto.nombreProducto,
            precio: precio,
            cantidad: cantidad,
            iva: ivaSel,
          );
          
          showSnack(context, '✅ Nuevo producto creado y agregado al carrito');
        } else {
          showSnack(context, '❌ Error al crear el nuevo producto', bg: Colors.red);
        }
      } else {
        controller.addItem(
          productoId: productoSeleccionado!.productoId,
          nombre: nombreCtrl.text,
          precio: precio,
          cantidad: cantidad,
          iva: ivaSel,
        );
        showSnack(context, 'Producto agregado al carrito');
      }
      } else {
        showSnack(context, 'Datos inválidos', bg: Colors.red);
      }
    }
  }

  Widget _tabResumen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const _SectionTitle(icon: Icons.summarize_outlined, title: 'Resumen de la compra'),
          const SizedBox(height: 16),
          
          if (controller.proveedorId != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proveedor:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder<Proveedor?>(
                      future: _getProveedorSeleccionado(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final proveedor = snapshot.data!;
                          return Text(proveedor.nombreEmpresa);
                        }
                        return const Text('Cargando...');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha de compra:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${controller.fechaRegistro.day}/${controller.fechaRegistro.month}/${controller.fechaRegistro.year}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const _SectionTitle(icon: Icons.calculate, title: 'Totales'),
          const SizedBox(height: 8),
          _RowTotal('Cantidad Total de Productos', controller.cantidadTotal.toString()),
          _RowTotal('SubTotal', '\$${controller.subTotal.toStringAsFixed(2)}'),
          _RowTotal('IVA Total', '\$${controller.ivaTotal.toStringAsFixed(2)}'),
          _RowTotal('TOTAL', '\$${controller.total.toStringAsFixed(2)}', bold: true),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: controller.puedeConfirmar ? _confirmar : null,
            icon: const Icon(Icons.check_circle, size: 24),
            label: const Text(
              'Confirmar Compra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.puedeConfirmar ? kGreen : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmar() async {
    final ok = await controller.confirmarCompra();
    if (!mounted) return;
    showSnack(
      context,
      ok ? '✅ Compra registrada exitosamente' : '❌ No se pudo registrar la compra',
      bg: ok ? Colors.green : Colors.redAccent,
    );
    if (ok) {
      _cancelCrearCompra();
    }
  }

  Widget _viewHistorial(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.loading && controller.compras.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error != null && controller.compras.isEmpty) {
          return _ErrorState(message: controller.error!, onRetry: controller.load);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _histSearchCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar por #compra o nombre de proveedor...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _histSearchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _histSearchCtrl.clear();
                            controller.setQuery('');
                            setState(() {});
                          },
                        ),
                ),
                onChanged: controller.setQuery,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => controller.load(),
                child: controller.compras.isEmpty
                    ? const _EmptyState(
                        icon: Icons.receipt_long_outlined, 
                        title: 'Sin compras', 
                        subtitle: 'No hay compras que coincidan con el filtro.'
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.compras.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, index) {
                          final c = controller.compras[index];
                          final f = c.fechaRegistro;
                          final fechaFmt = '${_dd(f.day)}/${_dd(f.month)}/${f.year} ${_dd(f.hour)}:${_dd(f.minute)}';
                          final proveedorNombre = controller.getProveedorNombreById(c.proveedorId);
                          
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), 
                              side: const BorderSide(color: kGreen, width: 0.5)
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              leading: CircleAvatar(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                radius: 20,
                                child: Text(c.compraId.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(
                                proveedorNombre,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: $fechaFmt', style: const TextStyle(fontSize: 12)),
                                  Text(
                                    'Productos: ${c.cantidadTotal} • Total: \$${c.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: kGreen),
                              onTap: () {
                                showSnack(context, 'Compra #${c.compraId} - $proveedorNombre');
                              },
                              onLongPress: () {
                                _mostrarDetallesCompra(context, c);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}