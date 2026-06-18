import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../providers/exams_notifier.dart';
import '../widgets/exam_card.dart';
import 'exam_detail_page.dart';

/// Pantalla de ETS favoritos del usuario.
///
/// Muestra solo los ETS marcados con estrella, ordenados por fecha.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examsProvider);
    final notifier = ref.read(examsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? Colors.grey.shade300 : AppColors.textSecondary;

    // Filtrar solo los favoritos y ordenarlos por fecha.
    final favorites = state.exams
        .where((exam) => state.favoriteIds.contains(exam.id))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ETS Favoritos'),
        actions: [
          // Toggle Dark Mode
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeProvider);
              final isDarkMode = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context, secondaryColor)
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${favorites.length} ${favorites.length == 1 ? "examen" : "exámenes"} guardado${favorites.length == 1 ? "" : "s"}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final exam = favorites[index];
                      return ExamCard(
                        exam: exam,
                        isFavorite: true,
                        onFavoriteToggle: () =>
                            notifier.toggleFavorite(exam.id),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExamDetailPage(exam: exam),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color secondaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline_rounded,
              size: 80,
              color: secondaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin favoritos aún',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Marca tus exámenes con la estrella ⭐ para encontrarlos rápidamente aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
