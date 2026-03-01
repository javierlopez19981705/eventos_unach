import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';
import 'package:eventos_unach/features/events/data/repositories/event_repository.dart';
import 'package:eventos_unach/features/attendance/domain/attendance_provider.dart';

/// Configuración centralizada de todos los providers de la aplicación.
/// Usa MultiProvider para inyectar dependencias en el árbol de widgets.
class AppProviders {
  /// Crea el MultiProvider con todos los providers necesarios
  static MultiProvider create({
    required EventRepository eventRepository,
    required Widget child,
  }) {
    return MultiProvider(
      providers: [
        // Provider de eventos (CRUD, persistencia)
        ChangeNotifierProvider<EventProvider>(
          create: (_) => EventProvider(eventRepository)..loadEvents(),
        ),
        // Provider de asistencia (sesión activa, persiste registros)
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(eventRepository),
        ),
      ],
      child: child,
    );
  }
}
