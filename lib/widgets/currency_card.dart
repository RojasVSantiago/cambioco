import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';
import '../config/currency_formatters.dart';

/// Card individual para una moneda — reutilizable para cualquier
/// código soportado por la API, no solo COP/EUR/USD.
class CurrencyCard extends StatelessWidget {
  final ExchangeRate rate;
  final String currencyCode;
  final bool isMain;
  final bool? trend;

  const CurrencyCard({
    super.key,
    required this.rate,
    required this.currencyCode,
    this.isMain = false,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = rate.rateFor(currencyCode);

    return Card(
      elevation: 0,
      color: isMain ? colors.primaryContainer : colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 USD → $currencyCode',
                  style: TextStyle(
                    color: isMain
                        ? colors.onPrimaryContainer.withOpacity(0.7)
                        : colors.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                if (isMain)
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
                      'Principal',
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    formatCurrencyValue(value, currencyCode),
                    style: TextStyle(
                      color: isMain
                          ? colors.onPrimaryContainer
                          : colors.onSurface,
                      fontSize: isMain ? 36 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                if (trend != null) _buildTrendBadge(context, trend!),
              ],
            ),
            if (isMain) ...[
              const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBadge(BuildContext context, bool isUp) {
    final color = isUp ? Colors.red.shade700 : Colors.green.shade700;
    final bgColor =
        isUp ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1);

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

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')} · '
        '${dt.day}/${dt.month}/${dt.year}';
  }
}
