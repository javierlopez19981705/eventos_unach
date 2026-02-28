import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';

/// Pantalla de detalle de un evento.
/// Muestra toda la información del evento y un botón para iniciar la asistencia.
class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Botón eliminar
          Consumer<EventProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _confirmDelete(context, provider),
                tooltip: 'Eliminar evento',
              );
            },
          ),
        ],
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          final event = provider.getEventById(eventId);

          if (event == null) {
            return const Center(child: Text('Evento no encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado con ícono
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: event.isCompleted
                          ? Colors.green.withValues(alpha: 0.12)
                          : theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      event.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.event_rounded,
                      size: 40,
                      color: event.isCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nombre del evento
                Text(
                  event.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Badge de estado
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: event.isCompleted
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.isCompleted ? '✅ Completado' : '⏳ Pendiente',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: event.isCompleted
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Información del evento
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Fecha',
                      value: dateFormat.format(event.date),
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Fecha fin',
                      value: dateFormat.format(event.dateEnd),
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.login_rounded,
                      label: 'Hora de Entrada',
                      value: event.entryTime.format(context),
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.logout_rounded,
                      label: 'Hora de Salida',
                      value: event.exitTime.format(context),
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.people_rounded,
                      label: 'Asistentes Registrados',
                      value: '${event.attendanceRecords.length}',
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botón Iniciar Evento (solo si no está completado)
                if (!event.isCompleted)
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/events/$eventId/attendance'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Iniciar Evento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Si está completado, mostrar lista de asistentes
                if (event.isCompleted &&
                    event.attendanceRecords.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Lista de Asistentes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...event.attendanceRecords.map(
                    (record) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            record.studentName[0].toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(record.studentName),
                        subtitle: Text('ID: ${record.studentId}'),
                        trailing: Text(
                          DateFormat('HH:mm').format(record.scannedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Diálogo de confirmación para eliminar el evento
  void _confirmDelete(BuildContext context, EventProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este evento? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await provider.deleteEvent(eventId);
              if (context.mounted) context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de información con bordes redondeados
class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

/// Fila de información con ícono, etiqueta y valor
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
