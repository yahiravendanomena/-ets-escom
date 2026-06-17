import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';

import 'features/splash/splash_page.dart';

import 'core/widgets/main_scaffold.dart';
import 'core/services/notification_service.dart'; // NUEVO

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);

  // Inicializa el servicio de notificaciones.
  await NotificationService().init(); // NUEVO

  // Inicializa todas las dependencias.

  await di.initDependencies();

  runApp(const ProviderScope(child: EtsEscomApp()));
}

class EtsEscomApp extends StatelessWidget {
  const EtsEscomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETS ESCOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'MX')],
    );
  }
}
