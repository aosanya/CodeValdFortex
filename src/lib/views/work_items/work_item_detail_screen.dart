import 'package:flutter/material.dart';

/// Work Item detail/edit screen (placeholder for MVP-FL-008)
class WorkItemDetailScreen extends StatelessWidget {
  const WorkItemDetailScreen({super.key, this.id});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Create Work Item' : 'Work Item Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              id == null ? 'Create Work Item' : 'Work Item: $id',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Work Item detail/edit will be implemented in MVP-FL-008',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
