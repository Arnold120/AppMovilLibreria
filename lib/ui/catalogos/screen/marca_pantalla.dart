// lib/ui/catalogos/screen/marca_pantalla.dart
// ignore_for_file: deprecated_member_use
import 'dart:async';
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _marcasFuture = _controller.cargarMarcas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onBuscar(String query) {
    if (_controller.cargando) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _controller.filtrarMarcas(query);
      });
    });
  }

  Future<void> _abrirDialogoCrearMarca() async {
    final formKey = GlobalKey<FormState>();
    String nombre = '';
    bool activo = true;

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Marca'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre de la marca'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onSaved: (v) => nombre = v!.trim(),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (c, setC) {
              return SwitchListTile(
                title: const Text('Activo'),
                value: activo,
                onChanged: (v) => setC(() => activo = v),
              );
            }),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          StatefulBuilder(builder: (c, setC) {
            return ElevatedButton(
              onPressed: _controller.operando
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      formKey.currentState!.save();
                      final nueva = Marca(marcaId: 0, nombreMarca: nombre, activo: activo, fechaRegistro: DateTime.now());
                      try {
                        final ok = await _controller.crearMarca(nueva);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Marca creada' : 'No se pudo crear')));
                        if (ok) setState(() => _marcasFuture = _controller.refrescar());
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    },
              child: _controller.operando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Guardar'),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _abrirDialogoEditarMarca(Marca marca) async {
    final formKey = GlobalKey<FormState>();
    String nombre = marca.nombreMarca;
    bool activo = marca.activo;

    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Marca'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              initialValue: nombre,
              decoration: const InputDecoration(labelText: 'Nombre de la marca'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              onSaved: (v) => nombre = v!.trim(),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (c, setC) {
              return SwitchListTile(
                title: const Text('Activo'),
                value: activo,
                onChanged: (v) => setC(() => activo = v),
              );
            }),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          StatefulBuilder(builder: (c, setC) {
            return ElevatedButton(
              onPressed: _controller.operando
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      formKey.currentState!.save();
                      final actualizado = Marca(
                        marcaId: marca.marcaId,
                        nombreMarca: nombre,
                        activo: activo,
                        fechaRegistro: marca.fechaRegistro,
                      );
                      try {
                        final ok = await _controller.actualizarMarca(actualizado);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Marca actualizada' : 'No se pudo actualizar')));
                        if (ok) setState(() => _marcasFuture = _controller.refrescar());
                      } catch (e) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    },
              child: _controller.operando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Guardar'),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarMarca(Marca marca) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar la marca "${marca.nombreMarca}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe74c3c)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final ok = await _controller.eliminarMarca(marca.marcaId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Marca eliminada' : 'No se pudo eliminar')));
        if (ok) setState(() => _marcasFuture = _controller.refrescar());
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(marca.nombreMarca, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            _buildInfoRow("Activo", marca.activo ? "Sí" : "No", marca.activo ? Icons.check_circle : Icons.cancel),
            _buildInfoRow("Registro", marca.fechaRegistro.toLocal().toString().split(' ')[0], Icons.calendar_today),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
          ]),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(icon, size: 20, color: const Color(0xFF4A00E0)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
        ]))
      ]),
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
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]))),
        title: const Text('Gestión de Marcas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => AutoRouter.of(context).pop()),
      ),
      body: FutureBuilder<List<Marca>>(
        future: _marcasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _controller.marcas.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }
          if (snapshot.hasError) {
            final err = snapshot.error.toString();
            return Center(child: Text('Error al cargar marcas: $err', style: const TextStyle(color: Colors.redAccent)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay marcas registradas.', style: TextStyle(color: Colors.grey)));
          }

          if (_controller.marcas.isEmpty) {
            _controller.marcas = snapshot.data!;
            _controller.marcasFiltradas = List.from(_controller.marcas);
          }

          final marcasFiltradas = _controller.marcasFiltradas;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Center(
                  child: TextField(decoration: const InputDecoration(hintText: 'Buscar marca...', prefixIcon: Icon(Icons.search, color: Colors.grey), border: InputBorder.none), onChanged: _onBuscar),
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
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    columns: isMobile
                        ? const [DataColumn(label: Text('Nombre')), DataColumn(label: Text('Activo')), DataColumn(label: Text('Acciones'))]
                        : const [DataColumn(label: Text('Nombre')), DataColumn(label: Text('Activo')), DataColumn(label: Text('Registro')), DataColumn(label: Text('Acciones'))],
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
                                DataCell(Text(m.nombreMarca.length > 18 ? '${m.nombreMarca.substring(0, 18)}...' : m.nombreMarca)),
                                DataCell(Icon(m.activo ? Icons.check_circle : Icons.cancel, color: m.activo ? Colors.green : Colors.redAccent)),
                                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6C63FF)), onPressed: () => _abrirDialogoEditarMarca(m)),
                                  IconButton(icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE74C3C)), onPressed: () => _confirmarEliminarMarca(m)),
                                ])),
                              ]
                            : [
                                DataCell(Text(m.nombreMarca, overflow: TextOverflow.ellipsis)),
                                DataCell(Icon(m.activo ? Icons.check_circle : Icons.cancel, color: m.activo ? Colors.green : Colors.redAccent)),
                                DataCell(Text(m.fechaRegistro.toLocal().toString().split(' ')[0])),
                                DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(icon: const Icon(Icons.edit, size: 18, color: Color(0xFF6C63FF)), onPressed: () => _abrirDialogoEditarMarca(m)),
                                  IconButton(icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE74C3C)), onPressed: () => _confirmarEliminarMarca(m)),
                                ])),
                              ],
                      );
                    }),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF27AE60),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Marca", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _abrirDialogoCrearMarca(),
      ),
    );
  }
}
