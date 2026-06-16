import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../exams/domain/entities/exam.dart';
import '../../../exams/presentation/providers/exams_notifier.dart';
import 'exam_form_page.dart';

/// Pantalla de gestión completa de ETS (lista + acciones CRUD).
class ExamsManagementPage extends ConsumerWidget {
  const ExamsManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examsProvider);
    final notifier = ref.read(examsProvider.notifier);
    final dateFormat = DateFormat('d MMM y · h:mm a', 'es_MX');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar ETS'),
        backgroundColor: AppColors.adminGreen,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.adminGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExamFormPage()),
          );
        },
      ),
      body: state.isLoading && state.exams.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.exams.length,
              itemBuilder: (context, index) {
                final exam = state.exams[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.adminGreen.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.adminGreen,
                      ),
                    ),
                    title: Text(
                      exam.subject,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${exam.careerCode} · Sem ${exam.semester}°',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          dateFormat.format(exam.date),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${exam.building} · Salón ${exam.classroom}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (action) {
                        if (action == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExamFormPage(examToEdit: exam),
                            ),
                          );
                        } else if (action == 'delete') {
                          _confirmDelete(context, ref, exam, notifier);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Exam exam,
    dynamic notifier,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar ETS?'),
        content: Text(
          '¿Estás seguro de eliminar "${exam.subject}"? Esta acción no se puede deshacer.',
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

    if (confirm == true) {
      final success = await notifier.deleteExam(exam.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'ETS eliminado 🗑️' : 'Error al eliminar',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}