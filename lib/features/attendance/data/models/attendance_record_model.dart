import 'package:hive/hive.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';

part 'attendance_record_model.g.dart';

/// Modelo que representa un registro de asistencia de un alumno.
/// Se almacena como parte de un evento en Hive.
@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  /// Datos del alumno registrado
  @HiveField(0)
  final Student student;

  /// Fecha y hora en que se escaneó/registró al alumno
  @HiveField(1)
  final DateTime scannedAt;

  AttendanceRecord({required this.student, required this.scannedAt});

  /// Crea una copia del registro con campos opcionales modificados
  AttendanceRecord copyWith({Student? student, DateTime? scannedAt}) {
    return AttendanceRecord(
      student: student ?? this.student,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  /// Convierte el registro a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Crea un registro a partir de un mapa JSON
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }
}
