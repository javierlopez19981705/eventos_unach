import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:eventos_unach/app/router.dart';
import 'package:eventos_unach/app/providers.dart';
import 'package:eventos_unach/shared/theme.dart';
import 'package:eventos_unach/shared/utils/constants.dart';
import 'package:eventos_unach/features/events/data/models/event_model.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';
import 'package:eventos_unach/features/events/data/repositories/event_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Punto de entrada principal de la aplicación Eventos UNACH.
/// Inicializa Hive, registra adaptadores y configura providers.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX', null);
  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  // Registrar adaptadores de Hive para los modelos
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(EventAdapter());

  // Inicializar el repositorio de eventos
  final eventRepository = EventRepository();
  await eventRepository.init();

  runApp(EventosUnachApp(eventRepository: eventRepository));
}

/// Widget raíz de la aplicación.
/// Configura el tema, los providers y el sistema de navegación.
class EventosUnachApp extends StatelessWidget {
  final EventRepository eventRepository;

  const EventosUnachApp({super.key, required this.eventRepository});

  @override
  Widget build(BuildContext context) {
    return AppProviders.create(
      eventRepository: eventRepository,
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        supportedLocales: const [Locale('es', 'MX')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
