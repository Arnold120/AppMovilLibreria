// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/ui/catalogos/logic/marca_controller.dart';

@RoutePage()
class PantallaMarca extends StatefulWidget {
  static const String nombreRuta = 'marcas';
  const PantallaMarca({super.key});

  @override
  State<PantallaMarca> createState() => _PantallaMarcaState();
}

class _PantallaMarcaState extends State<PantallaMarca> {
  final MarcaController _controller = MarcaController();
  late Future<List<Marca>> _marcasFuture;

  @override
  void initState() {
    super.initState();
    _marcasFuture = _controller.cargarMarcas();
  }

  void _onBuscar(String query) {
    setState(() {
      _controller.filtrarMarcas(query);
    });
  }

  void _mostrarDetalleMarca(Marca marca) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                marca.nombreMarca,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
              
              _buildInfoRow("Activo", marca.activo ? "Sí" : "No", marca.activo ? Icons.check_circle : Icons.cancel),
              _buildInfoRow("Registro", marca.fechaRegistro.toLocal().toString().split(' ')[0], Icons.calendar_today),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A00E0)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
            ]),
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Gestión de Marcas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Marca>>(
        future: _marcasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar marcas: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay marcas registradas.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final marcasFiltradas = _controller.marcasFiltradas;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
              
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        hintText: 'Buscar marca...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: _onBuscar,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 50,
                      headingRowHeight: 50,
                      columnSpacing: isMobile ? 16 : 24,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFF4A00E0)),
                      headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      dividerThickness: 0.5,
                      columns: isMobile
                          ? const [
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Activo')),
                              DataColumn(label: Text('Acciones')),
                            ]
                          : const [
                             
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Activo')),
                              DataColumn(label: Text('Registro')),
                              DataColumn(label: Text('Acciones')),
                            ],
                      rows: List.generate(marcasFiltradas.length, (index) {
                        final m = marcasFiltradas[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.hovered)) return const Color(0xFFE8EAF6);
                            return isEven ? Colors.white : const Color(0xFFF7F9FB);
                          }),
                          onLongPress: () => _mostrarDetalleMarca(m),
                          cells: isMobile
                              ? [
                                  DataCell(Text(
                                    m.nombreMarca.length > 18 ? '${m.nombreMarca.substring(0, 18)}...' : m.nombreMarca,
                                    style: const TextStyle(fontSize: 12),
                                  )),
                                  DataCell(Icon(m.activo ? Icons.check_circle : Icons.cancel,
                                      color: m.activo ? Colors.green : Colors.redAccent, size: 18)),
                                  DataCell(Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.edit, color: Color(0xFF6C63FF), size: 18), onPressed: () {}),
                                      IconButton(icon: const Icon(Icons.delete, color: Color(0xFFE74C3C), size: 18), onPressed: () {}),
                                    ],
                                  )),
                                ]
                              : [
                              
                                  DataCell(Text(m.nombreMarca, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  DataCell(Icon(m.activo ? Icons.check_circle : Icons.cancel,
                                      color: m.activo ? Colors.green : Colors.redAccent, size: 18)),
                                  DataCell(Text(
                                    m.fechaRegistro.toLocal().toString().split(' ')[0],
                                    style: const TextStyle(fontSize: 12),
                                  )),
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
        label: const Text("Nueva Marca", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        onPressed: () {
          // Aquí luego conectamos un diálogo/forma para crear Marca usando MarcaService.crearMarca(...)
        },
      ),
    );
  }
}
