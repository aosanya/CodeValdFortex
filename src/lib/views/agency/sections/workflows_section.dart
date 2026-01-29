import 'package:flutter/material.dart';

/// Placeholder for Workflows section
class WorkflowsSection extends StatelessWidget {
  const WorkflowsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Workflows',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Design and configure agency workflows and automation',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Workflows configuration coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Workflow'),
            ),
          ],
        ),
      ),
    );
  }
}
