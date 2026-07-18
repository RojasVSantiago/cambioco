import 'package:flutter/material.dart';

/// Vista de carga mientras se consulta la tasa de cambio.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
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
}
