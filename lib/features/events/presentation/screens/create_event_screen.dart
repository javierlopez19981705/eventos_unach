import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';
import 'package:eventos_unach/features/events/data/models/day_schedule_model.dart';

/// Pantalla para crear un nuevo evento.
/// Incluye formulario con nombre, rango de fechas y horarios por día.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  bool _isSaving = false;
  bool _sameScheduleForAll = true;

  // Horario global (cuando _sameScheduleForAll = true)
  TimeOfDay _globalEntryTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _globalExitTime = const TimeOfDay(hour: 17, minute: 0);

  // Horarios individuales por día (cuando _sameScheduleForAll = false)
  List<_DayScheduleEntry> _daySchedules = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Genera la lista de días entre las fechas seleccionadas
  void _generateDaySchedules() {
    if (_selectedDate == null || _selectedEndDate == null) return;

    final start = _selectedDate!;
    final end = _selectedEndDate!;

    if (end.isBefore(start)) return;

    final days = end.difference(start).inDays + 1;
    _daySchedules = List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      // Intentar mantener el horario existente si el día ya estaba
      final existing = _daySchedules.where(
        (s) =>
            s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day,
      );
      if (existing.isNotEmpty) {
        return existing.first;
      }
      return _DayScheduleEntry(
        date: date,
        entryTime: const TimeOfDay(hour: 8, minute: 0),
        exitTime: const TimeOfDay(hour: 17, minute: 0),
      );
    });
  }

  /// Muestra el selector de fecha de inicio
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Auto-ajustar fecha fin si es anterior
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked;
        }
        _generateDaySchedules();
      });
    }
  }

  /// Muestra el selector de fecha de finalización
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedDate ?? DateTime.now(),
      firstDate: _selectedDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
        _generateDaySchedules();
      });
    }
  }

  /// Selector de hora reutilizable
  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return showTimePicker(context: context, initialTime: initial);
  }

  /// Construye la lista de DaySchedule para guardar
  List<DaySchedule> _buildDailySchedules() {
    if (_sameScheduleForAll) {
      // Aplicar el mismo horario a todos los días
      final start = _selectedDate!;
      final end = _selectedEndDate!;
      final days = end.difference(start).inDays + 1;
      return List.generate(days, (i) {
        final date = start.add(Duration(days: i));
        return DaySchedule(
          date: date,
          entryTimeMinutes: DaySchedule.timeOfDayToMinutes(_globalEntryTime),
          exitTimeMinutes: DaySchedule.timeOfDayToMinutes(_globalExitTime),
        );
      });
    } else {
      return _daySchedules.map((s) {
        return DaySchedule(
          date: s.date,
          entryTimeMinutes: DaySchedule.timeOfDayToMinutes(s.entryTime),
          exitTimeMinutes: DaySchedule.timeOfDayToMinutes(s.exitTime),
        );
      }).toList();
    }
  }

  /// Valida los horarios
  String? _validateSchedules() {
    if (_sameScheduleForAll) {
      final entryMin = DaySchedule.timeOfDayToMinutes(_globalEntryTime);
      final exitMin = DaySchedule.timeOfDayToMinutes(_globalExitTime);
      if (exitMin <= entryMin) {
        return 'La hora de fin debe ser mayor a la hora de inicio';
      }
    } else {
      for (final s in _daySchedules) {
        final entryMin = DaySchedule.timeOfDayToMinutes(s.entryTime);
        final exitMin = DaySchedule.timeOfDayToMinutes(s.exitTime);
        if (exitMin <= entryMin) {
          final dateStr = DateFormat('dd/MM/yyyy').format(s.date);
          return 'El horario del día $dateStr es inválido: la hora de fin debe ser mayor a la de inicio';
        }
      }
    }
    return null;
  }

  /// Valida y guarda el evento
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona las fechas del evento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scheduleError = _validateSchedules();
    if (scheduleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scheduleError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<EventProvider>();
    final success = await provider.createEvent(
      name: _nameController.text.trim(),
      date: _selectedDate!,
      dateEnd: _selectedEndDate!,
      dailySchedules: _buildDailySchedules(),
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Evento creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al crear evento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Evento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícono decorativo
              Icon(
                Icons.event_available_rounded,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 24),

              // Campo: Nombre del evento
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Evento',
                  hintText: 'Ej: Congreso de Tecnología 2026',
                  prefixIcon: Icon(Icons.event_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del evento es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de inicio
              _DateTimeSelector(
                icon: Icons.calendar_today_rounded,
                label: 'Fecha de Inicio',
                value: _selectedDate != null
                    ? dateFormat.format(_selectedDate!)
                    : null,
                placeholder: 'Seleccionar fecha',
                onTap: _selectDate,
              ),
              const SizedBox(height: 20),

              // Campo: Fecha de finalización
              _DateTimeSelector(
                icon: Icons.calendar_today_rounded,
                label: 'Fecha de Finalización',
                value: _selectedEndDate != null
                    ? dateFormat.format(_selectedEndDate!)
                    : null,
                placeholder: 'Seleccionar fecha',
                onTap: _selectEndDate,
              ),
              const SizedBox(height: 24),

              // Sección de horarios
              if (_selectedDate != null && _selectedEndDate != null) ...[
                // Toggle: mismo horario para todos
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Mismo horario para todos los días',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _sameScheduleForAll
                          ? 'Se aplicará el mismo horario a todos los días'
                          : 'Configura un horario diferente por día',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    value: _sameScheduleForAll,
                    onChanged: (v) => setState(() => _sameScheduleForAll = v),
                    activeTrackColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                if (_sameScheduleForAll) ...[
                  // Horario global
                  _buildTimeRow(
                    label: 'Horario para todos los días',
                    entryTime: _globalEntryTime,
                    exitTime: _globalExitTime,
                    onEntryTap: () async {
                      final t = await _pickTime(_globalEntryTime);
                      if (t != null) setState(() => _globalEntryTime = t);
                    },
                    onExitTap: () async {
                      final t = await _pickTime(_globalExitTime);
                      if (t != null) setState(() => _globalExitTime = t);
                    },
                  ),
                ] else ...[
                  // Horarios individuales por día
                  ..._daySchedules.asMap().entries.map((entry) {
                    final index = entry.key;
                    final schedule = entry.value;
                    final dayLabel =
                        DateFormat('EEEE dd/MM', 'es').format(schedule.date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTimeRow(
                        label: dayLabel,
                        entryTime: schedule.entryTime,
                        exitTime: schedule.exitTime,
                        onEntryTap: () async {
                          final t = await _pickTime(schedule.entryTime);
                          if (t != null) {
                            setState(() {
                              _daySchedules[index] =
                                  schedule.copyWith(entryTime: t);
                            });
                          }
                        },
                        onExitTap: () async {
                          final t = await _pickTime(schedule.exitTime);
                          if (t != null) {
                            setState(() {
                              _daySchedules[index] =
                                  schedule.copyWith(exitTime: t);
                            });
                          }
                        },
                      ),
                    );
                  }),
                ],
              ],

              const SizedBox(height: 24),

              // Botón crear
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _isSaving ? 'Guardando...' : 'Crear Evento',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye una fila de horario (inicio / fin)
  Widget _buildTimeRow({
    required String label,
    required TimeOfDay entryTime,
    required TimeOfDay exitTime,
    required VoidCallback onEntryTap,
    required VoidCallback onExitTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    icon: Icons.login_rounded,
                    label: 'Inicio',
                    time: entryTime.format(context),
                    onTap: onEntryTap,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TimeChip(
                    icon: Icons.logout_rounded,
                    label: 'Fin',
                    time: exitTime.format(context),
                    onTap: onExitTap,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Entrada de horario por día (estado interno del form)
class _DayScheduleEntry {
  final DateTime date;
  TimeOfDay entryTime;
  TimeOfDay exitTime;

  _DayScheduleEntry({
    required this.date,
    required this.entryTime,
    required this.exitTime,
  });

  _DayScheduleEntry copyWith({TimeOfDay? entryTime, TimeOfDay? exitTime}) {
    return _DayScheduleEntry(
      date: date,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
    );
  }
}

/// Chip interactivo para mostrar/seleccionar hora
class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final VoidCallback onTap;
  final Color color;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget selector reutilizable para fecha.
class _DateTimeSelector extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _DateTimeSelector({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value ?? placeholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: value != null ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
