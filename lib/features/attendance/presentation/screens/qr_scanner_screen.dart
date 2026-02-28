import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:eventos_unach/features/attendance/domain/attendance_provider.dart';
import 'package:eventos_unach/features/attendance/data/models/student_model.dart';

/// Pantalla de escáner QR para registrar asistencia.
/// Usa la cámara del dispositivo para leer códigos QR con datos de alumnos.
class QrScannerScreen extends StatefulWidget {
  final String eventId;

  const QrScannerScreen({super.key, required this.eventId});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Procesa el código QR escaneado
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.isEmpty) continue;

      setState(() => _isProcessing = true);

      try {
        // Intentar parsear como datos de alumno JSON
        final student = Student.fromQrData(rawValue);
        final provider = context.read<AttendanceProvider>();
        final registered = provider.registerStudent(student);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              registered
                  ? '✅ ${student.name} registrado exitosamente'
                  : '⚠️ ${student.name} ya está registrado',
            ),
            backgroundColor: registered ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        // Pequeña pausa para evitar lecturas duplicadas
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isProcessing = false);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ QR no válido. Formato esperado: {"id":"...","name":"..."}',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isProcessing = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Botón para alternar flash
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _scannerController.toggleTorch(),
            tooltip: 'Flash',
          ),
          // Botón para cambiar cámara
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _scannerController.switchCamera(),
            tooltip: 'Cambiar cámara',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Vista de la cámara
          MobileScanner(controller: _scannerController, onDetect: _onDetect),

          // Overlay decorativo
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.green : Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Indicador de procesamiento
          if (_isProcessing)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Procesando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Instrucciones en la parte inferior
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Apunta al código QR del alumno',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
