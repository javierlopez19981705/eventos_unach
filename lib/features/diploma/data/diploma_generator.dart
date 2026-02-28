import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:eventos_unach/features/events/data/models/event_model.dart';

/// Clase encargada de generar diplomas en formato PDF.
/// Crea un documento decorado con los datos del alumno y evento.
class DiplomaGenerator {
  /// Genera un diploma PDF para un alumno y evento específicos.
  /// Retorna los bytes del PDF generado.
  static Future<Uint8List> generateDiploma({
    required String studentName,
    required Event event,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es');

    // Intentar cargar la imagen del borde decorativo
    pw.MemoryImage? borderImage;
    try {
      final imageData = await rootBundle.load(
        'assets/images/diploma_border.png',
      );
      borderImage = pw.MemoryImage(imageData.buffer.asUint8List());
    } catch (_) {
      // Si no se puede cargar, se generará sin imagen
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter.landscape,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Imagen de fondo (borde decorativo)
              if (borderImage != null)
                pw.Positioned.fill(
                  child: pw.Image(borderImage, fit: pw.BoxFit.cover),
                ),

              // Contenido del diploma
              pw.Positioned.fill(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 60,
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 30),

                      // Título principal
                      pw.Text(
                        'UNIVERSIDAD AUTÓNOMA DE CHIAPAS',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0D47A1'),
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      // Subtítulo
                      pw.Text(
                        'DIPLOMA DE PARTICIPACIÓN',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#1B5E20'),
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 24),

                      // Se otorga a
                      pw.Text(
                        'Se otorga el presente diploma a',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromHex('#424242'),
                        ),
                      ),
                      pw.SizedBox(height: 16),

                      // Nombre del alumno
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 8,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColor.fromHex('#1B5E20'),
                              width: 2,
                            ),
                          ),
                        ),
                        child: pw.Text(
                          studentName,
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#1B5E20'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // Descripción
                      pw.Text(
                        'Por su participación y asistencia en el evento',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColor.fromHex('#424242'),
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      // Nombre del evento
                      pw.Text(
                        event.name,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0D47A1'),
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 12),

                      // Fecha
                      pw.Text(
                        'Celebrado el ${dateFormat.format(event.date)}',
                        style: pw.TextStyle(
                          fontSize: 13,
                          color: PdfColor.fromHex('#616161'),
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 8),

                      // Horario
                      pw.Text(
                        'Horario: ${_formatMinutes(event.entryTimeMinutes)} - ${_formatMinutes(event.exitTimeMinutes)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#757575'),
                        ),
                      ),

                      pw.Spacer(),

                      // Firma
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Column(
                            children: [
                              pw.Container(
                                width: 200,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border(
                                    top: pw.BorderSide(
                                      color: PdfColor.fromHex('#424242'),
                                    ),
                                  ),
                                ),
                                child: pw.SizedBox(height: 2),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Firma del Organizador',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColor.fromHex('#757575'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Convierte minutos totales a formato HH:mm
  static String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
