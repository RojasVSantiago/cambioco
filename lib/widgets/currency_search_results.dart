import 'package:flutter/material.dart';
import '../models/currency_info.dart';

/// Lista de resultados de búsqueda para agregar una moneda nueva
/// en ManageCurrenciesScreen. Limita a 20 resultados visibles a la vez
/// para no renderizar listas largas sin necesidad.
class CurrencySearchResults extends StatelessWidget {
  final String query;
  final List<CurrencyInfo> results;
  final void Function(String code) onSelect;

  const CurrencySearchResults({
    super.key,
    required this.query,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();

    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No se encontraron monedas.'),
      );
    }

    return Column(
      children: results
          .take(20)
          .map(
            (c) => ListTile(
              title: Text('${c.code} — ${c.name}'),
              trailing: const Icon(Icons.add),
              onTap: () => onSelect(c.code),
            ),
          )
          .toList(),
    );
  }
}
