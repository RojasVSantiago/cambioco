import 'package:flutter/material.dart';
import '../screens/manage_currencies_screen.dart';
import '../screens/converter_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/history_screen.dart';


/// Menú lateral de navegación de CambioCO.
/// [onRecargar] conecta con la lógica de refresco ya existente en HomeScreen.
class AppDrawer extends StatelessWidget {
  final VoidCallback onRecargar;

  const AppDrawer({super.key, required this.onRecargar});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('CambioCO', style: TextStyle(fontSize: 22)),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Recargar'),
              onTap: () {
                Navigator.pop(context);
                onRecargar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Modificar monedas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCurrenciesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Cambio de moneda'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConverterScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
