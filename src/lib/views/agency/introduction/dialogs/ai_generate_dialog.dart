import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../providers/introduction_provider.dart';

/// Dialog for generating introduction using AI
class AIGenerateDialog extends ConsumerStatefulWidget {
  final String agencyId;
  final String agencyName;

  const AIGenerateDialog({
    super.key,
    required this.agencyId,
    required this.agencyName,
  });

  @override
  ConsumerState<AIGenerateDialog> createState() => _AIGenerateDialogState();
}

class _AIGenerateDialogState extends ConsumerState<AIGenerateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _keywordsController = TextEditingController();
  String _selectedTemplate = 'genesis';
  bool _isGenerating = false;

  @override
  void dispose() {
    _keywordsController.dispose();
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
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Text(
                    'Generate with AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
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
                        'Describe your agency',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        'Enter keywords or phrases that describe your agency\'s purpose, capabilities, and target audience. AI will generate a complete introduction based on your input.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppTheme.space16),
                      TextFormField(
                        controller: _keywordsController,
                        decoration: const InputDecoration(
                          labelText: 'Keywords',
                          hintText:
                              'e.g., software development, automation, AI agents',
                          helperText: 'Separate keywords with commas',
                          prefixIcon: Icon(Icons.label),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter at least one keyword';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.space24),
                      Text(
                        'Template',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.space8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'genesis',
                            label: Text('Genesis'),
                            icon: Icon(Icons.stars, size: 16),
                          ),
                          ButtonSegment(
                            value: 'minimal',
                            label: Text('Minimal'),
                            icon: Icon(Icons.bolt, size: 16),
                          ),
                        ],
                        selected: {_selectedTemplate},
                        onSelectionChanged: (Set<String> selected) {
                          setState(() {
                            _selectedTemplate = selected.first;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        _selectedTemplate == 'genesis'
                            ? 'Comprehensive 6-section introduction'
                            : 'Streamlined 3-section introduction',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                    onPressed: _isGenerating
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  FilledButton.icon(
                    onPressed: _isGenerating ? null : _generate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    final keywords = _keywordsController.text
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    final agencyContext = {
      'name': widget.agencyName,
    };

    try {
      await ref.read(introductionProvider(widget.agencyId).notifier).generateIntroduction(
            keywords: keywords,
            template: _selectedTemplate,
            agencyContext: agencyContext,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Introduction generated successfully!'),
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
        setState(() => _isGenerating = false);
      }
    }
  }
}
