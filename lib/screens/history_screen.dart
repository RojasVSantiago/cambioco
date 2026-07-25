import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exchange_rate.dart';
import '../providers/exchange_provider.dart';
import '../providers/currency_selection_provider.dart';
import '../config/currency_formatters.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allHistory = context.watch<ExchangeProvider>().history;
    final selection = context.watch<CurrencySelectionProvider>();
    final mainCurrency = selection.mainCurrency;
    final baseCurrency = selection.baseCurrency;
    final colors = Theme.of(context).colorScheme;

    // Solo se muestran entradas calculadas con la base actual — mezclar
    // bases distintas en la misma lista compararía valores no comparables.
    final history =
        allHistory.where((r) => r.baseCurrency == baseCurrency).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  color: colors.surfaceContainerHighest,
                  child: Text(
                    '${history.length} consulta${history.length != 1 ? 's' : ''} guardada${history.length != 1 ? 's' : ''} '
                    '(base $baseCurrency)',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
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
                      return _HistoryCard(
                        rate: rate,
                        previous: previous,
                        currencyCode: mainCurrency,
                      );
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Vuelve mañana para ver\ncómo se mueve el dólar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ExchangeRate rate;
  final ExchangeRate? previous;
  final String currencyCode;

  const _HistoryCard({
    required this.rate,
    required this.currencyCode,
    this.previous,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = rate.rateFor(currencyCode);
    final previousValue = previous?.rateFor(currencyCode);
    final isUp = previousValue != null ? value > previousValue : null;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
                    '1 ${rate.baseCurrency} = $currencyCode',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrencyValue(value, currencyCode),
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
                        formatCurrencyValue(
                          (value - previousValue!).abs(),
                          currencyCode,
                        ),
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
}
