import 'package:application_library/data/models/categoria.model.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/data/services/categoria_service.dart';

@RoutePage()
class CategoriaPantalla extends StatefulWidget {
  const CategoriaPantalla({super.key});

  @override
  State<CategoriaPantalla> createState() => _CategoriaPantallaState();
}

class _CategoriaPantallaState extends State<CategoriaPantalla> {
  final CategoriaService _categoriaService = CategoriaService();
  late Future<List<Categoria>> _categorias;
  List<Categoria> _categoriasFiltradas = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() {
    _categorias = _categoriaService.obtenerCategorias();
    _categorias.then((data) => setState(() => _categoriasFiltradas = data));
  }

  void _filtrarCategorias(String query, List<Categoria> categorias) {
    setState(() {
      _busqueda = query;
      _categoriasFiltradas = categorias
          .where((c) =>
              c.nombreCategoria.toLowerCase().contains(query.toLowerCase()))
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
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
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
          'Gestión de Categorías',
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
      body: FutureBuilder<List<Categoria>>(
        future: _categorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar categorías: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay categorías registradas.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final categorias = snapshot.data!;
          final categoriasFiltradas = _busqueda.isEmpty
              ? _categoriasFiltradas
              : _categoriasFiltradas
                  .where((c) =>
                      c.nombreCategoria
                          .toLowerCase()
                          .contains(_busqueda.toLowerCase()))
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar categoría...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _filtrarCategorias(value, categorias),
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
                              colors: [Color(0xFFFBFCFC), Color(0xFFF0F3F4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowMinHeight: 68,
                                dataRowMaxHeight: 68,
                                headingRowHeight: 56,
                                columnSpacing: isMobile ? 12 : 28,
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFF4A00E0),
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
                                rows: List.generate(categoriasFiltradas.length,
                                    (index) {
                                  final categoria = categoriasFiltradas[index];
                                  final isEven = index % 2 == 0;

                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>(
                                      (states) {
                                        if (states.contains(WidgetState.hovered)) {
                                          return const Color(0xFFE8EAF6);
                                        }
                                        return isEven
                                            ? Colors.white
                                            : const Color(0xFFF7F9FB);
                                      },
                                    ),
                                    cells: isMobile
                                        ? [
                                            DataCell(Text(
                                              categoria.categoriaId.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            )),
                                            DataCell(Text(
                                              categoria.nombreCategoria,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            )),
                                            DataCell(Icon(
                                              categoria.activo
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: categoria.activo
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
                                              categoria.categoriaId.toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            DataCell(Text(
                                              categoria.nombreCategoria,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            )),
                                            DataCell(Icon(
                                              categoria.activo
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: categoria.activo
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                            )),
                                            DataCell(Text(
                                              '${categoria.fechaRegistro.day}/${categoria.fechaRegistro.month}/${categoria.fechaRegistro.year}',
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            )),
                                            DataCell(Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Tooltip(
                                                  message:
                                                      'Editar categoría',
                                                  child: IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color:
                                                            Color(0xFF6C63FF)),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                                Tooltip(
                                                  message:
                                                      'Eliminar categoría',
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color:
                                                            Color(0xFFE74C3C)),
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
          "Nueva Categoría",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {},
      ),
    );
  }
}