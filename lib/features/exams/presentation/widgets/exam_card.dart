import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/exam.dart';

/// Tarjeta que muestra la información de un ETS.
class ExamCard extends StatelessWidget {
  final Exam exam;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.exam,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? Colors.grey.shade300 : AppColors.textSecondary;
    final dateFormat = DateFormat('d MMM yyyy', 'es_MX');
    final timeFormat = DateFormat('h:mm a', 'es_MX');

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: materia + botón favorito
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título con Hero animation (vuela al detalle).
                        Hero(
                          tag: 'exam-title-${exam.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              exam.subject,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.guindaIpn.withValues(
                                  alpha: isDark ? 0.3 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                exam.careerCode,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.guindaIpn,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Semestre ${exam.semester}°',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_outline,
                      color: isFavorite ? AppColors.warning : secondaryColor,
                    ),
                    tooltip: isFavorite ? 'Quitar favorito' : 'Marcar favorito',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              // Detalles del ETS
              _DetailRow(
                icon: Icons.calendar_today_rounded,
                label: dateFormat.format(exam.date),
              ),
              const SizedBox(height: 6),
              _DetailRow(
                icon: Icons.access_time_rounded,
                label: '${timeFormat.format(exam.date)} · ${exam.shift.label}',
              ),
              const SizedBox(height: 6),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: '${exam.building} · Salón ${exam.classroom}',
              ),
              const SizedBox(height: 6),
              _DetailRow(
                icon: Icons.person_outline,
                label: exam.professor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila pequeña con ícono + texto para los detalles de la tarjeta.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.grey.shade300 : AppColors.textSecondary;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}
