import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_scaffold.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa formatos de fecha en español.
  await initializeDateFormatting('es_MX', null);

  // Inicializa todas las dependencias.
  await di.initDependencies();

  runApp(
    const ProviderScope(
      child: EtsEscomApp(),
    ),
  );
}

class EtsEscomApp extends StatelessWidget {
  const EtsEscomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETS ESCOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}