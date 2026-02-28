import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eventos_unach/shared/utils/constants.dart';

/// Pantalla principal (Menú) de la aplicación.
/// Muestra tres opciones: Crear Evento, Ver Eventos y Generar Diploma.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo / Título
              Icon(
                Icons.school_rounded,
                size: 80,
                color: theme.colorScheme.onPrimary,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestión de Eventos Universitarios',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 60),

              // Botones del menú
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _MenuCard(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Crear Evento',
                        subtitle:
                            'Configura un nuevo evento con fecha y horario',
                        color: const Color(0xFF2E7D32),
                        onTap: () => context.push('/create-event'),
                      ),
                      const SizedBox(height: 16),
                      _MenuCard(
                        icon: Icons.event_note_rounded,
                        title: 'Eventos Guardados',
                        subtitle: 'Ver y gestionar tus eventos creados',
                        color: const Color(0xFF00695C),
                        onTap: () => context.push('/events'),
                      ),
                      const SizedBox(height: 16),
                      _MenuCard(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Generar Diploma',
                        subtitle: 'Crea diplomas para alumnos asistentes',
                        color: const Color(0xFF0D47A1),
                        onTap: () => context.push('/diploma'),
                      ),
                    ],
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

/// Tarjeta de menú reutilizable con ícono, título y subtítulo.
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
