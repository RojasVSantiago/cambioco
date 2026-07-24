import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/exchange_rate.dart';
import '../providers/currency_selection_provider.dart';
import '../config/currency_formatters.dart';

class ConverterWidget extends StatefulWidget {
  final ExchangeRate rate;

  const ConverterWidget({super.key, required this.rate});

  @override
  State<ConverterWidget> createState() => _ConverterWidgetState();
}

class _ConverterWidgetState extends State<ConverterWidget> {
  final _controller = TextEditingController();
  String? _fromCurrency;
  String? _toCurrency;
  double? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Asegura que _fromCurrency/_toCurrency sean válidos según la selección
  // actual del usuario — se corrige solo si alguna moneda ya no existe
  // en la lista (ej. el usuario la eliminó en Modificar monedas).
  void _ensureValidSelection(List<String> currencies) {
    if (currencies.isEmpty) return;

    if (_fromCurrency == null || !currencies.contains(_fromCurrency)) {
      _fromCurrency = currencies.first;
    }
    if (_toCurrency == null ||
        !currencies.contains(_toCurrency) ||
        _toCurrency == _fromCurrency) {
      _toCurrency = currencies.firstWhere(
        (c) => c != _fromCurrency,
        orElse: () => currencies.first,
      );
    }
  }

  void _convert() {
    final input = double.tryParse(
      _controller.text.replaceAll(',', '.'),
    );

    if (input == null || _fromCurrency == null || _toCurrency == null) {
      setState(() => _result = null);
      return;
    }

    setState(() {
      _result = widget.rate.convert(
        amount: input,
        from: _fromCurrency!,
        to: _toCurrency!,
      );
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _result = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currencies = context.watch<CurrencySelectionProvider>().selectedCurrencies;

    if (currencies.length < 2) {
      return Card(
        elevation: 0,
        color: colors.surfaceContainerHighest,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Agrega al menos 2 monedas en "Modificar monedas" '
            'para usar el conversor.',
          ),
        ),
      );
    }

    _ensureValidSelection(currencies);

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildCurrencyDropdown(
                  value: _fromCurrency!,
                  currencies: currencies,
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                      if (_fromCurrency == _toCurrency) {
                        _toCurrency = currencies.firstWhere(
                          (c) => c != _fromCurrency,
                          orElse: () => currencies.first,
                        );
                      }
                      _result = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => _convert(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: IconButton.filled(
                onPressed: _swapCurrencies,
                icon: const Icon(Icons.swap_vert),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCurrencyDropdown(
                  value: _toCurrency!,
                  currencies: currencies,
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                      if (_toCurrency == _fromCurrency) {
                        _fromCurrency = currencies.firstWhere(
                          (c) => c != _toCurrency,
                          orElse: () => currencies.first,
                        );
                      }
                      _result = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result != null
                          ? formatCurrencyValue(_result!, _toCurrency!)
                          : '—',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _result != null
                            ? colors.primary
                            : colors.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required List<String> currencies,
    required void Function(String?) onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: currencies.map((currency) {
            return DropdownMenuItem(
              value: currency,
              child: Text(
                currency,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
