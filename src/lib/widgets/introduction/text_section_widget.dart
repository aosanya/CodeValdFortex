import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/agency/introduction_section.dart';

/// Widget for rendering text-type sections
class TextSectionWidget extends StatelessWidget {
  final IntroductionSection section;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const TextSectionWidget({
    super.key,
    required this.section,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final textContent = section.textContent ?? '';

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
            // Content
            Text(
              textContent,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
