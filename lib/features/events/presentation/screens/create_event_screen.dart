import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:eventos_unach/features/events/domain/event_provider.dart';

/// Pantalla para crear un nuevo evento.
/// Incluye formulario con nombre, fecha, hora de entrada y hora de salida.
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
  TimeOfDay? _entryTime;
  TimeOfDay? _exitTime;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Muestra el selector de fecha
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Muestra el selector de fecha de finalización
  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() => _selectedEndDate = picked);
    }
  }

  /// Muestra el selector de hora de entrada
  Future<void> _selectEntryTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() => _entryTime = picked);
    }
  }

  /// Muestra el selector de hora de salida
  Future<void> _selectExitTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      setState(() => _exitTime = picked);
    }
  }

  /// Valida y guarda el evento
  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _entryTime == null || _exitTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
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
      entryTime: _entryTime!,
      exitTime: _exitTime!,
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

              // Campo: Fecha
              _DateTimeSelector(
                icon: Icons.calendar_today_rounded,
                label: 'Fecha del Evento',
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
              const SizedBox(height: 20),

              // Campo: Hora de entrada
              _DateTimeSelector(
                icon: Icons.login_rounded,
                label: 'Hora de Entrada',
                value: _entryTime?.format(context),
                placeholder: 'Seleccionar hora',
                onTap: _selectEntryTime,
              ),
              const SizedBox(height: 20),

              // Campo: Hora de salida
              _DateTimeSelector(
                icon: Icons.logout_rounded,
                label: 'Hora de Salida',
                value: _exitTime?.format(context),
                placeholder: 'Seleccionar hora',
                onTap: _selectExitTime,
              ),
              const SizedBox(height: 40),

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
}

/// Widget selector reutilizable para fecha y hora.
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
