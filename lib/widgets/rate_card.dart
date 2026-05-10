import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exchange_rate.dart';

class RateCard extends StatelessWidget {
  final ExchangeRate rate;
  final bool? trend; // true = subió, false = bajó, null = sin dato anterior

  const RateCard({super.key, required this.rate, this.trend});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final copFormat = NumberFormat('#,##0.00', 'es_CO');

    return Card(
      elevation: 0,
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etiqueta superior
            Text(
              '1 Dólar estadounidense',
              style: TextStyle(
                color: colors.onPrimaryContainer.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Tasa principal + indicador de tendencia
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$ ${copFormat.format(rate.copRate)}',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (trend != null) _buildTrendIcon(trend!),
              ],
            ),
            const SizedBox(height: 4),

            // Moneda
            Text(
              'Pesos colombianos (COP)',
              style: TextStyle(
                color: colors.onPrimaryContainer.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const Divider(height: 32),

            // Fila EUR
            _buildSecondaryRate(
              label: '1 USD en Euros',
              value: '€ ${rate.eurRate.toStringAsFixed(4)}',
              context: context,
            ),

            const SizedBox(height: 8),

            // Hora de actualización
            Text(
              'Actualizado: ${_formatTime(rate.fetchedAt)}',
              style: TextStyle(
                color: colors.onPrimaryContainer.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIcon(bool isUp) {
    return Icon(
      isUp ? Icons.trending_up : Icons.trending_down,
      color: isUp ? Colors.red.shade700 : Colors.green.shade700,
      size: 28,
    );
  }

  Widget _buildSecondaryRate({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onPrimaryContainer.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onPrimaryContainer,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} · '
        '${dt.day}/${dt.month}/${dt.year}';
  }
}