/// Constantes globales de la aplicación Eventos UNACH.
class AppConstants {
  // Nombre de la caja de Hive para almacenar eventos
  static const String eventsBoxName = 'events_box';

  // Rutas de navegación
  static const String homeRoute = '/';
  static const String createEventRoute = '/create-event';
  static const String savedEventsRoute = '/events';
  static const String eventDetailRoute = '/events/:id';
  static const String attendanceRoute = '/events/:id/attendance';
  static const String diplomaRoute = '/diploma';
  static const String qrScannerRoute = '/events/:id/attendance/scanner';

  // Nombre de la aplicación
  static const String appName = 'Eventos UNACH';
}
