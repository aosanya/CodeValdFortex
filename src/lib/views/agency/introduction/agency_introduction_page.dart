import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../models/agency/introduction_section.dart';
import '../../providers/introduction_provider.dart';
import '../../widgets/introduction/text_section_widget.dart';
import '../../widgets/introduction/list_section_widget.dart';
import '../../widgets/introduction/nested_section_widget.dart';
import '../../widgets/introduction/table_section_widget.dart';

/// Main page for managing agency introductions
class AgencyIntroductionPage extends ConsumerStatefulWidget {
  final String agencyId;
  final String agencyName;

  const AgencyIntroductionPage({
    super.key,
    required this.agencyId,
    required this.agencyName,
  });

  @override
  ConsumerState<AgencyIntroductionPage> createState() =>
      _AgencyIntroductionPageState();
}

class _AgencyIntroductionPageState
    extends ConsumerState<AgencyIntroductionPage> {
  @override
  void initState() {
    super.initState();
    // Load introduction when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(introductionProvider(widget.agencyId).notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(introductionProvider(widget.agencyId));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, state),
      floatingActionButton: state.introduction != null
          ? _buildFAB(context, state)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.agencyName),
          Text(
            'Introduction',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
                ),
          ),
        ],
      ),
      actions: [
        // Template selector
        IconButton(
          icon: const Icon(Icons.assignment),
          onPressed: () => _showTemplateSelector(context),
          tooltip: 'Apply Template',
        ),
        // AI Generate
        IconButton(
          icon: const Icon(Icons.auto_awesome),
          onPressed: () => _showAIGenerateDialog(context),
          tooltip: 'Generate with AI',
        ),
        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(introductionProvider(widget.agencyId).notifier).refresh();
          },
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, IntroductionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'Error loading introduction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              state.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space24),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(introductionProvider(widget.agencyId).notifier)
                    .refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.introduction == null) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(introductionProvider(widget.agencyId).notifier).refresh(),
      child: _buildSectionList(context, state),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 96,
            color: Theme.of(context).colorScheme.primary.withAlpha(128),
          ),
          const SizedBox(height: AppTheme.space24),
          Text(
            'No Introduction Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            'Create an introduction to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTheme.space32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _showTemplateSelector(context),
                icon: const Icon(Icons.assignment),
                label: const Text('Apply Template'),
              ),
              const SizedBox(width: AppTheme.space16),
              OutlinedButton.icon(
                onPressed: () => _showAIGenerateDialog(context),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate with AI'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionList(BuildContext context, IntroductionState state) {
    final sections = state.introduction!.orderedSections;

    if (sections.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: sections.length + 1, // +1 for summary card
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(context, state);
        }

        final section = sections[index - 1];
        return _buildSectionWidget(context, section);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, IntroductionState state) {
    final intro = state.introduction!;
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.space16),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppTheme.space8),
                Text(
                  'Introduction Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),
            Row(
              children: [
                _buildStat(context, 'Template', intro.template.toUpperCase()),
                const SizedBox(width: AppTheme.space24),
                _buildStat(context, 'Sections', '${intro.sectionCount}'),
                const SizedBox(width: AppTheme.space24),
                _buildStat(
                  context,
                  'Status',
                  intro.isComplete ? 'Complete' : 'Incomplete',
                  color: intro.isComplete ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionWidget(BuildContext context, IntroductionSection section) {
    switch (section.type) {
      case SectionType.text:
        return TextSectionWidget(
          section: section,
          onEdit: () => _editSection(context, section),
          onDelete: () => _deleteSection(context, section),
        );
      case SectionType.list:
        return ListSectionWidget(
          section: section,
          onEdit: () => _editSection(context, section),
          onDelete: () => _deleteSection(context, section),
        );
      case SectionType.nested:
        return NestedSectionWidget(
          section: section,
          onEdit: () => _editSection(context, section),
          onDelete: () => _deleteSection(context, section),
        );
      case SectionType.table:
        return TableSectionWidget(
          section: section,
          onEdit: () => _editSection(context, section),
          onDelete: () => _deleteSection(context, section),
        );
    }
  }

  Widget? _buildFAB(BuildContext context, IntroductionState state) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddSectionDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add Section'),
    );
  }

  // Action methods
  void _showTemplateSelector(BuildContext context) {
    // TODO: Implement template selector dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template selector - Coming soon'),
      ),
    );
  }

  void _showAIGenerateDialog(BuildContext context) {
    // TODO: Implement AI generation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI generation dialog - Coming soon'),
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context) {
    // TODO: Implement add section dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add section dialog - Coming soon'),
      ),
    );
  }

  void _editSection(BuildContext context, IntroductionSection section) {
    // TODO: Implement edit section dialog with AI refinement option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit section: ${section.title} - Coming soon'),
      ),
    );
  }

  void _deleteSection(BuildContext context, IntroductionSection section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Section'),
        content: Text('Are you sure you want to delete "${section.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(introductionProvider(widget.agencyId).notifier)
                  .deleteSection(section.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
