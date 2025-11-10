class Producto {
  final int productoId;
  final int marcaId;
  final int categoriaId;
  final int codigo;
  final String nombreProducto;
  final String unidadMedida;
  final int capacidadUnidad;
  final int cantidad;
  final bool activo;
  final DateTime fechaRegistro;
  final String marca;
  final String categoria;
  final double precioVenta;
  final double costoCompra;
  final double margenGanancia;
  final double porcentajeMargen;
  final String estadoStock;

  Producto({
    required this.productoId,
    required this.marcaId,
    required this.categoriaId,
    required this.codigo,
    required this.nombreProducto,
    required this.unidadMedida,
    required this.capacidadUnidad,
    required this.cantidad,
    required this.activo,
    required this.fechaRegistro,
    required this.marca,
    required this.categoria,
    required this.precioVenta,
    required this.costoCompra,
    required this.margenGanancia,
    required this.porcentajeMargen,
    required this.estadoStock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      productoId: json['producto_ID'] ?? 0,
      marcaId: json['marca_ID'] ?? 0,
      categoriaId: json['categoria_ID'] ?? 0,
      codigo: json['codigo'] ?? 0,
      nombreProducto: json['nombreProducto'] ?? '',
      unidadMedida: json['unidadMedida'] ?? '',
      capacidadUnidad: json['capacidadUnidad'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      activo: json['activo'] ?? true,
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      marca: json['marca'] ?? '',
      categoria: json['categoria'] ?? '',
      precioVenta: (json['precioVenta'] ?? 0).toDouble(),
      costoCompra: (json['costoCompra'] ?? 0).toDouble(),
      margenGanancia: (json['margenGanancia'] ?? 0).toDouble(),
      porcentajeMargen: (json['porcentajeMargen'] ?? 0).toDouble(),
      estadoStock: json['estadoStock'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_ID': productoId,
      'marca_ID': marcaId,
      'categoria_ID': categoriaId,
      'codigo': codigo,
      'nombreProducto': nombreProducto,
      'unidadMedida': unidadMedida,
      'capacidadUnidad': capacidadUnidad,
      'cantidad': cantidad,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'marca': marca,
      'categoria': categoria,
      'precioVenta': precioVenta,
      'costoCompra': costoCompra,
      'margenGanancia': margenGanancia,
      'porcentajeMargen': porcentajeMargen,
      'estadoStock': estadoStock,
    };
  }
}
