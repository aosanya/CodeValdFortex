import 'package:flutter/material.dart';

/// Agents list screen (placeholder for MVP-FL-021)
class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.smart_toy,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text('Agents', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'Agents feature will be implemented in MVP-FL-021+',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
