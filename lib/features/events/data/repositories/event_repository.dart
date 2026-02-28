import 'package:hive/hive.dart';
import 'package:eventos_unach/features/events/data/models/event_model.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:eventos_unach/shared/utils/constants.dart';

/// Repositorio local de eventos usando Hive.
/// Proporciona operaciones CRUD sobre la caja de eventos.
class EventRepository {
  late Box<Event> _eventsBox;

  /// Inicializa el repositorio abriendo la caja de Hive
  Future<void> init() async {
    _eventsBox = await Hive.openBox<Event>(AppConstants.eventsBoxName);
  }

  /// Obtiene la referencia a la caja (debe estar abierta)
  Box<Event> get box => _eventsBox;

  /// Obtiene todos los eventos almacenados
  List<Event> getAllEvents() {
    return _eventsBox.values.toList();
  }

  /// Obtiene un evento por su ID
  Event? getEventById(String id) {
    try {
      return _eventsBox.values.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Guarda un nuevo evento en la caja
  Future<void> saveEvent(Event event) async {
    await _eventsBox.put(event.id, event);
  }

  /// Actualiza un evento existente
  Future<void> updateEvent(Event event) async {
    await _eventsBox.put(event.id, event);
  }

  /// Elimina un evento por su ID
  Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }

  /// Obtiene solo los eventos completados
  List<Event> getCompletedEvents() {
    return _eventsBox.values.where((event) => event.isCompleted).toList();
  }

  /// Actualiza la lista de asistencia de un evento
  Future<void> updateAttendance(
    String eventId,
    List<AttendanceRecord> records,
  ) async {
    final event = getEventById(eventId);
    if (event != null) {
      final updated = event.copyWith(attendanceRecords: records);
      await updateEvent(updated);
    }
  }

  /// Marca un evento como completado
  Future<void> markEventCompleted(String eventId) async {
    final event = getEventById(eventId);
    if (event != null) {
      final updated = event.copyWith(isCompleted: true);
      await updateEvent(updated);
    }
  }
}
