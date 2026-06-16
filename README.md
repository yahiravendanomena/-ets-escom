# ETS ESCOM 

Sistema móvil nativo para la gestión de **Exámenes a Título de Suficiencia (ETS)** de la Escuela Superior de Cómputo - IPN.

##  Objetivo

Permitir a estudiantes consultar sus ETS y a administradores gestionarlos (CRUD completo), con funcionalidad offline-first.

##  Stack Técnico

- **Framework**: Flutter 3.x (Dart)
- **Diseño**: Material Design 3
- **Estado**: flutter_riverpod (StateNotifier)
- **Inyección de Dependencias**: get_it (Service Locator)
- **HTTP**: Dio (preparado para backend real)
- **Persistencia local**: sqflite + shared_preferences
- **Almacenamiento seguro**: flutter_secure_storage
- **Navegación**: Navigator + rutas
- **Internacionalización**: intl (es_MX)
- **Hash de contraseñas**: SHA-256 (crypto)
- **URL externos**: url_launcher (Google Maps)
- **Tipografía**: Google Fonts (Roboto)

##  Arquitectura

**Clean Architecture** con 3 capas por feature:

\`\`\`
lib/
├── core/                    # Código compartido
│   ├── errors/              # Failures + Exceptions (dartz)
│   ├── network/             # NetworkInfo
│   ├── theme/               # Material 3 + colores IPN + Dark mode
│   ├── usecases/            # UseCase base genérico
│   └── widgets/             # MainScaffold con BottomNav
├── features/
│   ├── exams/               # Feature público
│   │   ├── data/            # Modelos, datasources, repo impl
│   │   ├── domain/          # Entidades, contratos, casos de uso
│   │   └── presentation/    # Notifier (Riverpod), pages, widgets
│   ├── auth/                # Login admin con SHA-256
│   ├── admin/               # CRUD de ETS
│   ├── splash/              # Splash con animación
│   ├── onboarding/          # 3 pantallas de bienvenida
│   └── notifications/       # (Pendiente)
└── injection_container.dart # Service Locator (get_it)
\`\`\`

##  Funcionalidades implementadas

### Módulo Público
- [x] Splash Screen con animación
- [x] Onboarding (3 pantallas, persistente en SharedPreferences)
- [x] Búsqueda inteligente con filtros (Carrera, Semestre, Materia)
- [x] Visualización dinámica de resultados
- [x] Pantalla de detalle completa
- [x] Favoritos persistentes
- [x] Integración con Google Maps (url_launcher)
- [x] Hero animations entre pantallas
- [x] Dark Mode automático

### Módulo Administrativo
- [x] Login seguro con hash SHA-256
- [x] Sesión persistente (flutter_secure_storage)
- [x] Dashboard con estadísticas en tiempo real
- [x] CRUD completo de ETS (Crear, Leer, Actualizar, Eliminar)
- [x] Validaciones de formularios
- [x] Manejo profesional de errores

### Técnicas
- [x] Clean Architecture (Data/Domain/Presentation)
- [x] Gestión de estado con Riverpod
- [x] Inyección de dependencias con get_it
- [x] Either<Failure, T> para manejo funcional de errores
- [x] Material Design 3
- [x] Localización en español

##  Pendientes (FASE 4)

- [ ] Notificaciones locales (recordatorios)
- [ ] Exportar calendario a PDF
- [ ] Exportar a iCalendar (.ics) - puntos extra
- [ ] Conectar con backend real (actualmente usa mock)
- [ ] Gestión de catálogos (Carreras, Edificios)
- [ ] Biometría para login admin

##  Setup

\`\`\`bash
flutter pub get
flutter run -d chrome     # Desarrollo
flutter run               # Emulador Android
\`\`\`

##  Credenciales Admin (DEMO)

| Usuario | Contraseña |
|---------|-----------|
| admin   | Admin123! |
| escom   | Escom2026 |

> Las contraseñas se almacenan como hash SHA-256, cumpliendo el requisito "contraseñas encriptadas".

##  Colaboradores

- yahiravendanomena
- JxsueRam

##  Curso

Desarrollo de Aplicaciones Móviles Nativas (DAMN) - ESCOM IPN  
Profesor: Ing. José Antonio Ortiz Ramírez  
Semestre: 2026-2