import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/data/models/marca_model.dart';
import 'package:application_library/data/services/marca_service.dart';

@RoutePage()
class MarcaPantalla extends StatefulWidget {
  const MarcaPantalla({super.key});

  @override
  State<MarcaPantalla> createState() => _MarcaPantallaState();
}

class _MarcaPantallaState extends State<MarcaPantalla> {
  final MarcaService _marcaService = MarcaService();
  late Future<List<Marca>> _marcas;
  List<Marca> _marcasFiltradas = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarMarcas();
  }

  void _cargarMarcas() {
    _marcas = _marcaService.obtenerMarcas();
    _marcas.then((data) => setState(() => _marcasFiltradas = data));
  }

  void _filtrarMarcas(String query, List<Marca> marcas) {
    setState(() {
      _busqueda = query;
      _marcasFiltradas = marcas
          .where((m) => m.nombreMarca.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
              colors: [Color.fromARGB(255, 45, 116, 164), Color.fromARGB(255, 95, 194, 231)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: const Text(
          'Gestión de Marcas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Marca>>(
        future: _marcas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2980B9),
              ),
            );
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
              child: Text(
                'No hay marcas registradas.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final marcas = snapshot.data!;
          final marcasFiltradas = _busqueda.isEmpty
              ? _marcasFiltradas
              : _marcasFiltradas
                  .where((m) =>
                      m.nombreMarca.toLowerCase().contains(_busqueda.toLowerCase()))
                  .toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar marca...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _filtrarMarcas(value, marcas),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFECF0F1), Color(0xFFFFFFFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowHeight: 64,
                                headingRowHeight: 56,
                                columnSpacing: isMobile ? 12 : 28,
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFF2980B9),
                                ),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                dividerThickness: 0.5,
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 0.5,
                                  ),
                                ),
                                columns: isMobile
                                    ? const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Nombre')),
                                        DataColumn(label: Text('Activo')),
                                        DataColumn(label: Text('Acciones')),
                                      ]
                                    : const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Nombre')),
                                        DataColumn(label: Text('Activo')),
                                        DataColumn(label: Text('Fecha Registro')),
                                        DataColumn(label: Text('Acciones')),
                                      ],
                                rows: List.generate(marcasFiltradas.length, (index) {
                                  final marca = marcasFiltradas[index];
                                  final isEven = index % 2 == 0;

                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states.contains(WidgetState.hovered)) {
                                          return Colors.blue.shade50;
                                        }
                                        return isEven
                                            ? Colors.white
                                            : const Color(0xFFF8FAFC);
                                      },
                                    ),
                                    cells: isMobile
                                        ? [
                                            DataCell(Text(
                                              marca.marcaId.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            )),
                                            DataCell(Text(
                                              marca.nombreMarca,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            )),
                                            DataCell(Icon(
                                              marca.activo
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: marca.activo
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                            )),
                                            DataCell(Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.edit,
                                                      color: Colors.blueAccent),
                                                  tooltip: 'Editar',
                                                  onPressed: () {},
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.redAccent),
                                                  tooltip: 'Eliminar',
                                                  onPressed: () {},
                                                ),
                                              ],
                                            )),
                                          ]
                                        : [
                                            DataCell(Text(
                                              marca.marcaId.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataCell(Text(
                                              marca.nombreMarca,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            )),
                                            DataCell(Icon(
                                              marca.activo
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: marca.activo
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                            )),
                                            DataCell(Text(
                                              '${marca.fechaRegistro.day}/${marca.fechaRegistro.month}/${marca.fechaRegistro.year}',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            )),
                                            DataCell(Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Tooltip(
                                                  message: 'Editar marca',
                                                  child: IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Color(0xFF3498DB)),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Eliminar marca',
                                                  child: IconButton(
                                                    icon: const Icon(Icons.delete,
                                                        color: Color(0xFFE74C3C)),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
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
          "Nueva Marca",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      ),
    );
  }
}
