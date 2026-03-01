import 'dart:convert';
import 'package:hive/hive.dart';

part 'student_model.g.dart';

/// Modelo simple que representa un alumno.
/// Se usa para codificar/decodificar datos en códigos QR.
@HiveType(typeId: 2)
class Student extends HiveObject {
  /// Identificador único del alumno
  @HiveField(0)
  final String id;

  /// Nombre completo del alumno
  @HiveField(1)
  final String name;

  /// Apellido paterno del alumno
  @HiveField(2)
  final String lastNameP;

  /// Apellido materno del alumno
  @HiveField(3)
  final String lastNameM;

  /// Matricula del alumno
  @HiveField(4)
  final String matriculation;

  /// Carrera del alumno
  @HiveField(5)
  final String career;

  /// Turno del alumno
  @HiveField(6)
  final String turno;

  /// QR del alumno
  @HiveField(7)
  final String qr;

  Student({
    required this.id,
    required this.name,
    required this.lastNameP,
    required this.lastNameM,
    required this.matriculation,
    required this.career,
    required this.turno,
    required this.qr,
  });

  /// Convierte los datos del alumno a JSON string (para codificar en QR)
  String toQrData() {
    return jsonEncode({'id': id, 'name': name});
  }

  /// Crea un alumno a partir de datos decodificados del QR
  factory Student.fromQrData(String qrData) {
    final Map<String, dynamic> data = jsonDecode(qrData);
    return Student(
      id: data['id'] as String,
      name: data['name'] as String,
      lastNameP: data['lastNameP'] as String,
      lastNameM: data['lastNameM'] as String,
      matriculation: data['matriculation'] as String,
      career: data['career'] as String,
      turno: data['turno'] as String,
      qr: data['qr'] as String,
    );
  }

  /// Convierte a mapa JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastNameP': lastNameP,
    'lastNameM': lastNameM,
    'matriculation': matriculation,
    'career': career,
    'turno': turno,
    'qr': qr,
  };

  /// Crea desde mapa JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      lastNameP: json['lastNameP'] as String,
      lastNameM: json['lastNameM'] as String,
      matriculation: json['matriculation'] as String,
      career: json['career'] as String,
      turno: json['turno'] as String,
      qr: json['qr'] as String,
    );
  }
}
