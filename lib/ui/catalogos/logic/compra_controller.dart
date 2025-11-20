import 'package:application_library/data/models/categoria.model.dart';
import 'package:application_library/data/models/compra_model.dart';
import 'package:application_library/data/models/proveedor_model.dart';
import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/data/services/compra_service.dart';
import 'package:application_library/data/services/proveedor_service.dart';
import 'package:application_library/data/services/producto_service.dart';
import 'package:application_library/data/services/marca_service.dart';
import 'package:application_library/data/services/categoria_service.dart';
import 'package:flutter/material.dart';

class CompraController extends ChangeNotifier {
  final CompraService _compraService;
  final ProveedorService _proveedorService;
  final ProductoService _productoService;
  final MarcaService _marcaService;
  final CategoriaService _categoriaService;
  final double ivaTasa;
  
  int? _proveedorId;
  DateTime _fechaRegistro = DateTime.now();
  final List<DetalleCompraRequest> _items = [];
  final TextEditingController? _provText;
  int get _usuarioId => 1;

  CompraController({
    CompraService? compraService, 
    ProveedorService? proveedorService,
    ProductoService? productoService,
    MarcaService? marcaService,
    CategoriaService? categoriaService,
    this.ivaTasa = 0.15
  })  : _compraService = compraService ?? CompraService(),
        _proveedorService = proveedorService ?? ProveedorService(),
        _productoService = productoService ?? ProductoService(),
        _marcaService = marcaService ?? MarcaService(),
        _categoriaService = categoriaService ?? CategoriaService(),
        _provText = null;

  bool _loading = false;
  String? _error;

  List<Compra> _todas = [];
  List<Compra> _compras = [];
  String _query = '';

  List<Proveedor> _proveedores = [];
  List<Producto> _productos = [];
  List<Marca> _marcas = [];
  List<Categoria> _categorias = [];
  bool _proveedoresCargados = false;
  bool _productosCargados = false;
  bool _marcasCargadas = false;
  bool _categoriasCargadas = false;

  bool get loading => _loading;
  String? get error => _error;
  List<Compra> get compras => List.unmodifiable(_compras);
  List<Proveedor> get proveedores => List.unmodifiable(_proveedores);
  List<Producto> get productos => List.unmodifiable(_productos);
  List<Marca> get marcas => List.unmodifiable(_marcas);
  List<Categoria> get categorias => List.unmodifiable(_categorias);
  bool get proveedoresCargados => _proveedoresCargados;
  bool get productosCargados => _productosCargados;
  bool get marcasCargadas => _marcasCargadas;
  bool get categoriasCargadas => _categoriasCargadas;

  int? get proveedorId => _proveedorId;
  DateTime get fechaRegistro => _fechaRegistro;
  List<DetalleCompraRequest> get items => List.unmodifiable(_items);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _todas = await _compraService.obtenerCompras();
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
      _compras = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadProveedores() async {
    try {
      _proveedores = await _proveedorService.obtenerProveedores();
      _proveedoresCargados = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando proveedores: $e';
      _proveedores = [];
    }
  }

  Future<void> loadProductos() async {
    try {
      _productos = await _productoService.obtenerProductos();
      _productosCargados = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando productos: $e';
      _productos = [];
    }
  }

  Future<void> loadMarcas() async {
    try {
      _marcas = await _marcaService.obtenerMarcas();
      _marcasCargadas = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando marcas: $e';
      _marcas = [];
    }
  }

  Future<void> loadCategorias() async {
    try {
      _categorias = await _categoriaService.obtenerCategorias();
      _categoriasCargadas = true;
      notifyListeners();
    } catch (e) {
      _error = 'Error cargando categorias: $e';
      _categorias = [];
    }
  }

