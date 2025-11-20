class Compra {
  final int compraId;
  final int usuarioId;
  final int proveedorId;
  final DateTime fechaRegistro;
  final int cantidadTotal;
  final double subTotal;
  final double ivaTotal;
  final double montoTotal;
  final double total;
  final String? proveedorNombre;

  Compra({
    required this.compraId,
    required this.usuarioId,
    required this.proveedorId,
    required this.fechaRegistro,
    required this.cantidadTotal,
    required this.subTotal,
    required this.ivaTotal,
    required this.montoTotal,
    required this.total,
    this.proveedorNombre,
  });

  factory Compra.fromJson(Map<String, dynamic> json) {
    DateTime asDate(dynamic v) =>
        DateTime.tryParse((v ?? '').toString()) ?? DateTime.now();
    double asDouble(dynamic v) => (v == null) ? 0.0 : (v as num).toDouble();
    int asInt(dynamic v) => (v == null) ? 0 : (v as num).toInt();

    return Compra(
      compraId: asInt(json['compra_ID'] ?? json['Compra_ID'] ?? json['compraId']),
      usuarioId: asInt(json['usuario_ID'] ?? json['Usuario_ID'] ?? json['usuarioId']),
      proveedorId: asInt(json['proveedor_ID'] ?? json['Proveedor_ID'] ?? json['proveedorId']),
      fechaRegistro: asDate(json['fechaRegistro'] ?? json['FechaRegistro']),
      cantidadTotal: asInt(json['cantidadTotal'] ?? json['CantidadTotal'] ?? json['cantidad']),
      subTotal: asDouble(json['subTotal'] ?? json['SubTotal']),
      ivaTotal: asDouble(json['ivaTotal'] ?? json['IVATotal'] ?? json['iva']),
      montoTotal: asDouble(json['montoTotal'] ?? json['MontoTotal']),
      total: asDouble(json['total'] ?? json['Total']),
      proveedorNombre: json['proveedorNombre'] ??
          (json['proveedor_ID'] != null ? 'Proveedor ${json['proveedor_ID']}' : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'compra_ID': compraId,
        'usuario_ID': usuarioId,
        'proveedor_ID': proveedorId,
        'fechaRegistro': fechaRegistro.toIso8601String(),
        'cantidadTotal': cantidadTotal,
        'subTotal': subTotal,
        'ivaTotal': ivaTotal,
        'montoTotal': montoTotal,
        'total': total,
      };
}

class DetalleCompra {
  final int detalleCompraId;
  final int compraId;
  final int productoId;
  final String productoNombre;
  final int cantidadUnitaria;
  final double precioUnitario;
  final double montoUnitario;
  final double iva;
  final double total;

  DetalleCompra({
    required this.detalleCompraId,
    required this.compraId,
    required this.productoId,
    required this.productoNombre,
    required this.cantidadUnitaria,
    required this.precioUnitario,
    required this.montoUnitario,
    required this.iva,
    required this.total,
  });

  factory DetalleCompra.fromJson(Map<String, dynamic> json) {
    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    final detalle = DetalleCompra(
      detalleCompraId: safeInt(json['detalleCompra_ID'] ?? json['detalleCompraId']),
      compraId: safeInt(json['compra_ID'] ?? json['compraId']),
      productoId: safeInt(json['producto_ID'] ?? json['productoId']),
      productoNombre: json['productoNombre'] ?? 'Producto',
      cantidadUnitaria: safeInt(json['cantidadUnitaria']),
      precioUnitario: safeDouble(json['precioUnitario']),
      montoUnitario: safeDouble(json['montoUnitario']),
      iva: safeDouble(json['iva']),
      total: safeDouble(json['total']),
    );
    
    return detalle;
  }

  Map<String, dynamic> toJson() => {
        'detalleCompra_ID': detalleCompraId,
        'compra_ID': compraId,
        'producto_ID': productoId,
        'productoNombre': productoNombre,
        'cantidadUnitaria': cantidadUnitaria,
        'precioUnitario': precioUnitario,
        'montoUnitario': montoUnitario,
        'iva': iva,
        'total': total,
      };
}

class CompraRequest {
  final int proveedorId;
  final DateTime fechaRegistro;
  final List<DetalleCompraRequest> detallesCompra;

  const CompraRequest({
    required this.proveedorId,
    required this.fechaRegistro,
    required this.detallesCompra,
  });

  Map<String, dynamic> toJson() => {
        'proveedor_ID': proveedorId,
        'fechaRegistro': fechaRegistro.toIso8601String(),
        'detallesCompra': detallesCompra.map((e) => e.toJson()).toList(),
      };
}

class DetalleCompraRequest {
  final int productoId;
  final int cantidadUnitaria;
  final double precioUnitario;
  final double iva;

  const DetalleCompraRequest({
    required this.productoId,
    required this.cantidadUnitaria,
    required this.precioUnitario,
    required this.iva,
  });

  Map<String, dynamic> toJson() => {
        'producto_ID': productoId,
        'cantidadUnitaria': cantidadUnitaria,
        'precioUnitario': precioUnitario,
        'iva': iva,
      };
}