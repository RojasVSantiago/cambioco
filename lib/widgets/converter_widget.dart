import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exchange_rate.dart';

class ConverterWidget extends StatefulWidget {
  final ExchangeRate rate;

  const ConverterWidget({super.key, required this.rate});

  @override
  State<ConverterWidget> createState() => _ConverterWidgetState();
}

class _ConverterWidgetState extends State<ConverterWidget> {
  final _controller = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'COP';
  double? _result;

  final List<String> _currencies = ['USD', 'COP', 'EUR'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(
      _controller.text.replaceAll(',', '.'),
    );

    if (input == null) {
      setState(() => _result = null);
      return;
    }

    setState(() {
      _result = widget.rate.convert(
        amount: input,
        from: _fromCurrency,
        to: _toCurrency,
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

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Conversor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Fila: selector origen + campo de texto
            Row(
              children: [
                _buildCurrencyDropdown(
                  value: _fromCurrency,
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                      // Evitar que origen y destino sean iguales
                      if (_fromCurrency == _toCurrency) {
                        _toCurrency = _currencies.firstWhere(
                          (c) => c != _fromCurrency,
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

            // Botón de intercambio centrado
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

            // Fila: selector destino + resultado
            Row(
              children: [
                _buildCurrencyDropdown(
                  value: _toCurrency,
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                      if (_toCurrency == _fromCurrency) {
                        _fromCurrency = _currencies.firstWhere(
                          (c) => c != _toCurrency,
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
                          ? _formatResult(_result!, _toCurrency)
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

  // Dropdown reutilizable para seleccionar moneda
  Widget _buildCurrencyDropdown({
    required String value,
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
          items: _currencies.map((currency) {
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

  // Formatea el resultado según la moneda destino
  String _formatResult(double value, String currency) {
    return switch (currency) {
      'COP' => '\$ ${value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          )}',
      'EUR' => '€ ${value.toStringAsFixed(2)}',
      _ => '\$ ${value.toStringAsFixed(2)}',
    };
  }
}