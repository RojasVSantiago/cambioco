import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/exchange_provider.dart';
import 'providers/currency_selection_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CambioCOApp());
}

class CambioCOApp extends StatelessWidget {
  const CambioCOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExchangeProvider()),
        ChangeNotifierProvider(
          create: (_) => CurrencySelectionProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'CambioCO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF003087), // Azul bandera Colombia
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
