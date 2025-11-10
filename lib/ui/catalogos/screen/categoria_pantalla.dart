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
  late final CategoriaController controller;

  @override
  void initState() {
    super.initState();
    controller = CategoriaController();
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
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
          onPressed: () => AutoRouter.of(context).maybePop(),
        ),
      ),

      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A00E0)),
            );
          }

          if (controller.error != null) {
            return Center(
              child: Text(
                'Error al cargar categorías: ${controller.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _SearchBar(onChanged: controller.filter),
                const SizedBox(height: 16),

                if (controller.filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No hay categorías registradas.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final c = controller.filtered[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E5CA9).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.sell_rounded, color: Color(0xFF1E5CA9)),
                            ),
                            title: Text(
                              c.nombreCategoria,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                c.descripcion.isEmpty ? 'Sin descripción' : c.descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'editar') {
                                  await _editarCategoria(context, c);
                                } else if (value == 'eliminar') {
                                  await _eliminarCategoria(context, c);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18),
                                      SizedBox(width: 8),
                                      Text('Eliminar'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // si deseas abrir detalle, aquí
                            },
                          ),
                        );
                      },
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
        label: const Text("Nueva Categoría", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _crearCategoria(context),
      ),
    );
  }

  Future<void> _crearCategoria(BuildContext context) async {
    final nueva = await _dialogoCategoria(
      context,
      titulo: 'Nueva categoría',
      categoriaInicial: null,
    );
    if (!mounted || nueva == null) return;

    final ok = await controller.crear(nueva);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Categoría creada' : 'No se pudo crear'),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _editarCategoria(BuildContext context, Categoria original) async {
    final editada = await _dialogoCategoria(
      context,
      titulo: 'Editar categoría',
      categoriaInicial: original,
    );
    if (!mounted || editada == null) return;

    final actualizada = Categoria(
      categoriaId: original.categoriaId,
      nombreCategoria: editada.nombreCategoria,
      descripcion: editada.descripcion,
      activo: editada.activo,
      fechaRegistro: original.fechaRegistro,
    );

    final ok = await controller.actualizar(actualizada);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Categoría actualizada' : 'No se pudo actualizar'),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _eliminarCategoria(BuildContext context, Categoria categoria) async {
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final ok = await controller.eliminar(categoria.categoriaId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Categoría eliminada' : 'No se pudo eliminar'),
        backgroundColor: ok ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<Categoria?> _dialogoCategoria(
    BuildContext context, {
    required String titulo,
    Categoria? categoriaInicial,
  }) async {
    final nombreCtrl = TextEditingController(text: categoriaInicial?.nombreCategoria ?? '');
    final descCtrl   = TextEditingController(text: categoriaInicial?.descripcion ?? '');
    bool activo      = categoriaInicial?.activo ?? true;

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
                width: 320,
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
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text('Activo'),
                      value: activo,
                      onChanged: (v) => setStateDialog(() => activo = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
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
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    return result;
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        onChanged: onChanged,
      ),
    );
  }
}