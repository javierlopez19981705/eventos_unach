import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';
import 'package:eventos_unach/features/events/data/models/event_model.dart';
import 'package:eventos_unach/features/diploma/data/diploma_generator.dart';
import 'package:eventos_unach/shared/widgets/empty_state.dart';

/// Pantalla para generar diplomas de participación.
/// Muestra la lista de eventos completados y permite generar
/// diplomas PDF para los alumnos que asistieron.
class DiplomaScreen extends StatefulWidget {
  const DiplomaScreen({super.key});

  @override
  State<DiplomaScreen> createState() => _DiplomaScreenState();
}

class _DiplomaScreenState extends State<DiplomaScreen> {
  bool _isGenerating = false;

  /// Genera y muestra el diploma PDF para compartir/imprimir
  Future<void> _generateDiploma(Event event, String studentName) async {
    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await DiplomaGenerator.generateDiploma(
        studentName: studentName,
        event: event,
      );

      if (mounted) {
        // Mostrar preview del PDF con opción de compartir/imprimir
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name:
              'Diploma_${studentName.replaceAll(' ', '_')}_${event.name.replaceAll(' ', '_')}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar diploma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  /// Genera diplomas para todos los asistentes de un evento
  Future<void> _generateAllDiplomas(Event event) async {
    if (event.attendanceRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay asistentes registrados en este evento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar diálogo para seleccionar alumno
    _showStudentSelector(event);
  }

  /// Diálogo para seleccionar el alumno al que se le generará el diploma
  void _showStudentSelector(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Selecciona un alumno',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: event.attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = event.attendanceRecords[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(record.studentName[0].toUpperCase()),
                        ),
                        title: Text(record.studentName),
                        subtitle: Text('ID: ${record.studentId}'),
                        trailing: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _generateDiploma(event, record.studentName);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Diplomas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando diploma...'),
                ],
              ),
            )
          : Consumer<EventProvider>(
              builder: (context, provider, _) {
                final completedEvents = provider.completedEvents;

                if (completedEvents.isEmpty) {
                  return const EmptyState(
                    icon: Icons.workspace_premium_rounded,
                    title: 'No hay eventos completados',
                    description:
                        'Completa un evento con registro de asistencia para generar diplomas',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completedEvents.length,
                  itemBuilder: (context, index) {
                    final event = completedEvents[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(event.date),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.attendanceRecords.length} asistente(s)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _generateAllDiplomas(event),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1),
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 20,
                                ),
                                label: const Text('Generar Diploma'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
