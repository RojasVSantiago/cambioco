import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_selection_provider.dart';
import '../providers/exchange_provider.dart';
import '../widgets/selected_currency_tile.dart';
import '../widgets/currency_search_results.dart';
import '../widgets/error_view.dart';

class ManageCurrenciesScreen extends StatefulWidget {
  const ManageCurrenciesScreen({super.key});

  @override
  State<ManageCurrenciesScreen> createState() =>
      _ManageCurrenciesScreenState();
}

class _ManageCurrenciesScreenState extends State<ManageCurrenciesScreen> {
  late List<String> _draftSelected;
  late String _draftMain;
  late String _draftBase;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final selection = context.read<CurrencySelectionProvider>();
    _draftSelected = List.from(selection.selectedCurrencies);
    _draftMain = selection.mainCurrency;
    _draftBase = selection.baseCurrency;

    Future.microtask(
      () => context.read<ExchangeProvider>().loadSupportedCurrencies(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCurrency(String code) {
    setState(() {
      _draftSelected = [..._draftSelected, code];
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeCurrency(String code) {
    if (code == _draftMain || code == _draftBase) return;
    if (_draftSelected.length <= 2) return;
    setState(() {
      _draftSelected = _draftSelected.where((c) => c != code).toList();
    });
  }

  void _setMain(String code) {
    if (code == _draftBase) return;
    setState(() => _draftMain = code);
  }

  void _setBase(String code) {
    if (code == _draftMain) return;
    setState(() => _draftBase = code);
  }

  Future<void> _confirm() async {
    final selectionProvider = context.read<CurrencySelectionProvider>();

    await selectionProvider.applyChanges(
      selectedCurrencies: _draftSelected,
      mainCurrency: _draftMain,
      baseCurrency: _draftBase,
    );

    await context.read<ExchangeProvider>().refresh(base: _draftBase);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final exchangeProvider = context.watch<ExchangeProvider>();
    final allCurrencies = exchangeProvider.supportedCurrencies;
    final loading = exchangeProvider.loadingCurrencies;
    final loadError = exchangeProvider.supportedCurrenciesError;

    final nameByCode = {for (final c in allCurrencies) c.code: c.name};

    final available = allCurrencies
        .where((c) => !_draftSelected.contains(c.code))
        .where((c) =>
            _searchQuery.isEmpty ||
            c.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar monedas'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError
              ? ErrorView(
                  message: 'No se pudo cargar la lista de monedas.',
                  onRetry: () => context
                      .read<ExchangeProvider>()
                      .loadSupportedCurrencies(),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Monedas seleccionadas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final code in _draftSelected)
                      SelectedCurrencyTile(
                        code: code,
                        name: nameByCode[code] ?? code,
                        isMain: code == _draftMain,
                        isBase: code == _draftBase,
                        canRemove: code != _draftMain &&
                            code != _draftBase &&
                            _draftSelected.length > 2,
                        onSetMain: () => _setMain(code),
                        onSetBase: () => _setBase(code),
                        onRemove: () => _removeCurrency(code),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Agregar moneda',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por código o nombre...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 8),
                    CurrencySearchResults(
                      query: _searchQuery,
                      results: available,
                      onSelect: _addCurrency,
                    ),
                  ],
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (loading || loadError) ? null : _confirm,
            child: const Text('Guardar cambios'),
          ),
        ),
      ),
    );
  }
}
