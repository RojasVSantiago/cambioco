import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';
import '../widgets/rate_card.dart';
import '../widgets/converter_widget.dart';
import 'history_screen.dart';

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
          // Botón de historial
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
          ),
          // Botón de refrescar
          Consumer<ExchangeProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: provider.status == ExchangeStatus.loading
                    ? null
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
              ExchangeStatus.initial ||
              ExchangeStatus.loading =>
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
  final now = DateTime.now();
  final greeting = _getGreeting(now.hour);

  return ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    children: [
      // Saludo y fecha
      Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(now),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),

      // Tarjeta de tasa
      RateCard(
        rate: provider.currentRate!,
        trend: provider.copTrend,
      ),
      const SizedBox(height: 12),

      // Conversor
      ConverterWidget(rate: provider.currentRate!),
      const SizedBox(height: 16),

      // Atribución de fuente
      Center(
        child: Text(
          'Tasas proporcionadas por ExchangeRate-API',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    ],
  );
}

String _getGreeting(int hour) {
  if (hour < 12) return 'Buenos días 🌤️';
  if (hour < 18) return 'Buenas tardes ☀️';
  return 'Buenas noches 🌙';
}

String _formatDate(DateTime dt) {
  const days = [
    '', 'Lunes', 'Martes', 'Miércoles',
    'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];
  const months = [
    '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
  ];
  return '${days[dt.weekday]}, ${dt.day} de ${months[dt.month]} de ${dt.year}';
}
}
