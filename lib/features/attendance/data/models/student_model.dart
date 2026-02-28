import 'dart:convert';

/// Modelo simple que representa un alumno.
/// Se usa para codificar/decodificar datos en códigos QR.
class Student {
  /// Identificador único del alumno
  final String id;

  /// Nombre completo del alumno
  final String name;

  Student({required this.id, required this.name});

  /// Convierte los datos del alumno a JSON string (para codificar en QR)
  String toQrData() {
    return jsonEncode({'id': id, 'name': name});
  }

  /// Crea un alumno a partir de datos decodificados del QR
  factory Student.fromQrData(String qrData) {
    final Map<String, dynamic> data = jsonDecode(qrData);
    return Student(id: data['id'] as String, name: data['name'] as String);
  }

  /// Convierte a mapa JSON
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  /// Crea desde mapa JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(id: json['id'] as String, name: json['name'] as String);
  }
}
