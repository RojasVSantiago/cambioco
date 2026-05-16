import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exchange_rate.dart';
import '../providers/exchange_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ExchangeProvider>().history;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                // Encabezado con conteo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: colors.surfaceContainerHighest,
                  child: Text(
                    '${history.length} consulta${history.length != 1 ? 's' : ''} guardada${history.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),

                // Lista de entradas
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final rate = history[index];
                      final previous = index < history.length - 1
                          ? history[index + 1]
                          : null;
                      return _HistoryCard(rate: rate, previous: previous);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay consultas guardadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve mañana para ver\ncómo se mueve el dólar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ExchangeRate rate;
  final ExchangeRate? previous;

  const _HistoryCard({required this.rate, this.previous});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUp = previous != null ? rate.copRate > previous!.copRate : null;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Ícono de calendario
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 20,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 14),

            // Fecha y EUR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(rate.fetchedAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '1 USD = € ${rate.eurRate.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            // COP + tendencia
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$ ${_formatCOP(rate.copRate)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUp != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 13,
                        color: isUp
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatDiff(rate.copRate, previous!.copRate),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUp
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatCOP(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  // Muestra la diferencia vs el día anterior
  String _formatDiff(double current, double previous) {
    final diff = (current - previous).abs();
    return '\$ ${diff.toStringAsFixed(0)}';
  }
}