import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/agency/introduction_section.dart';

/// Widget for rendering list-type sections
class ListSectionWidget extends StatelessWidget {
  final IntroductionSection section;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;
  final bool isNumbered;

  const ListSectionWidget({
    super.key,
    required this.section,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
    this.isNumbered = false,
  });

  @override
  Widget build(BuildContext context) {
    final listContent = section.listContent;
    final items = listContent?.items ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.space16),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        section.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (section.required) ...[
                        const SizedBox(width: AppTheme.space8),
                        Chip(
                          label: const Text(
                            'Required',
                            style: TextStyle(fontSize: 10),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEditable) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit section',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (!section.required)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete section',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            // List items
            if (items.isEmpty)
              Text(
                'No items yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          isNumbered ? '${index + 1}.' : '•',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
