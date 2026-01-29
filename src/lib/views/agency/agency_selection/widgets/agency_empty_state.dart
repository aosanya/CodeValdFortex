import 'package:flutter/material.dart';

/// Empty state widget shown when no agencies are found
class AgencyEmptyState extends StatelessWidget {
  final String? message;
  final VoidCallback? onCreateAgency;

  const AgencyEmptyState({super.key, this.message, this.onCreateAgency});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 120, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              message ?? 'No agencies found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              onCreateAgency != null
                  ? 'Create your first agency to get started'
                  : 'Try adjusting your search or filters',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (onCreateAgency != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onCreateAgency,
                icon: const Icon(Icons.add),
                label: const Text('Create Agency'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
