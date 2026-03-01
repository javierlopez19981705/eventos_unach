import 'package:flutter/material.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';
import 'package:eventos_unach/features/events/data/models/event_model.dart';
import 'package:eventos_unach/features/events/data/repositories/event_repository.dart';

import '../../../shared/utils/extensions_date.dart';

/// Resultado del intento de registro de asistencia
enum RegistrationResult {
  /// Registro exitoso
  success,

  /// El alumno ya fue registrado hoy
  alreadyRegisteredToday,

  /// La fecha actual está fuera del rango del evento
  outsideDateRange,
}

/// Provider que gestiona el estado de la sesión de asistencia activa.
/// Controla la lista de alumnos registrados durante un evento en curso.
/// Persiste los registros en Hive después de cada cambio para no perder datos.
class AttendanceProvider extends ChangeNotifier {
  final EventRepository _repository;

  List<AttendanceRecord> _currentRecords = [];
  bool _isSessionActive = false;
  String? _activeEventId;

  AttendanceProvider(this._repository);

  // --- Getters ---

  /// Registros de asistencia de la sesión actual
  List<AttendanceRecord> get currentRecords =>
      List.unmodifiable(_currentRecords);

  /// Indica si hay una sesión de asistencia activa
  bool get isSessionActive => _isSessionActive;

  /// ID del evento activo
  String? get activeEventId => _activeEventId;

  /// Cantidad de alumnos registrados en la sesión actual
  int get registeredCount => _currentRecords.length;

  // --- Métodos principales ---

  /// Inicia una nueva sesión de asistencia para un evento
  void startSession(String eventId, [List<AttendanceRecord>? existingRecords]) {
    _activeEventId = eventId;
    _currentRecords = existingRecords != null ? List.from(existingRecords) : [];
    _isSessionActive = true;
    notifyListeners();
  }

  /// Registra un alumno en la sesión actual.
  /// Reglas:
  /// - El alumno puede asistir varias veces al mismo evento (en días distintos).
  /// - Solo puede registrarse una vez por día.
  /// - Solo puede registrarse dentro del rango de fechas del evento (date - dateEnd).
  RegistrationResult registerStudent(Student student, Event event) {
    final now = DateTime.now();

    // Verificar que la fecha actual esté dentro del rango del evento
    final todayDate = DateTime(now.year, now.month, now.day);
    final eventStart = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    final eventEnd = DateTime(
      event.dateEnd.year,
      event.dateEnd.month,
      event.dateEnd.day,
    );

    if (todayDate.isBefore(eventStart) || todayDate.isAfter(eventEnd)) {
      return RegistrationResult.outsideDateRange;
    }

    // Verificar si ya está registrado hoy
    final alreadyRegisteredToday = _currentRecords.any(
      (r) =>
          r.student.id == student.id &&
          r.scannedAt.formattedDate == now.formattedDate,
    );

    if (alreadyRegisteredToday) {
      return RegistrationResult.alreadyRegisteredToday;
    }

    final record = AttendanceRecord(student: student, scannedAt: now);

    _currentRecords.add(record);
    _persistRecords();
    notifyListeners();
    return RegistrationResult.success;
  }

  /// Elimina un registro de asistencia de la sesión actual
  void removeRecord(String studentId) {
    _currentRecords.removeWhere((r) => r.student.id == studentId);
    _persistRecords();
    notifyListeners();
  }

  /// Finaliza la sesión de asistencia y devuelve los registros
  List<AttendanceRecord> endSession() {
    final records = List<AttendanceRecord>.from(_currentRecords);
    _isSessionActive = false;
    _activeEventId = null;
    _currentRecords = [];
    notifyListeners();
    return records;
  }

  /// Limpia la sesión sin devolver registros
  void clearSession() {
    _isSessionActive = false;
    _activeEventId = null;
    _currentRecords = [];
    notifyListeners();
  }

  /// Guarda los registros actuales en Hive asociados al evento activo.
  /// Se ejecuta después de cada registro o eliminación.
  Future<void> _persistRecords() async {
    if (_activeEventId == null) return;
    try {
      await _repository.updateAttendance(
        _activeEventId!,
        List<AttendanceRecord>.from(_currentRecords),
      );
    } catch (e) {
      debugPrint('Error al persistir registros de asistencia: $e');
    }
  }
}
