import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/catalogs_provider.dart';

/// Pantalla de gestión de catálogos (Carreras y Edificios).
class CatalogsPage extends ConsumerStatefulWidget {
  const CatalogsPage({super.key});

  @override
  ConsumerState<CatalogsPage> createState() => _CatalogsPageState();
}

class _CatalogsPageState extends ConsumerState<CatalogsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogsProvider);
    final notifier = ref.read(catalogsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Catálogos'),
        backgroundColor: AppColors.adminGreen,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.school_outlined), text: 'Carreras'),
            Tab(icon: Icon(Icons.business_outlined), text: 'Edificios'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  context: context,
                  items: state.careers,
                  emptyText: 'No hay carreras registradas',
                  onDelete: (career) async {
                    final confirm =
                        await _confirmDelete(context, 'carrera', career);
                    if (confirm == true) {
                      await notifier.removeCareer(career);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Carrera "$career" eliminada 🗑️'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: Icons.school,
                ),
                _buildList(
                  context: context,
                  items: state.buildings,
                  emptyText: 'No hay edificios registrados',
                  onDelete: (building) async {
                    final confirm =
                        await _confirmDelete(context, 'edificio', building);
                    if (confirm == true) {
                      await notifier.removeBuilding(building);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Edificio "$building" eliminado 🗑️'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  icon: Icons.business,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Carrera' : 'Edificio'),
        onPressed: () => _showAddDialog(context, notifier),
      ),
    );
  }

  Widget _buildList({
    required BuildContext context,
    required List<String> items,
    required String emptyText,
    required Function(String) onDelete,
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.adminGreen.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.adminGreen),
            ),
            title: Text(
              item,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Eliminar',
              onPressed: () => onDelete(item),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    String type,
    String name,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar $type?'),
        content: Text(
          '¿Estás seguro de eliminar "$name"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    CatalogsNotifier notifier,
  ) async {
    final isCareer = _tabController.index == 0;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCareer ? 'Nueva Carrera' : 'Nuevo Edificio'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: isCareer ? 'Sigla de carrera' : 'Nombre del edificio',
              hintText: isCareer ? 'Ej. IRO' : 'Ej. Edificio 5',
              prefixIcon: Icon(isCareer ? Icons.school : Icons.business),
            ),
            textCapitalization: isCareer
                ? TextCapitalization.characters
                : TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Este campo es requerido';
              }
              if (isCareer && v.trim().length > 5) {
                return 'Máximo 5 caracteres';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.adminGreen),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (isCareer) {
      await notifier.addCareer(result);
    } else {
      await notifier.addBuilding(result);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${isCareer ? 'Carrera' : 'Edificio'} "$result" agregado ✅',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
