import 'package:flutter/material.dart';

/// Placeholder for RACI Matrix section
class RaciMatrixSection extends StatelessWidget {
  const RaciMatrixSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'RACI Matrix',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Define responsibility matrix (Responsible, Accountable, Consulted, Informed)',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RACI Matrix configuration coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.grid_on),
              label: const Text('Configure RACI Matrix'),
            ),
          ],
        ),
      ),
    );
  }
}
