import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/exams_notifier.dart';
import '../widgets/exam_card.dart';
import 'exam_detail_page.dart';
import '../../../../core/theme/theme_provider.dart';

/// Pantalla principal: búsqueda y consulta pública de ETS.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  static const _careers = ['ISC', 'IIA', 'LCD'];
  static const _semesters = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  void initState() {
    super.initState();
    // Carga inicial: traer todos los ETS.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(examsProvider.notifier).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(examsProvider);
    final notifier = ref.read(examsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? Colors.grey.shade300 : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ETS ESCOM'),
        actions: [
          // Toggle Dark Mode
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeProvider);
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              );
            },
          ),
          if (state.selectedCareer != null ||
              state.selectedSemester != null ||
              state.subjectQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Limpiar filtros',
              onPressed: notifier.clearAllFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Sección de filtros.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador por materia.
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar materia...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: notifier.setSubjectQuery,
                ),
                const SizedBox(height: 12),
                // Dropdown de carrera.
                DropdownButtonFormField<String?>(
                  initialValue: state.selectedCareer,
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas las carreras'),
                    ),
                    ..._careers.map(
                      (c) =>
                          DropdownMenuItem<String?>(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: notifier.setCareer,
                ),
                const SizedBox(height: 12),
                // Chips de semestre.
                Text(
                  'Semestre',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: _semesters.map((sem) {
                    final isSelected = state.selectedSemester == sem;
                    return FilterChip(
                      label: Text(
                        '$sem°',
                        style: TextStyle(
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.guindaIpn)
                              : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        notifier.setSemester(selected ? sem : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
          // Sección de resultados.
          Expanded(child: _buildResults(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildResults(state, notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor =
        isDark ? Colors.grey.shade300 : AppColors.textSecondary;

    if (state.isLoading && state.exams.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: notifier.loadInitialData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.exams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: secondaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                'No se encontraron ETS con esos filtros',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Contador de resultados.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${state.exams.length} ETS encontrados',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: state.exams.length,
            itemBuilder: (context, index) {
              final exam = state.exams[index];
              final isFavorite = state.favoriteIds.contains(exam.id);
              return ExamCard(
                exam: exam,
                isFavorite: isFavorite,
                onFavoriteToggle: () => notifier.toggleFavorite(exam.id),
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
    );
  }
}
