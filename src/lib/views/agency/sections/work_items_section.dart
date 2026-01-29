import 'package:flutter/material.dart';

/// Placeholder for Work Items section
class WorkItemsSection extends StatelessWidget {
  const WorkItemsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Work Items',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create and manage tasks, issues, and deliverables for your agency',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Work Items configuration coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Work Item'),
            ),
          ],
        ),
      ),
    );
  }
}
