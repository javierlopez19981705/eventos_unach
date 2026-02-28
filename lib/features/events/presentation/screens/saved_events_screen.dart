import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';
import 'package:eventos_unach/shared/widgets/empty_state.dart';
import 'package:eventos_unach/shared/widgets/loading_widget.dart';

/// Pantalla que muestra la lista de todos los eventos guardados.
/// Al seleccionar un evento, navega a su detalle.
class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Guardados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          // Estado de carga
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Cargando eventos...');
          }

          // Estado de error
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadEvents(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Estado vacío
          if (provider.events.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy_rounded,
              title: 'No hay eventos guardados',
              description: 'Crea tu primer evento desde el menú principal',
            );
          }

          // Lista de eventos
          return RefreshIndicator(
            onRefresh: () => provider.loadEvents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.events.length,
              itemBuilder: (context, index) {
                final event = provider.events[index];
                final dateFormat = DateFormat('dd MMM yyyy', 'es');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.push('/events/${event.id}'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Indicador de estado
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: event.isCompleted
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              event.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.event_rounded,
                              color: event.isCompleted
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Información del evento
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateFormat.format(event.date),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_rounded,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${event.attendanceRecords.length} asistentes',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: event.isCompleted
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.isCompleted ? 'Completado' : 'Pendiente',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: event.isCompleted
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
