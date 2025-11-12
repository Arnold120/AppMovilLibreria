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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _controller.filtrarMarcas(query);
      });
    });
  }

  // -----------------------
  // CREAR
  // -----------------------
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
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              formKey.currentState!.save();

              final nueva = Marca(
                marcaId: 0,
                nombreMarca: nombre,
                activo: activo,
                fechaRegistro: DateTime.now(),
              );

              try {
                final ok = await _controller.crearMarca(nueva);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(ok ? 'Marca creada' : 'Error al crear marca')));
                if (ok) {
                  setState(() {
                    _marcasFuture = _controller.refrescar();
                  });
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // -----------------------
  // EDITAR
  // -----------------------
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
          ElevatedButton(
            onPressed: () async {
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
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(ok ? 'Marca actualizada' : 'Error al actualizar')));
                if (ok) {
                  setState(() {
                    _marcasFuture = _controller.refrescar();
                  });
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // -----------------------
  // ELIMINAR
  // -----------------------
  Future<void> _confirmarEliminarMarca(Marca marca) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Marca'),
        content: Text('¿Seguro que deseas eliminar "${marca.nombreMarca}"?'),
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

    if (confirmar != true) return;

    try {
      final ok = await _controller.eliminarMarca(marca.marcaId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ok ? 'Marca eliminada' : 'Error al eliminar marca')));
      if (ok) {
        setState(() {
          _marcasFuture = _controller.refrescar();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
          ),
        ),
        title: const Text('Gestión de Marcas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => AutoRouter.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Marca>>(
        future: _marcasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _controller.marcas.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay marcas registradas.'));
          }

          if (_controller.marcas.isEmpty) {
            _controller.marcas = snapshot.data!;
            _controller.marcasFiltradas = List.from(_controller.marcas);
          }

          final marcasFiltradas = _controller.marcasFiltradas;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 🔎 Buscador
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        hintText: 'Buscar marca...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: _onBuscar,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 📋 Tabla con header fijo y scroll
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        // 🔝 Encabezado fijo
                        Container(
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A00E0),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Text('Nombre',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 44,
                                child: Center(
                                  child: Text('Activo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                width: 84,
                                child: Center(
                                  child: Text('Acciones',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 📜 Contenido desplazable
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(marcasFiltradas.length, (index) {
                                final m = marcasFiltradas[index];
                                final isEven = index % 2 == 0;
                                return Container(
                                  color: isEven ? Colors.white : const Color(0xFFF7F9FB),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          m.nombreMarca,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 44,
                                        child: Center(
                                          child: Icon(
                                            m.activo ? Icons.check_circle : Icons.cancel,
                                            color: m.activo ? Colors.green : Colors.redAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 84,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Color(0xFF6C63FF), size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                              onPressed: () => _abrirDialogoEditarMarca(m),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Color(0xFFE74C3C), size: 18),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                              onPressed: () => _confirmarEliminarMarca(m),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
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
        label: const Text("Nueva Marca", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _abrirDialogoCrearMarca,
      ),
    );
  }
}
