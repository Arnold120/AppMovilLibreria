import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:application_library/data/models/categoria_model.dart';
import 'package:application_library/ui/catalogos/logic/categoria_controller.dart';

@RoutePage()
class CategoriaPantalla extends StatefulWidget {
  static const String nombreRuta = 'categorias';
  const CategoriaPantalla({super.key});

  @override
  State<CategoriaPantalla> createState() => _CategoriaPantallaState();
}

class _CategoriaPantallaState extends State<CategoriaPantalla> {
  late final CategoriaController _controller;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CategoriaController();
    _controller.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onBuscar(String q) => _controller.filter(q);

  void _mostrarDetalle(Categoria c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.nombreCategoria),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv('Código', '${c.categoriaId}'),
            _kv('Activo', c.activo ? 'Sí' : 'No'),
            _kv('Registro', c.fechaRegistro.toLocal().toString().split(' ').first),
            const SizedBox(height: 8),
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(c.descripcion.isEmpty ? 'Sin descripción' : c.descripcion),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 28, 82, 229), Color.fromARGB(255, 25, 59, 195)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Gestión de Categorías',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => AutoRouter.of(context).maybePop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A00E0)));
          }
          if (_controller.error != null) {
            return Center(
              child: Text('Error al cargar categorías: ${_controller.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            );
          }

          final categorias = _controller.filtered;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _SearchBar(controller: _searchCtrl, onChanged: _onBuscar),
                const SizedBox(height: 12),
                if (categorias.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No hay categorías registradas.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowMinHeight: 56,
                        dataRowMaxHeight: 56,
                        headingRowHeight: 52,
                        columnSpacing: isMobile ? 12 : 20,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF1565C0)),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        dividerThickness: .5,
                        columns: isMobile
                            ? const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Acciones')),
                              ]
                            : const [
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Descripción')),
                                DataColumn(label: Text('Activo')),
                                DataColumn(label: Text('Registrada')),
                                DataColumn(label: Text('Acciones')),
                              ],
                        rows: List.generate(categorias.length, (index) {
                          final c = categorias[index];
                          final isEven = index.isEven;

                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.hovered)) {
                                return const Color(0xFFE3F2FD);
                              }
                              return isEven ? Colors.white : const Color(0xFFF7F9FB);
                            }),
                            onLongPress: () => _mostrarDetalle(c),
                            cells: isMobile
                                ? [
                                    DataCell(Text(
                                      c.nombreCategoria.length > 18
                                          ? '${c.nombreCategoria.substring(0, 18)}...'
                                          : c.nombreCategoria,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Row(
                                      children: [
                                        Icon(
                                          c.activo ? Icons.circle : Icons.circle_outlined,
                                          color: c.activo ? Colors.green : Colors.redAccent,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(c.activo ? 'Activo' : 'Inactivo',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF1E88E5), size: 18),
                                          onPressed: () async => _editarCategoria(c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFFE74C3C), size: 18),
                                          onPressed: () async => _eliminarCategoria(c),
                                        ),
                                      ],
                                    )),
                                  ]
                                : [
                                    DataCell(Text(
                                      c.nombreCategoria,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    DataCell(SizedBox(
                                      width: 260,
                                      child: Text(
                                        c.descripcion.isEmpty ? 'Sin descripción' : c.descripcion,
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                                    DataCell(Icon(
                                      c.activo ? Icons.check_circle : Icons.cancel,
                                      color: c.activo ? Colors.green : Colors.redAccent,
                                      size: 18,
                                    )),
                                    DataCell(Text(
                                      c.fechaRegistro.toLocal().toString().split(' ').first,
                                      style: const TextStyle(fontSize: 12),
                                    )),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF4A90E2), size: 18),
                                          onPressed: () async => _editarCategoria(c),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFFE74C3C), size: 18),
                                          onPressed: () async => _eliminarCategoria(c),
                                        ),
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
        label: const Text('Nueva Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _crearCategoria,
      ),
    );
  }

  Future<void> _crearCategoria() async {
    final nueva = await _dialogoCategoria(titulo: 'Nueva categoría');
    if (!mounted || nueva == null) return;
    final ok = await _controller.crear(nueva);
    if (!mounted) return;
    _toast(ok ? 'Categoría creada' : 'No se pudo crear', ok);
  }

  Future<void> _editarCategoria(Categoria original) async {
    final editada =
        await _dialogoCategoria(titulo: 'Editar categoría', categoriaInicial: original);
    if (!mounted || editada == null) return;

    final actualizada = Categoria(
      categoriaId: original.categoriaId,
      nombreCategoria: editada.nombreCategoria,
      descripcion: editada.descripcion,
      activo: editada.activo,
      fechaRegistro: original.fechaRegistro,
    );

    final ok = await _controller.actualizar(actualizada);
    if (!mounted) return;
    _toast(ok ? 'Categoría actualizada' : 'No se pudo actualizar', ok);
  }

  Future<void> _eliminarCategoria(Categoria categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Seguro que deseas eliminar "${categoria.nombreCategoria}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final ok = await _controller.eliminar(categoria.categoriaId);
    if (!mounted) return;
    _toast(ok ? 'Categoría eliminada' : 'No se pudo eliminar', ok);
  }

  Future<Categoria?> _dialogoCategoria({
    required String titulo,
    Categoria? categoriaInicial,
  }) async {
    final nombreCtrl = TextEditingController(text: categoriaInicial?.nombreCategoria ?? '');
    final descCtrl = TextEditingController(text: categoriaInicial?.descripcion ?? '');
    bool activo = categoriaInicial?.activo ?? true;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Categoria?>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(titulo),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.sell_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: Icon(Icons.description),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    SwitchListTile(
                      dense: true,
                      title: const Text('Activo'),
                      value: activo,
                      onChanged: (v) => setStateDialog(() => activo = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final now = DateTime.now();
                  final salida = Categoria(
                    categoriaId: categoriaInicial?.categoriaId ?? 0,
                    nombreCategoria: nombreCtrl.text.trim(),
                    descripcion: descCtrl.text.trim(),
                    activo: activo,
                    fechaRegistro: categoriaInicial?.fechaRegistro ?? now,
                  );
                  Navigator.pop(context, salida);
                },
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }

  void _toast(String msg, bool ok) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: ok ? Colors.green : Colors.redAccent),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 90, child: Text(k, style: const TextStyle(color: Colors.black54))),
            const Text(':  '),
            Expanded(child: Text(v, maxLines: 2, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            hintText: 'Buscar categoría...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: onChanged,
        ),
      ),
    );
  }
}