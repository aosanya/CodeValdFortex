import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../models/agency/introduction_section.dart';
import '../../../providers/introduction_provider.dart';

/// Dialog for refining a section using AI
class AIRefineSectionDialog extends ConsumerStatefulWidget {
  final String agencyId;
  final String agencyName;
  final IntroductionSection section;

  const AIRefineSectionDialog({
    super.key,
    required this.agencyId,
    required this.agencyName,
    required this.section,
  });

  @override
  ConsumerState<AIRefineSectionDialog> createState() =>
      _AIRefineSectionDialogState();
}

class _AIRefineSectionDialogState extends ConsumerState<AIRefineSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _refinementController = TextEditingController();
  bool _isRefining = false;

  @override
  void dispose() {
    _refinementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.space24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.tertiary,
                    Theme.of(context).colorScheme.primary,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_fix_high,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refine Section',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        Text(
                          widget.section.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.space24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'What would you like to improve?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        'Describe how you want to refine this section. AI will intelligently update the content based on your instructions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppTheme.space16),
                      TextFormField(
                        controller: _refinementController,
                        decoration: const InputDecoration(
                          labelText: 'Refinement Instructions',
                          hintText:
                              'e.g., Make it more concise, Add focus on innovation, Remove technical jargon',
                          prefixIcon: Icon(Icons.edit_note),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe what to refine';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.space16),
                      // Current content preview
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.preview,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: AppTheme.space8),
                                Text(
                                  'Current Content',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.space8),
                            Text(
                              _getCurrentContentPreview(),
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isRefining ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  FilledButton.icon(
                    onPressed: _isRefining ? null : _refine,
                    icon: _isRefining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high),
                    label: Text(_isRefining ? 'Refining...' : 'Refine'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentContentPreview() {
    switch (widget.section.type) {
      case SectionType.text:
        return widget.section.textContent ?? 'No content';
      case SectionType.list:
        final items = widget.section.listContent?.items ?? [];
        return items.isEmpty ? 'No items' : items.take(3).join(', ');
      case SectionType.nested:
        final sections = widget.section.nestedContent?.sections ?? [];
        return sections.isEmpty
            ? 'No subsections'
            : sections.map((s) => s.title).take(3).join(', ');
      case SectionType.table:
        final table = widget.section.tableContent;
        return table == null
            ? 'No table data'
            : '${table.headers.length} columns, ${table.rows.length} rows';
    }
  }

  Future<void> _refine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRefining = true);

    final agencyContext = {
      'name': widget.agencyName,
    };

    try {
      await ref.read(introductionProvider(widget.agencyId).notifier).refineSection(
            sectionId: widget.section.id,
            section: widget.section,
            refinementText: _refinementController.text,
            agencyContext: agencyContext,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Section refined successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefining = false);
      }
    }
  }
}
