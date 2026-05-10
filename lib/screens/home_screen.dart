import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../widgets/rate_card.dart';
import '../widgets/converter_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga la tasa al abrir la pantalla por primera vez
    Future.microtask(
      () => context.read<ExchangeProvider>().loadRate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CambioCO'),
        centerTitle: true,
        actions: [
          // Botón de refrescar manual
          Consumer<ExchangeProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.status == ExchangeStatus.loading
                    ? null // Desactivado mientras carga
                    : () => provider.refresh(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ExchangeProvider>().refresh(),
        child: Consumer<ExchangeProvider>(
          builder: (context, provider, _) {
            return switch (provider.status) {
              ExchangeStatus.initial || ExchangeStatus.loading =>
                _buildLoading(),
              ExchangeStatus.error => _buildError(
                  provider.errorMessage,
                  () => provider.loadRate(),
                ),
              ExchangeStatus.success => _buildContent(provider),
            };
          },
        ),
      ),
    );
  }

  // Pantalla de carga
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Consultando tasas de cambio...'),
        ],
      ),
    );
  }

  // Pantalla de error
  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }

  // Contenido principal
  Widget _buildContent(ExchangeProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RateCard(
          rate: provider.currentRate!,
          trend: provider.copTrend,
        ),
        const SizedBox(height: 16),
        // Widget conversor 
        ConverterWidget(rate: provider.currentRate!),
      ],
    );
  }
}