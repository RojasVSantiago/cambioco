import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../widgets/rate_card.dart';
import '../widgets/converter_widget.dart';
import '../widgets/app_drawer.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/greeting_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ExchangeProvider>().loadRate(),
    );
  }

  // Recarga compartida entre el botón de la AppBar y el Drawer
  void _loadData() {
    context.read<ExchangeProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () => context.read<ExchangeProvider>().refresh(),
        child: Consumer<ExchangeProvider>(
          builder: (context, provider, _) {
            return switch (provider.status) {
              ExchangeStatus.initial ||
              ExchangeStatus.loading =>
                const LoadingView(),
              ExchangeStatus.error => ErrorView(
                  message: provider.errorMessage,
                  onRetry: () => provider.loadRate(),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        GreetingHeader(now: now),
        RateCard(
          rate: provider.currentRate!,
          trend: provider.copTrend,
        ),
        const SizedBox(height: 12),
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
