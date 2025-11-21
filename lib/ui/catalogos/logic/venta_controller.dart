import 'package:flutter/foundation.dart';
import 'package:application_library/data/models/venta_model.dart';
import 'package:application_library/data/services/venta_service.dart';

class VentaController extends ChangeNotifier {
  final VentaService service;
  final double ivaTasa;
  VentaController({ VentaService? service, this.ivaTasa = 0.15, })
      : service = service ?? VentaService();

  bool _loading = false;
  String? _error;

  List<Venta> _todas = [];
  List<Venta> _ventas = [];
  String _query = '';

  bool get loading => _loading;
  String? get error => _error;
  List<Venta> get ventas => List.unmodifiable(_ventas);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _todas = await service.obtenerVentas();
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
      _ventas = []; 
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    _query = q.trim().toLowerCase();
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    Iterable<Venta> data = _todas;
    if (_query.isNotEmpty) {
      data = data.where((v) {
        final id = v.ventaId.toString();
        final nom = (v.clienteNombre ?? '').toLowerCase();
        final cid = (v.clienteId?.toString() ?? '');
        return id.contains(_query) || nom.contains(_query) || cid.contains(_query);
      });
    }
    _ventas = data.toList()
      ..sort((a, b) => b.fechaVenta.compareTo(a.fechaVenta));
  }

  int? clienteId;
  double descuento = 0.0;
  double montoRecibido = 0.0;

  final List<DetalleVentaRequest> _items = [];
  List<DetalleVentaRequest> get items => List.unmodifiable(_items);

  void setCliente(int? id) { clienteId = id; notifyListeners(); }
  void setDescuento(double d) { descuento = d.clamp(0, double.infinity); notifyListeners(); }
  void setMontoRecibido(double m) { montoRecibido = m.clamp(0, double.infinity); notifyListeners(); }

  void addItem({
    required int productoId,
    required String nombre,
    required double precio,
    required int cantidad,
    double? iva,
  }) {
    final iv = (iva ?? ivaTasa).clamp(0.0, 1.0);
    _items.add(DetalleVentaRequest(
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precio,
      iva: iv,
    ));
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateQty(int index, int qty) {
    if (index < 0 || index >= _items.length) return;
    final it = _items[index];
    _items[index] = DetalleVentaRequest(
      productoId: it.productoId,
      cantidad: qty,
      precioUnitario: it.precioUnitario,
      iva: it.iva,
      tipoComprobante: it.tipoComprobante,
    );
    notifyListeners();
  }

  int get cantidadTotal => _items.fold(0, (a, b) => a + b.cantidad);
  double get subTotal => _items.fold(0.0, (a, b) => a + (b.precioUnitario * b.cantidad));
  double get iva => _items.fold(0.0, (a, b) => a + (b.precioUnitario * b.cantidad * b.iva));
  double get total => (subTotal - descuento + iva).clamp(0.0, double.infinity);
  double get montoDevuelto => (montoRecibido - total);
  bool get puedeConfirmar => _items.isNotEmpty && montoRecibido >= total;

  void limpiarCarrito() {
    clienteId = null;
    descuento = 0.0;
    montoRecibido = 0.0;
    _items.clear();
    notifyListeners();
  }

  Future<bool> confirmarVenta() async {
    final req = VentaRequest(
      clienteId: clienteId,
      montoRecibido: montoRecibido,
      descuento: descuento,
      detallesVenta: _items,
    );
    final ok = await service.crearVenta(req);
    if (ok) {
      limpiarCarrito();
      await load();
    }
    return ok;
  }

  final Map<int, List<DetalleVenta>> _detallesCache = {};
  List<DetalleVenta>? detallesEnCache(int ventaId) => _detallesCache[ventaId];

  Future<List<DetalleVenta>> loadDetalles(int ventaId, {bool force = false}) async {
    if (!force && _detallesCache.containsKey(ventaId)) {
      return _detallesCache[ventaId]!;
    }
    final dets = await service.obtenerDetallesVenta(ventaId);
    _detallesCache[ventaId] = dets;
    notifyListeners();
    return dets;
  }
}