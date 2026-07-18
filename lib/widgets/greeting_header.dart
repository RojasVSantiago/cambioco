import 'package:flutter/material.dart';

/// Encabezado con saludo dinámico según la hora y fecha formateada.
class GreetingHeader extends StatelessWidget {
  final DateTime now;

  const GreetingHeader({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(now.hour),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(now),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Buenos días 🌤️';
    if (hour < 18) return 'Buenas tardes ☀️';
    return 'Buenas noches 🌙';
  }

  String _formatDate(DateTime dt) {
    const days = [
      '', 'Lunes', 'Martes', 'Miércoles',
      'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${days[dt.weekday]}, ${dt.day} de ${months[dt.month]} de ${dt.year}';
  }
}
