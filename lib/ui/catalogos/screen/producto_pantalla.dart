// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/data/models/producto_model.dart';
import 'package:application_library/ui/catalogos/logic/producto_controller.dart';

@RoutePage()
class PantallaProducto extends StatefulWidget {
  static const String nombreRuta = 'productos';
  const PantallaProducto({super.key});

  @override
  State<PantallaProducto> createState() => _PantallaProductoState();
}

class _PantallaProductoState extends State<PantallaProducto> {
  final ProductoController _controller = ProductoController();
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _controller.cargarProductos();
  }

  void _onBuscar(String query) {
    setState(() {
      _controller.filtrarProductos(query);
    });
  }

  void _mostrarDetalleProducto(Producto producto) {
    showDialog(
      context: context, barrierDismissible: true, builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5, backgroundColor: Colors.white,child: Container(
          padding: const EdgeInsets.all(16), constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500), 
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, children: [
                Text(
                  producto.nombreProducto, style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12), Divider(color: Colors.grey[300]), const SizedBox(height: 12),
                Wrap(
                  spacing: 10, runSpacing: 10, children: [
                    _buildInfoCard("Código", producto.codigo.toString(), Icons.qr_code),
                    _buildInfoCard("Marca", producto.marca, Icons.branding_watermark),
                    _buildInfoCard("Categoría", producto.categoria, Icons.category),
                    _buildInfoCard("Unidad", producto.unidadMedida, Icons.straighten),
                    _buildInfoCard("Capacidad", producto.capacidadUnidad.toString(), Icons.scale),
                    _buildInfoCard("Cantidad", producto.cantidad.toString(), Icons.inventory_2),
                    _buildInfoCard("Precio venta", "\$${producto.precioVenta.toStringAsFixed(2)}", Icons.attach_money),
                    _buildInfoCard("Costo compra", "\$${producto.costoCompra.toStringAsFixed(2)}", Icons.money_off),
                    _buildInfoCard("Margen", "\$${producto.margenGanancia.toStringAsFixed(2)}", Icons.trending_up),
                    _buildInfoCard("Porcentaje", "${producto.porcentajeMargen.toStringAsFixed(2)}%", Icons.percent),
                    _buildInfoCard("Activo", producto.activo ? "Sí" : "No", producto.activo ? Icons.check_circle : Icons.cancel),
                    _buildInfoCard("Stock", producto.estadoStock, producto.estadoStock == "Disponible" ? Icons.check_circle_outline : Icons.warning),
                    _buildInfoCard("Registro", producto.fechaRegistro.toLocal().toString().split(' ')[0], Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: 170, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100], borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A00E0)), const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 4),
                Text(value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Gestión de Productos',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Producto>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar productos: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos registrados.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final productosFiltrados = _controller.productosFiltrados;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        hintText: 'Buscar producto...', prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14), onChanged: _onBuscar,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 50, headingRowHeight: 50, columnSpacing: isMobile ? 10 : 20,
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF4A00E0),
                      ),
                      headingTextStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
                      ),
                      dividerThickness: 0.5, columns: isMobile
                        ? const [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('Cant / Precio')),
                          DataColumn(label: Text('Acciones')),
                        ]
                        : const [
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Marca')),
                            DataColumn(label: Text('Categoría')),
                            DataColumn(label: Text('Cantidad')),
                            DataColumn(label: Text('Precio')),
                            DataColumn(label: Text('Stock')),
                            DataColumn(label: Text('Activo')),
                            DataColumn(label: Text('Acciones')),
                        ],
                      rows: List.generate(productosFiltrados.length, (index) {
                        final producto = productosFiltrados[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(MaterialState.hovered)) {
                                return const Color(0xFFE8EAF6);
                              }
                              return isEven ? Colors.white : const Color(0xFFF7F9FB);
                            },
                          ),
                          onLongPress: () => _mostrarDetalleProducto(producto),
                          cells: isMobile
                              ? [
                                  DataCell(Text(
                                    producto.nombreProducto.length > 15
                                        ? '${producto.nombreProducto.substring(0, 15)}...'
                                        : producto.nombreProducto, style: const TextStyle(fontSize: 12),
                                  )),
                                  DataCell(
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cant: ${producto.cantidad}', style: const TextStyle(fontSize: 12),
                                            ),
                                            Text(
                                              'Precio: \$${producto.precioVenta.toStringAsFixed(2)}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          producto.activo ? Icons.circle : Icons.circle_outlined,
                                          color: producto.activo ? Colors.green : Colors.redAccent, size: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                        onPressed: () {},
                                      ),
                                    ],
                                  )),
                                ]
                              : [
                                  DataCell(Text(producto.nombreProducto, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  DataCell(Text(producto.marca, style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(producto.categoria, style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(producto.cantidad.toString(), style: const TextStyle(fontSize: 12))),
                                  DataCell(Text('\$${producto.precioVenta.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(producto.estadoStock, style: const TextStyle(fontSize: 12))),
                                  DataCell(Icon(producto.activo ? Icons.check_circle : Icons.cancel, color: producto.activo ? Colors.green : Colors.redAccent, size: 18)),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF6C63FF), size: 18), onPressed: () {}),
                                      IconButton(icon: const Icon(Icons.delete, color: Color(0xFFE74C3C), size: 18), onPressed: () {}),
                                    ],
                                  )),
                                ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF27AE60),
        icon: const Icon(Icons.add),
        label: const Text(
          "Nuevo Producto",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        onPressed: () {},
      ),
    );
  }
}
