import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exchange_rate.dart';

class RateCard extends StatelessWidget {
  final ExchangeRate rate;
  final bool? trend;

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
            // Encabezado con etiqueta y badge de actualizado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 Dólar estadounidense',
                  style: TextStyle(
                    color: colors.onPrimaryContainer.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'En vivo',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tasa principal + tendencia
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '\$ ${copFormat.format(rate.copRate)}',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                if (trend != null) _buildTrendBadge(context, trend!),
              ],
            ),
            const SizedBox(height: 2),

            Text(
              'Pesos colombianos (COP)',
              style: TextStyle(
                color: colors.onPrimaryContainer.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const Divider(height: 28),

            // Tasas secundarias
            _buildSecondaryRate(
              context: context,
              label: '1 USD → EUR',
              value: '€ ${rate.eurRate.toStringAsFixed(4)}',
            ),
            const SizedBox(height: 6),
            _buildSecondaryRate(
              context: context,
              label: '1 EUR → COP',
              value: '\$ ${NumberFormat('#,##0', 'es_CO').format(rate.copRate / rate.eurRate)}',
            ),
            const SizedBox(height: 12),

            // Hora de actualización
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: colors.onPrimaryContainer.withOpacity(0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  'Actualizado: ${_formatTime(rate.fetchedAt)}',
                  style: TextStyle(
                    color: colors.onPrimaryContainer.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(BuildContext context, bool isUp) {
    final color = isUp ? Colors.red.shade700 : Colors.green.shade700;
    final bgColor = isUp
        ? Colors.red.withOpacity(0.1)
        : Colors.green.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isUp ? 'Subió' : 'Bajó',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryRate({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onPrimaryContainer.withOpacity(0.6),
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