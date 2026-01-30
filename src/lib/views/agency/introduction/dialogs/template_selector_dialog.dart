import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/introduction_provider.dart';

/// Dialog for selecting and applying introduction templates
class TemplateSelectorDialog extends ConsumerWidget {
  final String agencyId;

  const TemplateSelectorDialog({
    super.key,
    required this.agencyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider(agencyId));

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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Text(
                    'Choose Template',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: templatesAsync.when(
                data: (templates) => _buildTemplateList(context, ref, templates),
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppTheme.space48),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(AppTheme.space24),
                  child: Center(
                    child: Text(
                      'Error loading templates: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(
    BuildContext context,
    WidgetRef ref,
    List<String> templates,
  ) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppTheme.space16),
      children: templates.map((template) {
        return _buildTemplateCard(context, ref, template);
      }).toList(),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    WidgetRef ref,
    String template,
  ) {
    final info = _getTemplateInfo(template);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      child: InkWell(
        onTap: () => _applyTemplate(context, ref, template),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space12),
                    decoration: BoxDecoration(
                      color: info.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(info.icon, color: info.color),
                  ),
                  const SizedBox(width: AppTheme.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${info.sectionCount} sections',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                info.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (info.sections.isNotEmpty) ...[
                const SizedBox(height: AppTheme.space12),
                Wrap(
                  spacing: AppTheme.space8,
                  runSpacing: AppTheme.space8,
                  children: info.sections.map((section) {
                    return Chip(
                      label: Text(
                        section,
                        style: const TextStyle(fontSize: 11),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _applyTemplate(BuildContext context, WidgetRef ref, String template) {
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Template'),
        content: Text(
          'This will replace your current introduction with the ${_getTemplateInfo(template).name} template. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(introductionProvider(agencyId).notifier)
                  .applyTemplate(template);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  TemplateInfo _getTemplateInfo(String template) {
    switch (template.toLowerCase()) {
      case 'genesis':
        return TemplateInfo(
          name: 'Genesis Template',
          description:
              'Comprehensive 6-section introduction covering all aspects of your agency',
          sectionCount: 6,
          icon: Icons.stars,
          color: Colors.purple,
          sections: [
            'Overview',
            'Key Capabilities',
            'Target Audience',
            'Core Principles',
            'Service Offerings',
            'Getting Started',
          ],
        );
      case 'minimal':
        return TemplateInfo(
          name: 'Minimal Template',
          description: 'Streamlined 3-section introduction for quick setup',
          sectionCount: 3,
          icon: Icons.bolt,
          color: Colors.orange,
          sections: ['About', 'What We Offer', 'Contact'],
        );
      case 'custom':
        return TemplateInfo(
          name: 'Custom Template',
          description: 'Start from scratch with your own structure',
          sectionCount: 0,
          icon: Icons.edit,
          color: Colors.blue,
          sections: [],
        );
      default:
        return TemplateInfo(
          name: template.toUpperCase(),
          description: 'Custom template',
          sectionCount: 0,
          icon: Icons.description,
          color: Colors.grey,
          sections: [],
        );
    }
  }
}

class TemplateInfo {
  final String name;
  final String description;
  final int sectionCount;
  final IconData icon;
  final Color color;
  final List<String> sections;

  TemplateInfo({
    required this.name,
    required this.description,
    required this.sectionCount,
    required this.icon,
    required this.color,
    required this.sections,
  });
}
