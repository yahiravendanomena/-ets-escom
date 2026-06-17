import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/exam.dart';
import '../providers/exams_notifier.dart';

/// Pantalla de detalle de un ETS.
class ExamDetailPage extends ConsumerWidget {
  final Exam exam;

  const ExamDetailPage({super.key, required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examsProvider);
    final notifier = ref.read(examsProvider.notifier);
    final isFavorite = state.favoriteIds.contains(exam.id);

    final dateFormat = DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_MX');
    final timeFormat = DateFormat('h:mm a', 'es_MX');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del ETS'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline,
              color: isFavorite ? Colors.amber : Colors.white,
            ),
            tooltip: isFavorite ? 'Quitar favorito' : 'Marcar favorito',
            onPressed: () {
              notifier.toggleFavorite(exam.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Eliminado de favoritos'
                        : 'Agregado a favoritos ⭐',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.guindaIpn,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con Hero animation (vuela desde la card).
                  Hero(
                    tag: 'exam-title-${exam.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        exam.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTag(exam.careerCode),
                      const SizedBox(width: 8),
                      _buildTag('Semestre ${exam.semester}°'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailCard(
                    icon: Icons.calendar_today_rounded,
                    title: 'Fecha',
                    value: dateFormat.format(exam.date),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.access_time_rounded,
                          title: 'Hora',
                          value: timeFormat.format(exam.date),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Turno',
                          value: exam.shift.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.location_on_outlined,
                    title: 'Ubicación',
                    value: '${exam.building} · Salón ${exam.classroom}',
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.map_outlined,
                        color: AppColors.guindaIpn,
                      ),
                      tooltip: 'Ver en mapa',
                      onPressed: () => _openMap(context, exam),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.person_outline,
                    title: 'Profesor evaluador',
                    value: exam.professor,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showComingSoon(context, 'PDF'),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _addToCalendar(context, exam),
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: const Text('Calendario'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleReminder(context, exam),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Programar recordatorio'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _openMap(BuildContext context, Exam exam) async {
    final query = Uri.encodeComponent('ESCOM IPN ${exam.building}');
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el mapa')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _scheduleReminder(BuildContext context, Exam exam) async {
    if (exam.date.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este examen ya pasó')),
      );
      return;
    }

    final int? hoursBefore = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '¿Cuándo quieres el recordatorio?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('1 hora antes'),
                onTap: () => Navigator.pop(ctx, 1),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('1 día antes'),
                onTap: () => Navigator.pop(ctx, 24),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('3 días antes'),
                onTap: () => Navigator.pop(ctx, 72),
              ),
            ],
          ),
        );
      },
    );

    if (hoursBefore == null) return;

    final scheduledDate = exam.date.subtract(Duration(hours: hoursBefore));

    if (scheduledDate.isBefore(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esa anticipación ya pasó, elige una más corta'),
          ),
        );
      }
      return;
    }

    final service = NotificationService();
    final granted = await service.requestPermissions();
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitas permitir notificaciones'),
          ),
        );
      }
      return;
    }

    await service.scheduleReminder(
      id: exam.id.hashCode,
      title: 'ETS: ${exam.subject}',
      body:
          'Tu examen es el ${DateFormat("d 'de' MMMM 'a las' h:mm a", 'es_MX').format(exam.date)} en ${exam.building}, salón ${exam.classroom}.',
      scheduledDate: scheduledDate,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recordatorio programado ✅'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _addToCalendar(BuildContext context, Exam exam) async {
    final event = Event(
      title: 'ETS: ${exam.subject}',
      description: 'Profesor: ${exam.professor}\nTurno: ${exam.shift.label}',
      location: '${exam.building} · Salón ${exam.classroom}',
      startDate: exam.date,
      endDate: exam.date.add(const Duration(hours: 2)),
    );

    await Add2Calendar.addEvent2Cal(event);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature: próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.guindaIpn.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.guindaIpn, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
