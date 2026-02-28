import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventos_unach/shared/utils/constants.dart';
import 'package:eventos_unach/features/events/presentation/screens/home_screen.dart';
import 'package:eventos_unach/features/events/presentation/screens/create_event_screen.dart';
import 'package:eventos_unach/features/events/presentation/screens/saved_events_screen.dart';
import 'package:eventos_unach/features/events/presentation/screens/event_detail_screen.dart';
import 'package:eventos_unach/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:eventos_unach/features/attendance/presentation/screens/qr_scanner_screen.dart';
import 'package:eventos_unach/features/attendance/presentation/screens/generate_qr_screen.dart';
import 'package:eventos_unach/features/diploma/presentation/screens/diploma_screen.dart';

/// Configuración de rutas de la aplicación usando GoRouter.
/// Define todas las rutas navegables y sus pantallas correspondientes.
final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.homeRoute,
  routes: [
    // Pantalla principal (menú)
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // Crear nuevo evento
    GoRoute(
      path: '/create-event',
      name: 'createEvent',
      builder: (context, state) => const CreateEventScreen(),
    ),

    // Lista de eventos guardados
    GoRoute(
      path: '/events',
      name: 'savedEvents',
      builder: (context, state) => const SavedEventsScreen(),
    ),

    // Detalle de un evento
    GoRoute(
      path: '/events/:id',
      name: 'eventDetail',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return EventDetailScreen(eventId: eventId);
      },
    ),

    // Pantalla de asistencia (evento activo)
    GoRoute(
      path: '/events/:id/attendance',
      name: 'attendance',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return AttendanceScreen(eventId: eventId);
      },
    ),

    // Escáner QR
    GoRoute(
      path: '/events/:id/attendance/scanner',
      name: 'qrScanner',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return QrScannerScreen(eventId: eventId);
      },
    ),

    // Generar QR para alumno
    GoRoute(
      path: '/generate-qr',
      name: 'generateQr',
      builder: (context, state) => const GenerateQrScreen(),
    ),

    // Pantalla de diplomas
    GoRoute(
      path: '/diploma',
      name: 'diploma',
      builder: (context, state) => const DiplomaScreen(),
    ),
  ],

  // Manejo de errores de navegación
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Ruta: ${state.uri.toString()}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
);
