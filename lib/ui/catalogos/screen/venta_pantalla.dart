import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/ui/catalogos/logic/venta_controller.dart';
import 'package:application_library/data/models/cliente_model.dart';
import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/data/models/venta_model.dart';
import 'package:application_library/data/services/cliente_service.dart';
import 'package:application_library/data/services/producto_service.dart';
import 'package:application_library/ui/core/routes/app_router.gr.dart';

const kBlue = Color(0xFF1565C0);
const kBlueLight = Color(0xFF1E88E5);

const kTs11 = TextStyle(fontSize: 11);
const kTs12 = TextStyle(fontSize: 12);
const kTs13 = TextStyle(fontSize: 13);
const kTs14 = TextStyle(fontSize: 14);
const kTs16 = TextStyle(fontSize: 16);
const kTs16b = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

SizedBox gap(double h) => SizedBox(height: h);
SizedBox wgap(double w) => SizedBox(width: w);

InputDecoration dec({String? label, String? hint, IconData? icon}) => InputDecoration(
  labelText: label,
  hintText: hint,
  labelStyle: kTs13,
  hintStyle: kTs13,
  prefixIcon: icon == null ? null : Icon(icon, size: 18),
);

void showSnack(BuildContext c, String msg, {Color? bg, SnackBarAction? action}) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg, action: action));
}

@RoutePage()
class PantallaVenta extends StatefulWidget {
  static const String nombreRuta = 'ventas';
  const PantallaVenta({super.key});
  @override
  State<PantallaVenta> createState() => _PantallaVentaState();
}

class _PantallaVentaState extends State<PantallaVenta> with SingleTickerProviderStateMixin {
  late final VentaController controller;
  late final ClienteService _clienteService;
  late final ProductoService _productoService;

  TabController? tabCtrl;
  bool _creandoVenta = false;
  int _selectedIndex = 1;

  final TextEditingController _cliText = TextEditingController();
  List<Cliente> _clientesCache = [];
  bool _clientesCargados = false;
  Cliente? _clienteSeleccionado;

  List<Producto> _productoCache = [];
  bool _productosCargados = false;

  final TextEditingController _histSearchCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _recCtrl = TextEditingController();
  final FocusNode _descFocus = FocusNode();
  final FocusNode _recFocus = FocusNode();

  bool get _isProductosTab => _creandoVenta && (tabCtrl?.index == 1);

  @override
  void initState() {
    super.initState();
    controller = VentaController()..load();
    _clienteService = ClienteService();
    _productoService = ProductoService();
    _descCtrl.text = controller.descuento.toStringAsFixed(2);
    _recCtrl.text = controller.montoRecibido.toStringAsFixed(2);
    _descFocus.addListener(() { if (!_descFocus.hasFocus) _syncResumenToController(); });
    _recFocus.addListener(() { if (!_recFocus.hasFocus) _syncResumenToController(); });
  }

