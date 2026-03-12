import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'day_schedule_model.g.dart';

/// Modelo que representa el horario de un día específico del evento.
@HiveType(typeId: 3)
class DaySchedule extends HiveObject {
  /// Fecha del día
  @HiveField(0)
  final DateTime date;

  /// Hora de inicio (minutos desde medianoche)
  @HiveField(1)
  final int entryTimeMinutes;

  /// Hora de fin (minutos desde medianoche)
  @HiveField(2)
  final int exitTimeMinutes;

  DaySchedule({
    required this.date,
    required this.entryTimeMinutes,
    required this.exitTimeMinutes,
  });

  /// Hora de inicio como TimeOfDay
  TimeOfDay get entryTime =>
      TimeOfDay(hour: entryTimeMinutes ~/ 60, minute: entryTimeMinutes % 60);

  /// Hora de fin como TimeOfDay
  TimeOfDay get exitTime =>
      TimeOfDay(hour: exitTimeMinutes ~/ 60, minute: exitTimeMinutes % 60);

  /// Helper para crear minutos desde un TimeOfDay
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  DaySchedule copyWith({
    DateTime? date,
    int? entryTimeMinutes,
    int? exitTimeMinutes,
  }) {
    return DaySchedule(
      date: date ?? this.date,
      entryTimeMinutes: entryTimeMinutes ?? this.entryTimeMinutes,
      exitTimeMinutes: exitTimeMinutes ?? this.exitTimeMinutes,
    );
  }
}
