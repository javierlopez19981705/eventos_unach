import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';
import 'package:eventos_unach/features/attendance/domain/attendance_provider.dart';

/// Pantalla de registro de asistencia para un evento activo.
/// Muestra reloj en tiempo real, lista de alumnos registrados,
/// y botones para escanear QR, agregar manualmente y guardar.
class AttendanceScreen extends StatefulWidget {
  final String eventId;

  const AttendanceScreen({super.key, required this.eventId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Timer _clockTimer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Actualizar el reloj cada segundo
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTime(),
    );

    // Iniciar sesión de asistencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = context.read<EventProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final event = eventProvider.getEventById(widget.eventId);
      if (event != null) {
        attendanceProvider.startSession(
          widget.eventId,
          event.attendanceRecords,
        );
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  /// Actualiza la hora actual
  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  /// Muestra diálogo para agregar alumno manualmente
  void _showManualAddDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID / Matrícula',
                prefixIcon: Icon(Icons.badge_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                final provider = context.read<AttendanceProvider>();
                final registered = provider.registerStudentManually(
                  idController.text.trim(),
                  nameController.text.trim(),
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      registered
                          ? '✅ Alumno registrado'
                          : '⚠️ El alumno ya está registrado',
                    ),
                    backgroundColor: registered ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Guarda la asistencia y cierra el evento
  Future<void> _saveAndClose() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final eventProvider = context.read<EventProvider>();

    final records = attendanceProvider.endSession();
    await eventProvider.completeEvent(widget.eventId, records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Evento guardado y completado'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/events');
    }
  }

  /// Confirma antes de guardar y cerrar
  void _confirmSave() {
    final count = context.read<AttendanceProvider>().registeredCount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar y Cerrar Evento'),
        content: Text(
          '¿Deseas guardar la asistencia con $count alumno(s) registrado(s) y marcar el evento como completado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveAndClose();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventProvider = context.watch<EventProvider>();
    final event = eventProvider.getEventById(widget.eventId);

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Asistencia')),
        body: const Center(child: Text('Evento no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Reloj y info del evento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Reloj en tiempo real
                Text(
                  _currentTime,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrada: ${event.entryTime.format(context)} — Salida: ${event.exitTime.format(context)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Contador de asistentes
                Consumer<AttendanceProvider>(
                  builder: (context, provider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.registeredCount} alumno(s) registrado(s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/events/${widget.eventId}/attendance/scanner',
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Escanear QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showManualAddDialog,
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Manual'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de alumnos registrados
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, _) {
                if (provider.currentRecords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay alumnos registrados',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Escanea un QR o agrega manualmente',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.currentRecords.length,
                  itemBuilder: (context, index) {
                    final record = provider.currentRecords[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          record.studentName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'ID: ${record.studentId} • ${DateFormat('HH:mm').format(record.scannedAt)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              provider.removeRecord(record.studentId),
                          tooltip: 'Eliminar registro',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Botón fijo para guardar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _confirmSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.save_rounded),
            label: const Text(
              'Guardar y Cerrar Evento',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
