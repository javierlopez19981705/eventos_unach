import 'package:flutter/material.dart';
import 'package:eventos_unach/features/events/data/models/event_model.dart';
import 'package:eventos_unach/features/events/data/repositories/event_repository.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:uuid/uuid.dart';

/// Provider que gestiona el estado global de los eventos.
/// Utiliza ChangeNotifier para notificar a los widgets cuando cambian los datos.
class EventProvider extends ChangeNotifier {
  final EventRepository _repository;
  final Uuid _uuid = const Uuid();

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  EventProvider(this._repository);

  // --- Getters ---

  /// Lista de todos los eventos
  List<Event> get events => _events;

  /// Indica si se están cargando datos
  bool get isLoading => _isLoading;

  /// Mensaje de error, si existe
  String? get errorMessage => _errorMessage;

  /// Lista de eventos completados (para generar diplomas)
  List<Event> get completedEvents =>
      _events.where((e) => e.isCompleted).toList();

  // --- Métodos principales ---

  /// Carga todos los eventos desde el almacenamiento local
  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = _repository.getAllEvents();
      // Ordenar por fecha descendente
      _events.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _errorMessage = 'Error al cargar eventos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea y guarda un nuevo evento
  Future<bool> createEvent({
    required String name,
    required DateTime date,
    required DateTime dateEnd,
    required TimeOfDay entryTime,
    required TimeOfDay exitTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final event = Event(
        id: _uuid.v4(),
        name: name,
        date: date,
        dateEnd: dateEnd,
        entryTimeMinutes: Event.timeOfDayToMinutes(entryTime),
        exitTimeMinutes: Event.timeOfDayToMinutes(exitTime),
      );

      await _repository.saveEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear evento: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtiene un evento específico por su ID
  Event? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return _repository.getEventById(id);
    }
  }

  /// Elimina un evento por su ID
  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      await loadEvents();
    } catch (e) {
      _errorMessage = 'Error al eliminar evento: $e';
      notifyListeners();
    }
  }

  /// Agrega un registro de asistencia a un evento
  Future<void> addAttendanceRecord(
    String eventId,
    AttendanceRecord record,
  ) async {
    try {
      final event = getEventById(eventId);
      if (event != null) {
        // Verificar si el alumno ya está registrado
        final alreadyExists = event.attendanceRecords.any(
          (r) => r.student.id == record.student.id,
        );
        if (!alreadyExists) {
          final updatedRecords = [...event.attendanceRecords, record];
          await _repository.updateAttendance(eventId, updatedRecords);
          await loadEvents();
        }
      }
    } catch (e) {
      _errorMessage = 'Error al registrar asistencia: $e';
      notifyListeners();
    }
  }

  /// Marca un evento como completado y guarda la asistencia final
  Future<void> completeEvent(
    String eventId,
    List<AttendanceRecord> records,
  ) async {
    try {
      await _repository.updateAttendance(eventId, records);
      await _repository.markEventCompleted(eventId);
      await loadEvents();
    } catch (e) {
      _errorMessage = 'Error al completar evento: $e';
      notifyListeners();
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
