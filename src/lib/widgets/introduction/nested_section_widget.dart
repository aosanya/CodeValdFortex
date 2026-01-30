import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/agency/introduction_section.dart';

/// Widget for rendering nested-type sections with expandable subsections
class NestedSectionWidget extends StatefulWidget {
  final IntroductionSection section;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const NestedSectionWidget({
    super.key,
    required this.section,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  State<NestedSectionWidget> createState() => _NestedSectionWidgetState();
}

class _NestedSectionWidgetState extends State<NestedSectionWidget> {
  final Set<int> _expandedIndices = {};

  @override
  void initState() {
    super.initState();
    // Expand first subsection by default
    _expandedIndices.add(0);
  }

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nestedContent = widget.section.nestedContent;
    final subsections = nestedContent?.sections ?? [];

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
                        widget.section.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.section.required) ...[
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
                if (widget.isEditable) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit section',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (!widget.section.required)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete section',
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            // Subsections
            if (subsections.isEmpty)
              Text(
                'No subsections yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...subsections.asMap().entries.map((entry) {
                final index = entry.key;
                final subsection = entry.value;
                final isExpanded = _expandedIndices.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.space8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _toggleExpanded(index),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.space12),
                          child: Row(
                            children: [
                              Icon(
                                isExpanded
                                    ? Icons.expand_more
                                    : Icons.chevron_right,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppTheme.space8),
                              Expanded(
                                child: Text(
                                  subsection.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.space12 + 32,
                            0,
                            AppTheme.space12,
                            AppTheme.space12,
                          ),
                          width: double.infinity,
                          child: Text(
                            subsection.content,
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
