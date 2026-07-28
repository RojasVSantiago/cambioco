import 'package:flutter/material.dart';
import 'currency_badge.dart';

/// Card de una moneda ya seleccionada en ManageCurrenciesScreen,
/// con acciones para marcarla como principal, base, o eliminarla.
class SelectedCurrencyTile extends StatelessWidget {
  final String code;
  final String name;
  final bool isMain;
  final bool isBase;
  final bool canRemove;
  final VoidCallback onSetMain;
  final VoidCallback onSetBase;
  final VoidCallback onRemove;

  const SelectedCurrencyTile({
    super.key,
    required this.code,
    required this.name,
    required this.isMain,
    required this.isBase,
    required this.canRemove,
    required this.onSetMain,
    required this.onSetBase,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            isMain
                ? CurrencyBadge(label: 'Principal', color: colors.primary)
                : TextButton(
                    onPressed: onSetMain,
                    child: const Text('Principal'),
                  ),
            isBase
                ? CurrencyBadge(label: 'Base', color: colors.secondary)
                : TextButton(
                    onPressed: onSetBase,
                    child: const Text('Base'),
                  ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: canRemove ? onRemove : null,
            ),
          ],
        ),
      ),
    );
  }
}
