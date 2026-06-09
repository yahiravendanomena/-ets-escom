import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Pantalla de inicio de sesión administrativa.
/// (Placeholder — se implementa en la siguiente fase del proyecto.)
class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso Administrativo'),
        backgroundColor: AppColors.adminGreen,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings_outlined,
                size: 80,
                color: AppColors.adminGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Panel administrativo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente: gestión completa de ETS, carreras, salones y estadísticas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: null, // Deshabilitado por ahora
                icon: const Icon(Icons.login),
                label: const Text('Iniciar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}