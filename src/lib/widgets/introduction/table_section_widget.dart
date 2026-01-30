import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/agency/introduction_section.dart';

/// Widget for rendering table-type sections with responsive design
class TableSectionWidget extends StatelessWidget {
  final IntroductionSection section;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const TableSectionWidget({
    super.key,
    required this.section,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final tableContent = section.tableContent;
    final headers = tableContent?.headers ?? [];
    final rows = tableContent?.rows ?? [];

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
            // Table
            if (headers.isEmpty || rows.isEmpty)
              Text(
                'No table data yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    columns: headers.map((header) {
                      return DataColumn(
                        label: Text(
                          header,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    rows: rows.map((row) {
                      return DataRow(
                        cells: row.map((cell) {
                          return DataCell(
                            Text(
                              cell,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