  void setQuery(String q) {
    _query = q.trim().toLowerCase();
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    Iterable<Compra> data = _todas;
    if (_query.isNotEmpty) {
      data = data.where((c) {
        final id = c.compraId.toString();
        final proveedorNombre = _getProveedorNombre(c.proveedorId)?.toLowerCase() ?? '';
        return id.contains(_query) || proveedorNombre.contains(_query);
      });
    }
    _compras = data.toList()
      ..sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));
  }

  String? _getProveedorNombre(int proveedorId) {
    try {
      final proveedor = _proveedores.firstWhere((p) => p.proveedorId == proveedorId);
      return proveedor.nombreEmpresa;
    } catch (e) {
      return null;
    }
  }

  void setProveedor(int? id) {
    _proveedorId = id;
    notifyListeners();
  }

  void setFechaRegistro(DateTime fecha) {
    _fechaRegistro = fecha;
    notifyListeners();
  }

  void limpiarCarritoCompleto() {
    _items.clear();
    _proveedorId = null;
    _fechaRegistro = DateTime.now();
    _provText?.clear();
    notifyListeners();
  }

  void addItem({
    required int productoId,
    required String nombre,
    required double precio,
    required int cantidad,
    double? iva,
  }) {
    final ivaValidado = (iva ?? ivaTasa).clamp(0.0, 1.0);
    if (precio <= 0) {
      return;
    }
    
    _items.add(DetalleCompraRequest(
      productoId: productoId,
      cantidadUnitaria: cantidad,
      precioUnitario: precio,
      iva: ivaValidado,
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
    _items[index] = DetalleCompraRequest(
      productoId: it.productoId,
      cantidadUnitaria: qty,
      precioUnitario: it.precioUnitario,
      iva: it.iva,
    );
    notifyListeners();
  }

  int get cantidadTotal => _items.fold(0, (a, b) => a + b.cantidadUnitaria);
  double get subTotal => _items.fold(0.0, (a, b) => a + (b.precioUnitario * b.cantidadUnitaria));
  double get ivaTotal => _items.fold(0.0, (a, b) => a + (b.precioUnitario * b.cantidadUnitaria * b.iva));
  double get total => (subTotal + ivaTotal).clamp(0.0, double.infinity);
  bool get puedeConfirmar => _items.isNotEmpty && _proveedorId != null;

  void limpiarCarrito() {
    _proveedorId = null;
    _fechaRegistro = DateTime.now();
    _items.clear();
    notifyListeners();
  }

  Future<bool> confirmarCompra() async {
    try {
      if (!puedeConfirmar) return false;
      final detalles = _items.map((item) {
        return {
          'producto_ID': item.productoId,
          'cantidadUnitaria': item.cantidadUnitaria,
          'precioUnitario': item.precioUnitario,
          'iva': item.iva,
        };
      }).toList();

      final compraData = {
        'usuario_ID': _usuarioId,
        'proveedor_ID': _proveedorId!,
        'cantidadTotal': cantidadTotal,
        'montoTotal': total,
        'subTotal': subTotal,
        'ivaTotal': ivaTotal,
        'total': total,
        'fechaRegistro': _fechaRegistro.toIso8601String(),
        'detallesCompra': detalles,
      };

      final response = await _compraService.crearCompra(compraData);

      if (response != null) {
        _limpiarYResetear();
        await load();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _limpiarYResetear() {
    _items.clear();
    _proveedorId = null;
    _fechaRegistro = DateTime.now();
    notifyListeners();
  }

  final Map<int, List<DetalleCompra>> _detallesCache = {};
  List<DetalleCompra>? detallesEnCache(int compraId) => _detallesCache[compraId];

  Future<List<DetalleCompra>> loadDetalles(int compraId, {bool force = false}) async {
    try {
      if (!force && _detallesCache.containsKey(compraId)) {
        return _detallesCache[compraId]!;
      }
      
      final dets = await _compraService.obtenerDetallesCompra(compraId);  
      _detallesCache[compraId] = dets;
      notifyListeners();
      return dets;
    } catch (e) {
      return [];
    }
  }
  String getProveedorNombreById(int proveedorId) {
    try {
      final proveedor = _proveedores.firstWhere((p) => p.proveedorId == proveedorId);
      return proveedor.nombreEmpresa;
    } catch (e) {
      return 'Proveedor $proveedorId';
    }
  }

  String getProductoNombreById(int productoId) {
    try {
      final producto = _productos.firstWhere((p) => p.productoId == productoId);
      return producto.nombreProducto;
    } catch (e) {
      return 'Producto $productoId';
    }
  }

  int obtenerMarcaIdPorNombre(String marcaNombre) {
    try {
      final marca = _marcas.firstWhere(
        (m) => m.nombreMarca.toLowerCase() == marcaNombre.toLowerCase(),
        orElse: () => Marca(
          marcaId: 1,
          nombreMarca: '',
          activo: true,
          fechaRegistro: DateTime.now(),
        ),
      );
      return marca.marcaId;
    } catch (e) {
      return 1;
    }
  }

  int obtenerCategoriaIdPorNombre(String categoriaNombre) {
    try {
      final categoria = _categorias.firstWhere(
        (c) => c.nombreCategoria.toLowerCase() == categoriaNombre.toLowerCase(),
        orElse: () => Categoria(
          categoriaId: 1,
          nombreCategoria: '',
          activo: true,
          fechaRegistro: DateTime.now(),
        ),
      );
      return categoria.categoriaId;
    } catch (e) {
      return 1;
    }
  }

  String obtenerMarcaNombrePorId(int marcaId) {
    try {
      final marca = _marcas.firstWhere((m) => m.marcaId == marcaId);
      return marca.nombreMarca;
    } catch (e) {
      return 'Marca $marcaId';
    }
  }

  String obtenerCategoriaNombrePorId(int categoriaId) {
    try {
      final categoria = _categorias.firstWhere((c) => c.categoriaId == categoriaId);
      return categoria.nombreCategoria;
    } catch (e) {
      return 'Categoria $categoriaId';
    }
  }

  Future<Producto?> crearNuevoProducto({
    required String nombre,
    required Marca marca,
    required Categoria categoria,
    required double precioCompra,
    required int cantidad,
  }) async {
    final nuevoProducto = Producto(
      productoId: 0,
      marcaId: marca.marcaId,
      categoriaId: categoria.categoriaId,
      codigo: 0,
      nombreProducto: nombre,
      unidadMedida: 'UNIDAD',
      capacidadUnidad: 1,
      cantidad: cantidad,
      activo: true,
      fechaRegistro: DateTime.now(),
      marca: marca.nombreMarca,
      categoria: categoria.nombreCategoria,
      precioVenta: precioCompra * 1.3,
      costoCompra: precioCompra,
      margenGanancia: precioCompra * 0.3,
      porcentajeMargen: 30.0,
      estadoStock: cantidad > 0 ? 'Disponible' : 'Agotado',
    );

    final productoIdCreado = await _productoService.crearProducto(nuevoProducto);
    if (productoIdCreado != null) {
      final productoCompleto = await _productoService.obtenerProductoPorId(productoIdCreado);
       
      if (productoCompleto != null) {
        return productoCompleto;
      } else {
        return Producto(
          productoId: productoIdCreado,
          marcaId: marca.marcaId,
          categoriaId: categoria.categoriaId,
          codigo: 0,
          nombreProducto: nombre,
          unidadMedida: 'UNIDAD',
          capacidadUnidad: 1,
          cantidad: cantidad,
          activo: true,
          fechaRegistro: DateTime.now(),
          marca: marca.nombreMarca,
          categoria: categoria.nombreCategoria,
          precioVenta: precioCompra * 1.3,
          costoCompra: precioCompra,
          margenGanancia: precioCompra * 0.3,
          porcentajeMargen: 30.0,
          estadoStock: cantidad > 0 ? 'Disponible' : 'Agotado',
        );
      }
    }
  return null;
  }
}