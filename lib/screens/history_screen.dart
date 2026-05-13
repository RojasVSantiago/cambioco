import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exchange_rate.dart';
import '../providers/exchange_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<ExchangeProvider>().history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rate = history[index];
                final previous =
                    index < history.length - 1 ? history[index + 1] : null;
                return _HistoryCard(rate: rate, previous: previous);
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aún no hay consultas guardadas.\nVuelve mañana para ver el historial.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
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
    final isUp =
        previous != null ? rate.copRate > previous!.copRate : null;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Fecha
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
                    '€ ${rate.eurRate.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Tasa COP + tendencia
            Row(
              children: [
                Text(
                  '\$ ${_formatCOP(rate.copRate)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                if (isUp != null)
                  Icon(
                    isUp ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                    color: isUp ? Colors.red.shade700 : Colors.green.shade700,
                  ),
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
}