class Venta {
  final int ventaId;
  final int usuarioId;
  final int? clienteId;
  final DateTime fechaVenta;
  final int cantidadTotal;
  final double subTotal;
  final double descuento;
  final double iva;
  final double total;
  final String estado;
  final String? clienteNombre;

  Venta({
    required this.ventaId,
    required this.usuarioId,
    this.clienteId,
    required this.fechaVenta,
    required this.cantidadTotal,
    required this.subTotal,
    required this.descuento,
    required this.iva,
    required this.total,
    required this.estado,
    this.clienteNombre,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
  DateTime asDate(dynamic v) =>
      DateTime.tryParse((v ?? '').toString()) ?? DateTime.now();
  double asDouble(dynamic v) => (v == null) ? 0.0 : (v as num).toDouble();
  int asInt(dynamic v) => (v == null) ? 0 : (v as num).toInt();

  return Venta(
    ventaId: asInt(json['venta_ID'] ?? json['Venta_ID'] ?? json['ventaId']),
    usuarioId: asInt(json['usuario_ID'] ?? json['Usuario_ID'] ?? json['usuarioId']),
    clienteId: json['cliente_ID'] ?? json['Cliente_ID'] ?? json['clienteId'],
    fechaVenta: asDate(json['fechaVenta'] ?? json['FechaVenta']),
    cantidadTotal: asInt(json['cantidadTotal'] ?? json['CantidadTotal'] ?? json['cantidad']),
    subTotal: asDouble(json['subTotal'] ?? json['SubTotal']),
    descuento: asDouble(json['descuento'] ?? json['Descuento']),
    iva: asDouble(json['iva'] ?? json['IVA']),
    total: asDouble(json['total'] ?? json['Total']),
    estado: (json['estado'] ?? json['Estado'] ?? 'Activo').toString(),
    clienteNombre: json['clienteNombre'] ??
        (json['cliente_ID'] != null ? 'Cliente ${json['cliente_ID']}' : null),
  );
}

  Map<String, dynamic> toJson() => {
        'venta_ID': ventaId,
        'usuario_ID': usuarioId,
        'cliente_ID': clienteId,
        'fechaVenta': fechaVenta.toIso8601String(),
        'cantidadTotal': cantidadTotal,
        'subTotal': subTotal,
        'descuento': descuento,
        'iva': iva,
        'total': total,
        'estado': estado,
      };
}

class DetalleVenta {
  final int detalleVentaId;
  final int ventaId;
  final int productoId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final double subTotal;
  final double iva;
  final double total;
  final String tipoComprobante;

  DetalleVenta({
    required this.detalleVentaId,
    required this.ventaId,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subTotal,
    required this.iva,
    required this.total,
    required this.tipoComprobante,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
  double asDouble(dynamic v) => (v == null) ? 0.0 : (v as num).toDouble();
  int asInt(dynamic v) => (v == null) ? 0 : (v as num).toInt();

  final pid = asInt(json['producto_ID'] ?? json['Producto_ID'] ?? json['productoId']);

  return DetalleVenta(
    detalleVentaId:
        asInt(json['detalleVenta_ID'] ?? json['DetalleVenta_ID'] ?? json['detalleVentaId']),
    ventaId: asInt(json['venta_ID'] ?? json['Venta_ID'] ?? json['ventaId']),
    productoId: pid,
    productoNombre: json['productoNombre'] ?? 'Producto $pid',
    cantidad: asInt(json['cantidad'] ?? json['Cantidad']),
    precioUnitario: asDouble(json['precioUnitario'] ?? json['PrecioUnitario']),
    subTotal: asDouble(json['subTotal'] ?? json['SubTotal']),
    iva: asDouble(json['iva'] ?? json['IVA']),
    total: asDouble(json['total'] ?? json['Total']),
    tipoComprobante:
        (json['tipoComprobante'] ?? json['TipoComprobante'] ?? 'Factura').toString(),
  );
}
  Map<String, dynamic> toJson() => {
        'detalleVenta_ID': detalleVentaId,
        'venta_ID': ventaId,
        'producto_ID': productoId,
        'productoNombre': productoNombre,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'subTotal': subTotal,
        'iva': iva,
        'total': total,
        'tipoComprobante': tipoComprobante,
      };
}

class VentaRequest {
  final int? clienteId;            
  final double montoRecibido;
  final double descuento;
  final List<DetalleVentaRequest> detallesVenta;

  const VentaRequest({
    required this.clienteId,
    required this.montoRecibido,
    required this.descuento,
    required this.detallesVenta,
  });

  Map<String, dynamic> toJson() => {
        'cliente_ID': clienteId,
        'montoRecibido': montoRecibido,
        'descuento': descuento,
        'detallesVenta': detallesVenta.map((e) => e.toJson()).toList(),
      };
}

class DetalleVentaRequest {
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double iva;               
  final String tipoComprobante;     

  const DetalleVentaRequest({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    this.iva = 0.0,
    this.tipoComprobante = 'Factura',
  });

  Map<String, dynamic> toJson() => {
        'producto_ID': productoId,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'iva': iva,
        'tipoComprobante': tipoComprobante,
      };
}