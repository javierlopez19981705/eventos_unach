import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:eventos_unach/features/attendance/data/models/attendance_record_model.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';

part 'event_model.g.dart';

/// Modelo que representa un evento universitario.
/// Se almacena localmente usando Hive para persistir los datos.
@HiveType(typeId: 0)
class Event extends HiveObject {
  /// Identificador único del evento
  @HiveField(0)
  final String id;

  /// Nombre descriptivo del evento
  @HiveField(1)
  final String name;

  /// Fecha del evento
  @HiveField(2)
  final DateTime date;

  /// Hora de entrada (almacenada como minutos desde medianoche)
  @HiveField(3)
  final int entryTimeMinutes;

  /// Hora de salida (almacenada como minutos desde medianoche)
  @HiveField(4)
  final int exitTimeMinutes;

  /// Lista de registros de asistencia del evento
  @HiveField(5)
  final List<AttendanceRecord> attendanceRecords;

  /// Indica si el evento ya fue completado/cerrado
  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime dateEnd;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.dateEnd,
    required this.entryTimeMinutes,
    required this.exitTimeMinutes,
    List<AttendanceRecord>? attendanceRecords,
    this.isCompleted = false,
  }) : attendanceRecords = attendanceRecords ?? [];

  /// Convierte los minutos almacenados a TimeOfDay para la UI
  TimeOfDay get entryTime =>
      TimeOfDay(hour: entryTimeMinutes ~/ 60, minute: entryTimeMinutes % 60);

  /// Convierte los minutos almacenados a TimeOfDay para la UI
  TimeOfDay get exitTime =>
      TimeOfDay(hour: exitTimeMinutes ~/ 60, minute: exitTimeMinutes % 60);

  /// Número total de días del evento (desde date hasta dateEnd inclusive)
  int get totalEventDays {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(dateEnd.year, dateEnd.month, dateEnd.day);
    return end.difference(start).inDays + 1;
  }

  /// Retorna la lista de alumnos elegibles para diploma.
  /// Solo son elegibles los alumnos que asistieron TODOS los días del evento.
  List<Student> getEligibleStudents() {
    final requiredDays = totalEventDays;

    // Agrupar registros por studentId y contar días únicos
    final Map<String, Set<String>> studentDays = {};
    final Map<String, Student> studentMap = {};

    for (final record in attendanceRecords) {
      final studentId = record.student.id;
      final dayKey =
          '${record.scannedAt.year}-${record.scannedAt.month}-${record.scannedAt.day}';

      studentDays.putIfAbsent(studentId, () => {});
      studentDays[studentId]!.add(dayKey);
      studentMap[studentId] = record.student;
    }

    // Filtrar solo los que asistieron todos los días
    return studentMap.entries
        .where((entry) => studentDays[entry.key]!.length >= requiredDays)
        .map((entry) => entry.value)
        .toList();
  }

  /// Helper para crear minutos desde un TimeOfDay
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Crea una copia del evento con campos opcionales modificados
  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    DateTime? dateEnd,
    int? entryTimeMinutes,
    int? exitTimeMinutes,
    List<AttendanceRecord>? attendanceRecords,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      dateEnd: dateEnd ?? this.dateEnd,
      entryTimeMinutes: entryTimeMinutes ?? this.entryTimeMinutes,
      exitTimeMinutes: exitTimeMinutes ?? this.exitTimeMinutes,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
