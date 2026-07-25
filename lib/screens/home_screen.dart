import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../providers/currency_selection_provider.dart';
import '../widgets/currency_card.dart';
import '../widgets/converter_widget.dart';
import '../widgets/app_drawer.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/greeting_header.dart';
import 'manage_currencies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _initialLoadTriggered = false;

  void _loadData() {
    final base = context.read<CurrencySelectionProvider>().baseCurrency;
    context.read<ExchangeProvider>().refresh(base: base);
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<CurrencySelectionProvider>();

    // Espera a que CurrencySelectionProvider termine de leer SharedPreferences
    // antes de la primera consulta — evita usar la base por defecto (USD)
    // si el usuario ya había guardado otra base en una sesión anterior.
    if (selection.isLoaded && !_initialLoadTriggered) {
      _initialLoadTriggered = true;
      Future.microtask(
        () => context
            .read<ExchangeProvider>()
            .loadRate(base: selection.baseCurrency),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CambioCO'),
        centerTitle: true,
        actions: [
          Consumer<ExchangeProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.status == ExchangeStatus.loading
                    ? null
                    : _loadData,
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(onRecargar: _loadData),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ManageCurrenciesScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Monedas'),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_loadData),
        child: Consumer<ExchangeProvider>(
          builder: (context, provider, _) {
            return switch (provider.status) {
              ExchangeStatus.initial ||
              ExchangeStatus.loading =>
                const LoadingView(),
              ExchangeStatus.error => ErrorView(
                  message: provider.errorMessage,
                  onRetry: _loadData,
                ),
              ExchangeStatus.success => _buildContent(provider),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(ExchangeProvider provider) {
    final now = DateTime.now();
    final selection = context.watch<CurrencySelectionProvider>();
    final mainCurrency = selection.mainCurrency;
    final baseCurrency = provider.currentRate!.baseCurrency;

    final orderedCodes = [
      mainCurrency,
      ...selection.selectedCurrencies.where((c) => c != mainCurrency),
    ].where((c) => c != baseCurrency).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        GreetingHeader(now: now),
        for (final code in orderedCodes) ...[
          CurrencyCard(
            rate: provider.currentRate!,
            currencyCode: code,
            isMain: code == mainCurrency,
            trend: provider.trendFor(code),
          ),
          const SizedBox(height: 12),
        ],
        ConverterWidget(rate: provider.currentRate!),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Tasas proporcionadas por ExchangeRate-API',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
