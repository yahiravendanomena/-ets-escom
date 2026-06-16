import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../notifications/services/notification_service.dart';
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
            // Header con info principal
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
            // Cuerpo con la información
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
                  // Botones de acción
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
                          onPressed: () =>
                              _showComingSoon(context, 'iCalendar'),
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: const Text('.ics'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _scheduleReminder(context),
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

  /// Muestra el bottom sheet para programar un recordatorio del ETS.
  Future<void> _scheduleReminder(BuildContext context) async {
    final option = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
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
              leading: const Icon(Icons.today, color: AppColors.guindaIpn),
              title: const Text('1 día antes'),
              subtitle: const Text('Recordatorio el día previo'),
              onTap: () => Navigator.pop(ctx, '1day'),
            ),
            ListTile(
              leading: const Icon(
                Icons.timer_outlined,
                color: AppColors.guindaIpn,
              ),
              title: const Text('1 hora antes'),
              subtitle: const Text('Justo antes del examen'),
              onTap: () => Navigator.pop(ctx, '1hour'),
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: AppColors.warning,
              ),
              title: const Text('Probar ahora'),
              subtitle: const Text('Recibir notificación inmediata (test)'),
              onTap: () => Navigator.pop(ctx, 'now'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (option == null || !context.mounted) return;

    final service = sl<NotificationService>();
    final notificationId = exam.id.hashCode;
    final title = 'Recordatorio: ${exam.subject}';
    final body = 'Tu ETS es en ${exam.building}, Salón ${exam.classroom}';

    try {
      if (option == 'now') {
        await service.showNow(
          id: notificationId,
          title: title,
          body: body,
        );
      } else {
        DateTime scheduledTime;
        if (option == '1day') {
          scheduledTime = exam.date.subtract(const Duration(days: 1));
        } else {
          scheduledTime = exam.date.subtract(const Duration(hours: 1));
        }

        // Validar que la fecha no sea en el pasado.
        if (scheduledTime.isBefore(DateTime.now())) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No se puede programar: la fecha ya pasó. Usa "Probar ahora".',
                ),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }

        await service.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledTime,
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            option == 'now'
                ? 'Notificación enviada 🔔'
                : 'Recordatorio programado ✅',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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

/// Card de información con ícono, título y valor.
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