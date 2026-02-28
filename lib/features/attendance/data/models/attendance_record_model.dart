import 'package:hive/hive.dart';

part 'attendance_record_model.g.dart';

/// Modelo que representa un registro de asistencia de un alumno.
/// Se almacena como parte de un evento en Hive.
@HiveType(typeId: 1)
class AttendanceRecord extends HiveObject {
  /// Identificador único del alumno
  @HiveField(0)
  final String studentId;

  /// Nombre completo del alumno
  @HiveField(1)
  final String studentName;

  /// Fecha y hora en que se escaneó/registró al alumno
  @HiveField(2)
  final DateTime scannedAt;

  AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.scannedAt,
  });

  /// Crea una copia del registro con campos opcionales modificados
  AttendanceRecord copyWith({
    String? studentId,
    String? studentName,
    DateTime? scannedAt,
  }) {
    return AttendanceRecord(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  /// Convierte el registro a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  /// Crea un registro a partir de un mapa JSON
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
    );
  }
}
