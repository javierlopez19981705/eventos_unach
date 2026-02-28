import 'package:flutter/material.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';

/// Provider que gestiona el estado de la sesión de asistencia activa.
/// Controla la lista de alumnos registrados durante un evento en curso.
class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _currentRecords = [];
  bool _isSessionActive = false;
  String? _activeEventId;

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

  /// Registra un alumno en la sesión actual a partir de datos del QR
  bool registerStudent(Student student) {
    // Verificar si ya está registrado
    final alreadyRegistered = _currentRecords.any(
      (r) => r.studentId == student.id,
    );
    if (alreadyRegistered) {
      return false; // Ya registrado
    }

    final record = AttendanceRecord(
      studentId: student.id,
      studentName: student.name,
      scannedAt: DateTime.now(),
    );

    _currentRecords.add(record);
    notifyListeners();
    return true;
  }

  /// Registra un alumno manualmente (sin QR)
  bool registerStudentManually(String id, String name) {
    return registerStudent(Student(id: id, name: name));
  }

  /// Elimina un registro de asistencia de la sesión actual
  void removeRecord(String studentId) {
    _currentRecords.removeWhere((r) => r.studentId == studentId);
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
}
