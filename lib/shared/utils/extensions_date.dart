import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  /// Formatea la fecha como "dd/MM/yyyy"
  String get formattedDate => DateFormat('dd/MM/yyyy').format(this);
}
