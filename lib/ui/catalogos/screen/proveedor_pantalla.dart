// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:application_library/ui/catalogos/logic/proveedor_controller.dart';
import 'package:application_library/data/models/proveedor_model.dart';

@RoutePage()
class PantallaProveedor extends StatelessWidget {
  static const String nombreRuta = 'proveedores';
  const PantallaProveedor({super.key});

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final controller = context.watch<ProveedorController>();

    if (!controller.cargando && controller.proveedoresFiltrados.isEmpty) {
      controller.cargarProveedores();
    }

    final proveedoresFiltrados = controller.proveedoresFiltrados;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB), appBar: AppBar(
          elevation: 2, backgroundColor: Colors.deepPurpleAccent,
          title: Text(
            'Gestión de Proveedores',
            style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white,
              fontSize: anchoPantalla >= 430 ? 22 : 20, letterSpacing: 0.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
        ),
        body: controller.cargando
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.deepPurpleAccent),
              )
            : proveedoresFiltrados.isEmpty
                ? const Center(
                    child: Text('No hay proveedores registrados.'),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: anchoPantalla >= 430 ? 16 : 14),
                            decoration: const InputDecoration(
                              hintText: 'Buscar proveedor...', prefixIcon:
                                Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onChanged: controller.filtrar,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth >= 430) {
                                return _tablaProveedores(proveedoresFiltrados);
                              } else {
                                return _listaProveedores(proveedoresFiltrados);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurpleAccent,icon: const 
          Icon(Icons.add),label: Text("Nuevo Proveedor",
              style: TextStyle(fontSize: anchoPantalla >= 430 ? 16 : 14)),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _tablaProveedores(List<Proveedor> lista) {
    return Card(
      elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: DataTable(
            columnSpacing: 32, headingRowColor:
               MaterialStateProperty.all(Colors.deepPurpleAccent),
            headingTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
            dataTextStyle: const TextStyle(fontSize: 15, color: Colors.black87),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Empresa')),
              DataColumn(label: Text('Dirección')),
              DataColumn(label: Text('Teléfono')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Devoluciones')),
              DataColumn(label: Text('Tiempo (días)')),
              DataColumn(label: Text('Cobertura %')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: lista.map((proveedor) {
              final index = lista.indexOf(proveedor);
              final esPar = index % 2 == 0;
              return DataRow(
                color: MaterialStateProperty.all(
                  esPar ? const Color(0xFFF8FAFC) : Colors.white),
                cells: [
                  DataCell(Text(proveedor.proveedorId.toString())),
                  DataCell(Text(proveedor.nombreEmpresa)),
                  DataCell(Text(proveedor.direccion)),
                  DataCell(Text(proveedor.telefono)),
                  DataCell(Text(proveedor.email)),
                  DataCell(Icon(
                    proveedor.aceptaDevoluciones ? Icons.check_circle : Icons.cancel, color:
                      proveedor.aceptaDevoluciones ? Colors.green : Colors.redAccent,
                  )),
                  DataCell(Text(proveedor.tiempoDevolucion.toString())),
                  DataCell(Text('${proveedor.porcentajeCobertura.toStringAsFixed(0)}%')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () {}),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {}),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _listaProveedores(List<Proveedor> lista) {
    return ListView.builder(
      itemCount: lista.length, itemBuilder: (context, index) {
        final proveedor = lista[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6), elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Padding(
            padding: const EdgeInsets.all(12), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(proveedor.nombreEmpresa,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Tel: ${proveedor.telefono}'),
                Text('Email: ${proveedor.email}'),
                Text('Dirección: ${proveedor.direccion}'),
                Text('Cobertura: ${proveedor.porcentajeCobertura.toStringAsFixed(0)}%'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Icon(
                      proveedor.aceptaDevoluciones ? Icons.check_circle : Icons.cancel,
                      color: proveedor.aceptaDevoluciones
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent), onPressed: () {}
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {}
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}