import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:application_library/data/models/cliente_model.dart';
import 'package:application_library/data/services/cliente_service.dart';

@RoutePage()
class ClientePantalla extends StatefulWidget {
  const ClientePantalla({super.key});

  @override
  State<ClientePantalla> createState() => _ClientePantallaState();
}

class _ClientePantallaState extends State<ClientePantalla> {
  final ClienteService _clienteService = ClienteService();
  late Future<List<Cliente>> _clientes;
  List<Cliente> _clientesFiltrados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() {
    _clientes = _clienteService.obtenerClientes();
    _clientes.then((data) => setState(() => _clientesFiltrados = data));
  }

  void _filtrarClientes(String query, List<Cliente> clientes) {
    setState(() {
      _busqueda = query;
      _clientesFiltrados = clientes
          .where((c) =>
              c.nombre.toLowerCase().contains(query.toLowerCase()) ||
              c.apellido.toLowerCase().contains(query.toLowerCase()) ||
              c.email.toLowerCase().contains(query.toLowerCase()) ||
              c.telefono.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.deepPurpleAccent,
          title: Text(
            'Gestión de Clientes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: anchoPantalla < 400 ? 18 : 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
        ),
        body: FutureBuilder<List<Cliente>>(
          future: _clientes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar clientes: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay clientes registrados.'));
            }

            final clientes = snapshot.data!;
            final clientesFiltrados = _busqueda.isEmpty
                ? _clientesFiltrados
                : _clientesFiltrados
                    .where((c) =>
                        c.nombre
                            .toLowerCase()
                            .contains(_busqueda.toLowerCase()) ||
                        c.apellido
                            .toLowerCase()
                            .contains(_busqueda.toLowerCase()))
                    .toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(fontSize: anchoPantalla < 380 ? 13 : 14),
                      decoration: const InputDecoration(
                        hintText: 'Buscar cliente...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _filtrarClientes(value, clientes),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Expanded(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: Colors.white,
                          child: Scrollbar(
                            thumbVisibility: true,
                            radius: const Radius.circular(8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minWidth: 900),
                                  child: DataTable(
                                    columnSpacing: anchoPantalla < 400 ? 16 : 20,
                                    headingRowColor: MaterialStateProperty.all(
                                        Colors.deepPurpleAccent),
                                    headingTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    dataTextStyle: const TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                    dividerThickness: 0.4,
                                    columns: const [
                                      DataColumn(label: Text('ID')),
                                      DataColumn(label: Text('Nombre')),
                                      DataColumn(label: Text('Apellido')),
                                      DataColumn(label: Text('Dirección')),
                                      DataColumn(label: Text('Teléfono')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(label: Text('Activo')),
                                      DataColumn(label: Text('Fecha Registro')),
                                      DataColumn(label: Text('Acciones')),
                                    ],
                                    rows: clientesFiltrados.map((c) {
                                      final index =
                                          clientesFiltrados.indexOf(c);
                                      final esPar = index % 2 == 0;

                                      return DataRow(
                                        color: MaterialStateProperty.all(
                                            esPar
                                                ? const Color(0xFFF8FAFC)
                                                : Colors.white),
                                        cells: [
                                          DataCell(
                                              Text(c.clienteId.toString())),
                                          DataCell(Text(c.nombre)),
                                          DataCell(Text(c.apellido)),
                                          DataCell(Text(c.direccion)),
                                          DataCell(Text(c.telefono)),
                                          DataCell(Text(c.email)),
                                          DataCell(Icon(
                                            c.activo
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: c.activo
                                                ? Colors.green
                                                : Colors.redAccent,
                                          )),
                                          DataCell(Text(
                                              "${c.fechaRegistro.day}/${c.fechaRegistro.month}/${c.fechaRegistro.year}")),
                                          DataCell(Row(
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
                                        ],
                                      );
                                    }).toList(),
                                  ),
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
          backgroundColor: Colors.deepPurpleAccent,
          icon: const Icon(Icons.add),
          label: const Text("Nuevo Cliente"),
          onPressed: () {},
        ),
      ),
    );
  }
}