  @override
  void dispose() {
    tabCtrl?.dispose();
    controller.dispose();
    _cliText.dispose();
    _histSearchCtrl.dispose();
    _descCtrl.dispose();
    _recCtrl.dispose();
    _descFocus.dispose();
    _recFocus.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      switch (index) {
        case 0: 
          context.router.replace(const RoutePrincipal());
          break;
        case 1: 
          break;
        case 2: 
          context.router.replace(const RouteCompra());
          break;
        case 3: 
          context.router.replace(const RouteAdminUsuarios());
          break;
      }
    }
  }

  void _startCrearVenta() {
    setState(() {
      _creandoVenta = true;
      tabCtrl?.dispose();
      tabCtrl = TabController(length: 3, vsync: this);
    });
  }

  void _cancelCrearVenta() {
    setState(() {
      _creandoVenta = false;
      tabCtrl?.dispose();
      tabCtrl = null;
      _descCtrl.text = controller.descuento.toStringAsFixed(2);
      _recCtrl.text = controller.montoRecibido.toStringAsFixed(2);
    });
  }

  String _dd(int x) => x.toString().padLeft(2, '0');
  double _parseDouble(String s) => double.tryParse(s.replaceAll(',', '.')) ?? 0.0;

  void _syncResumenToController() {
    controller.setDescuento(_parseDouble(_descCtrl.text));
    controller.setMontoRecibido(_parseDouble(_recCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blueTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(primary: kBlue, secondary: kBlueLight),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kBlue, width: 2)),
        prefixIconColor: kBlue,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: kBlue, foregroundColor: Colors.white, centerTitle: false),
    );

    return Theme(
      data: blueTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_creandoVenta ? 'Nueva venta' : 'Ventas'),
          leading: _creandoVenta
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _cancelCrearVenta,
                )
              : null,
          bottom: _creandoVenta
              ? TabBar(
                  controller: tabCtrl,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(icon: Icon(Icons.person_outline), text: 'Cliente'),
                    Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Productos'),
                    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Resumen'),
                  ],
                )
              : null,
          actions: [
            if (_creandoVenta)
              IconButton(tooltip: 'Cancelar', icon: const Icon(Icons.close), onPressed: _cancelCrearVenta),
            if (!_creandoVenta)
              IconButton(tooltip: 'Refrescar ventas', icon: const Icon(Icons.refresh), onPressed: controller.load),
          ],
        ),
        floatingActionButton: _creandoVenta
            ? null
            : FloatingActionButton.extended(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                onPressed: _startCrearVenta,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Crear venta'),
              ),
        body: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            if (!_creandoVenta) return _viewHistorial(context);

            final descUI = _parseDouble(_descCtrl.text);
            final recibidoUI = _parseDouble(_recCtrl.text);
            final subUI = controller.subTotal;
            final ivaUI = controller.iva;
            final totalUI = (subUI - descUI + ivaUI).clamp(0.0, double.infinity);
            final cambioUI = (recibidoUI - totalUI);
            final puedeConfirmarUI = controller.items.isNotEmpty && recibidoUI >= totalUI;

            return Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: tabCtrl,
                    children: [
                      _tabCliente(context),
                      _tabProductos(context),
                      _tabResumen(context, totalUI: totalUI, cambioUI: cambioUI, puedeConfirmarUI: puedeConfirmarUI),
                    ],
                  ),
                ),
                _BottomSummaryBarCompact(
                  subtotal: subUI,
                  iva: ivaUI,
                  total: totalUI,
                  recibido: recibidoUI,
                  cambio: cambioUI,
                  puedeConfirmar: puedeConfirmarUI,
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

  Future<void> _ensureClientes() async {
    if (_clientesCargados) return;
    try {
      final list = await _clienteService.obtenerClientes();
      if (!mounted) return;
      setState(() {
        _clientesCache = list;
        _clientesCargados = true;
      });
    } catch (err) {
      if (!mounted) return;
      showSnack(context, 'No se pudieron cargar clientes: $err');
    }
  }

  Widget _tabCliente(BuildContext context) {
    _ensureClientes();
    if (_clienteSeleccionado != null && _cliText.text.isEmpty) {
      _cliText.text = '${_clienteSeleccionado!.nombre} ${_clienteSeleccionado!.apellido}'.trim();
    }

    Iterable<Cliente> filtrarClientes(String query) {
      final filtro = query.trim().toLowerCase();
      if (filtro.isEmpty) return const Iterable<Cliente>.empty();
      return _clientesCache.where((c) {
        final full = ('${c.nombre} ${c.apellido}').toLowerCase();
        return full.contains(filtro);
      }).take(30);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const _SectionTitle(icon: Icons.person, title: 'Cliente'),
          gap(8),
          Autocomplete<Cliente>(
            displayStringForOption: (c) => '${c.nombre} ${c.apellido}'.trim(),
            optionsBuilder: (te) => filtrarClientes(te.text),
            fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
              textController.text = _cliText.text;
              textController.selection = TextSelection.fromPosition(TextPosition(offset: textController.text.length));
              return TextField(
                controller: _cliText,
                focusNode: focusNode,
                decoration: dec(hint: 'Crear o buscar cliente…', icon: Icons.badge_outlined).copyWith(
                  suffixIcon: _cliText.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _cliText.clear();
                              _clienteSeleccionado = null;
                              controller.setCliente(null);
                            });
                          },
                        ),
                ),
                onChanged: (_) {
                  setState(() {
                    _clienteSeleccionado = null;
                    controller.setCliente(null);
                  });
                },
                onSubmitted: (_) => onSubmitted(),
              );
            },
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260, maxWidth: 520),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    children: [
                      for (final o in options)
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: kBlue),
                          title: Text('${o.nombre} ${o.apellido}'.trim(), style: kTs14),
                          subtitle: Text(o.telefono.isEmpty ? o.email : o.telefono, style: kTs12),
                          onTap: () => onSelected(o),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            onSelected: (cli) {
              setState(() {
                _clienteSeleccionado = cli;
                _cliText.text = '${cli.nombre} ${cli.apellido}'.trim();
                controller.setCliente(cli.clienteId);
              });
            },
          ),
          gap(12),
          _InfoChip(icon: Icons.event, label: 'Fecha', value: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
        ],
      ),
    );
  }

  Future<void> _ensureProductos() async {
    if (_productosCargados) return;
    try {
      final list = await _productoService.obtenerProductos();
      if (!mounted) return;
      setState(() {
        _productoCache = list;
        _productosCargados = true;
      });
    } catch (err) {
      if (!mounted) return;
      showSnack(context, 'No se pudieron cargar productos: $err');
    }
  }

  Widget _tabProductos(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => _dialogAddItem(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
            ),
          ),
          gap(8),
          Expanded(
            child: controller.items.isEmpty
                ? const _EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Sin productos',
                    subtitle: 'Toca "Agregar producto" para añadir al carrito de la venta.',
                  )
                : ListView.separated(
                    itemCount: controller.items.length,
                    separatorBuilder: (_, __) => gap(8),
                    itemBuilder: (context, index) {
                      final it = controller.items[index];
                      final sub = it.precioUnitario * it.cantidad;
                      final iva = sub * it.iva;
                      final tot = sub + iva;
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: kBlue, width: 0.3),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          leading: const CircleAvatar(backgroundColor: kBlue, foregroundColor: Colors.white, child: Icon(Icons.tag)),
                          title: const Text('Producto', style: kTs14),
                          subtitle: Text(
                            'Precio: ${it.precioUnitario.toStringAsFixed(2)} • '
                            'Cant: ${it.cantidad}\n'
                            'Sub: ${sub.toStringAsFixed(2)} '
                            'IVA: ${iva.toStringAsFixed(2)} '
                            'Total: ${tot.toStringAsFixed(2)}',
                            style: kTs12,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (s) {
                              if (s == 'qty') {
                                _dialogQty(context, index, it.cantidad);
                              } else if (s == 'del') {
                                controller.removeAt(index);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'qty',
                                child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 6), Text('Cantidad', style: kTs12)]),
                              ),
                              PopupMenuItem(
                                value: 'del',
                                child: Row(children: [Icon(Icons.delete, size: 16), SizedBox(width: 6), Text('Eliminar', style: kTs12)]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogAddItem(BuildContext context) async {
    await _ensureProductos();
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final cantCtrl = TextEditingController(text: '1');
    double ivaSel = controller.ivaTasa;
    Producto? productoSeleccionado;

    Iterable<Producto> filtrarProductos(String query) {
      final filtro = query.trim().toLowerCase();
      if (filtro.isEmpty) return const Iterable<Producto>.empty();
      return _productoCache.where((p) {
        final n = p.nombreProducto.toLowerCase();
        final cod = p.codigo.toString();
        return n.contains(filtro) || cod.contains(filtro);
      }).take(30);
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Agregar producto', style: kTs16),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<Producto>(
                  displayStringForOption: (o) => o.nombreProducto,
                  optionsBuilder: (te) => filtrarProductos(te.text),
                  fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      style: kTs13,
                      decoration: dec(label: 'Buscar producto', icon: Icons.shopping_bag_outlined),
                      onChanged: (_) {
                        setStateDialog(() {
                          productoSeleccionado = null;
                          nombreCtrl.clear();
                          precioCtrl.clear();
                        });
                      },
                      onSubmitted: (_) => onSubmitted(),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          children: [
                            for (final o in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.inventory_2_outlined, color: kBlue, size: 18),
                                title: Text(o.nombreProducto, style: kTs13),
                                subtitle: Text(
                                  'Precio: ${o.precioVenta.toStringAsFixed(2)} • Stock: ${o.estadoStock}',
                                  style: kTs11,
                                ),
                                onTap: () => onSelected(o),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onSelected: (o) {
                    setStateDialog(() {
                      productoSeleccionado = o;
                      nombreCtrl.text = o.nombreProducto;
                      precioCtrl.text = o.precioVenta.toStringAsFixed(2);
                    });
                  },
                ),
                gap(8),
                TextField(controller: nombreCtrl, style: kTs13, decoration: dec(label: 'Nombre', icon: Icons.text_fields), readOnly: true),
                gap(8),
                TextField(
                  controller: precioCtrl,
                  style: kTs13,
                  decoration: dec(label: 'Precio unitario', icon: Icons.attach_money),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                gap(8),
                TextField(
                  controller: cantCtrl,
                  style: kTs13,
                  decoration: dec(label: 'Cantidad', icon: Icons.numbers),
                  keyboardType: TextInputType.number,
                ),
                gap(10),
                Row(
                  children: [
                    const Text('IVA', style: kTs13),
                    wgap(10),
                    ChoiceChip(label: const Text('0%', style: kTs11), selected: ivaSel == 0.0, onSelected: (_) => setStateDialog(() => ivaSel = 0.0)),
                    wgap(6),
                    ChoiceChip(
                      label: Text('${(controller.ivaTasa * 100).toStringAsFixed(0)}%', style: kTs11),
                      selected: ivaSel == controller.ivaTasa,
                      onSelected: (_) => setStateDialog(() => ivaSel = controller.ivaTasa),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: kTs13)),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Agregar', style: kTs13)),
          ],
        ),
      ),
    );

    if (ok == true) {
      final precio = double.tryParse(precioCtrl.text.trim());
      final cantidad = int.tryParse(cantCtrl.text.trim());
      if (productoSeleccionado != null && precio != null && cantidad != null && cantidad > 0) {
        controller.addItem(
          productoId: productoSeleccionado!.productoId,
          nombre: nombreCtrl.text.trim().isEmpty ? productoSeleccionado!.nombreProducto : nombreCtrl.text.trim(),
          precio: precio,
          cantidad: cantidad,
          iva: ivaSel,
        );
        if (!mounted) return;
        if (!_isProductosTab) tabCtrl?.animateTo(1);
      } else {
        if (!mounted) return;
        showSnack(context, 'Datos inválidos del producto');
      }
    }
  }

  Future<void> _dialogQty(BuildContext context, int index, int currentQty) async {
    final qtyCtrl = TextEditingController(text: currentQty.toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar cantidad', style: kTs16),
        content: TextField(controller: qtyCtrl, style: kTs13, keyboardType: TextInputType.number, decoration: dec(label: 'Cantidad', icon: Icons.numbers)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: kTs13)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar', style: kTs13)),
        ],
      ),
    );
    if (ok == true) {
      final cantidad = int.tryParse(qtyCtrl.text.trim());
      if (cantidad != null && cantidad > 0) controller.updateQty(index, cantidad);
    }
  }

  Widget _tabResumen(BuildContext context, {required double totalUI, required double cambioUI, required bool puedeConfirmarUI}) {
    if (!_descFocus.hasFocus) {
      final t = controller.descuento.toStringAsFixed(2);
      if (_descCtrl.text != t) _descCtrl.text = t;
    }
    if (!_recFocus.hasFocus) {
      final t = controller.montoRecibido.toStringAsFixed(2);
      if (_recCtrl.text != t) _recCtrl.text = t;
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const _SectionTitle(icon: Icons.summarize_outlined, title: 'Totales'),
          gap(8),
          _RowTotal('Cantidad', controller.cantidadTotal.toString()),
          _RowTotal('SubTotal', controller.subTotal.toStringAsFixed(2)),
          gap(8),
          TextField(
            controller: _descCtrl,
            focusNode: _descFocus,
            style: kTs13,
            decoration: dec(label: 'Descuento', icon: Icons.percent),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onTap: () {
              if (_descCtrl.selection.baseOffset == _descCtrl.selection.extentOffset) {
                _descCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _descCtrl.text.length);
              }
            },
            onChanged: (v) {
              setState(() {});
            },
            onSubmitted: (v) => _syncResumenToController(),
          ),
          gap(12),
          TextField(
            controller: _recCtrl,
            focusNode: _recFocus,
            style: kTs13,
            decoration: dec(label: 'Monto recibido', icon: Icons.payments_outlined),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onTap: () {
              if (_recCtrl.selection.baseOffset == _recCtrl.selection.extentOffset) {
                _recCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _recCtrl.text.length);
              }
            },
            onChanged: (v) {
              setState(() {});
            },
            onSubmitted: (v) => _syncResumenToController(),
          ),
          gap(16),
          ElevatedButton.icon(
            onPressed: puedeConfirmarUI ? _confirmar : null,
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Confirmar venta', style: kTs13),
          ),
          gap(80),
        ],
      ),
    );
  }

  Future<void> _confirmar() async {
    _syncResumenToController();
    final ok = await controller.confirmarVenta();
    if (!mounted) return;
    showSnack(
      context,
      ok ? 'Venta registrada' : 'No se pudo registrar la venta',
      bg: ok ? Colors.green : Colors.redAccent,
      action: ok
          ? SnackBarAction(
              label: 'VER',
              textColor: Colors.white,
              onPressed: () {
                if (controller.ventas.isNotEmpty) {
                  final ventaItem = controller.ventas.first;
                  _mostrarDetallesVenta(context, ventaItem);
                }
              },
            )
          : null,
    );
    if (ok) {
      _cancelCrearVenta();
      controller.load();
    }
  }

  Widget _viewHistorial(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.loading && controller.ventas.isEmpty) return const Center(child: CircularProgressIndicator());
        if (controller.error != null && controller.ventas.isEmpty) {
          return _ErrorState(message: controller.error!, onRetry: controller.load);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: TextField(
                controller: _histSearchCtrl,
                style: kTs13,
                decoration: dec(hint: 'Buscar por #venta, cliente o cliente_ID…', icon: Icons.search).copyWith(
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
            gap(6),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => controller.load(),
                child: controller.ventas.isEmpty
                    ? const _EmptyState(icon: Icons.receipt_long_outlined, title: 'Sin ventas', subtitle: 'No hay ventas que coincidan con el filtro.')
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.ventas.length,
                        separatorBuilder: (_, __) => gap(8),
                        itemBuilder: (_, index) {
                          final v = controller.ventas[index];
                          final f = v.fechaVenta;
                          final fechaFmt = '${_dd(f.day)}/${_dd(f.month)}/${f.year} ${_dd(f.hour)}:${_dd(f.minute)}';
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: kBlue, width: 0.3)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: kBlue,
                                foregroundColor: Colors.white,
                                radius: 18,
                                child: Text(v.ventaId.toString(), style: const TextStyle(fontSize: 11)),
                              ),
                              title: Text(
                                v.clienteNombre ?? (v.clienteId != null ? 'Cliente ${v.clienteId}' : 'Consumidor final'),
                                style: kTs14,
                              ),
                              subtitle: Text(
                                'Fecha: $fechaFmt\n'
                                'Cant: ${v.cantidadTotal} • Sub: ${v.subTotal.toStringAsFixed(2)} '
                                '• IVA: ${v.iva.toStringAsFixed(2)} • Desc: ${v.descuento.toStringAsFixed(2)} '
                                '• Total: ${v.total.toStringAsFixed(2)}',
                                style: kTs11,
                              ),
                              trailing: IconButton(tooltip: 'Ver detalles', icon: const Icon(Icons.visibility, size: 18), onPressed: () => _mostrarDetallesVenta(context, v)),
                              onTap: () => _mostrarDetallesVenta(context, v),
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

  Future<void> _mostrarDetallesVenta(BuildContext context, Venta v) async {
    final detalles = await controller.loadDetalles(v.ventaId);
    final f = v.fechaVenta;
    final fechaFmt = '${_dd(f.day)}/${_dd(f.month)}/${f.year} ${_dd(f.hour)}:${_dd(f.minute)}';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: kBlue, size: 20),
                  wgap(8),
                  Expanded(child: Text('Venta #${v.ventaId}', style: kTs16b)),
                  Chip(label: Text(v.estado, style: const TextStyle(fontSize: 10)), backgroundColor: kBlue),
                ],
              ),
              gap(12),
              _buildDetailRow('Cliente:', v.clienteNombre ?? 'Consumidor final'),
              _buildDetailRow('Fecha:', fechaFmt),
              _buildDetailRow('Productos:', v.cantidadTotal.toString()),
              gap(12),
              const Divider(height: 1),
              gap(8),
              const Text('Productos:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              gap(8),
              if (detalles.isEmpty) const Text('No hay productos', style: TextStyle(fontSize: 12, color: Colors.grey)) else ...detalles.map((d) => _buildProductoSimple(d)),
              gap(12),
              const Divider(height: 1),
              gap(8),
              _buildTotalRow('SubTotal:', v.subTotal),
              _buildTotalRow('IVA:', v.iva),
              _buildTotalRow('Descuento:', v.descuento),
              _buildTotalRow('TOTAL:', v.total, isTotal: true),
              gap(16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
                  child: const Text('Cerrar', style: kTs12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Text('$label ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), Expanded(child: Text(value, style: kTs12))]),
      );

  Widget _buildTotalRow(String label, double value, {bool isTotal = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isTotal ? FontWeight.bold : FontWeight.w600, color: isTotal ? kBlue : Colors.black87)),
            const Spacer(),
            Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? kBlue : Colors.black87)),
          ],
        ),
      );

  Widget _buildProductoSimple(DetalleVenta d) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag, color: kBlue, size: 16),
            wgap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.productoNombre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  Text('${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)} = \$${d.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: kBlue),
        wgap(6),
        Icon(icon, color: kBlue, size: 16),
        wgap(6),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: kTs13)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : null)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, color: kBlue, size: 16),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Chip(
          label: Text(value, style: kTs11),
          backgroundColor: kBlue.withValues(alpha: 0.08),
          side: const BorderSide(color: kBlue, width: 0.5),
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
            Icon(icon, size: 48, color: kBlue),
            gap(8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            gap(4),
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
            gap(8),
            Text(message, textAlign: TextAlign.center, style: kTs12),
            gap(8),
            OutlinedButton.icon(icon: const Icon(Icons.refresh, size: 14), label: const Text('Reintentar', style: kTs12), onPressed: onRetry),
          ],
        ),
      ),
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
      label: Text('$label: ${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : null)),
      backgroundColor: kBlue.withValues(alpha: 0.07),
      side: const BorderSide(color: kBlue, width: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _BottomSummaryBarCompact extends StatelessWidget {
  final double subtotal;
  final double iva;
  final double total;
  final double recibido;
  final double cambio;
  final bool puedeConfirmar;
  final VoidCallback onConfirmar;
  const _BottomSummaryBarCompact({
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.recibido,
    required this.cambio,
    required this.puedeConfirmar,
    required this.onConfirmar,
  });
  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _AmountChip(label: 'Sub', value: subtotal),
      _AmountChip(label: 'IVA', value: iva),
      _AmountChip(label: 'Total', value: total, bold: true),
      _AmountChip(label: 'Recibido', value: recibido),
      _AmountChip(label: 'Cambio', value: cambio),
    ];
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
                  child: Row(children: [for (final chip in chips) Padding(padding: const EdgeInsets.only(right: 4), child: chip)]),
                ),
              ),
              wgap(6),
              ElevatedButton.icon(
                onPressed: puedeConfirmar ? onConfirmar : null,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Confirmar', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
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