import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/agency/agency_designer_state.dart';
import '../../../viewmodels/agency/agency_designer_viewmodel.dart';
import 'sections/introduction_section.dart';
import 'sections/goals_section.dart';
import 'sections/work_items_section.dart';
import 'sections/roles_section.dart';
import 'sections/raci_matrix_section.dart';
import 'sections/workflows_section.dart';
import 'sections/policy_section.dart';
import 'sections/admin_section.dart';

/// Main Agency Designer view with responsive navigation
class AgencyDesignerView extends ConsumerWidget {
  final String agencyId;
  final String agencyName;

  const AgencyDesignerView({
    super.key,
    required this.agencyId,
    required this.agencyName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designerState = ref.watch(
      agencyDesignerViewModelProvider((agencyId: agencyId, agencyName: agencyName)),
    );

    return Scaffold(
      appBar: _buildAppBar(context, ref, designerState),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout switching
          if (constraints.maxWidth > 900) {
            return _buildDesktopLayout(context, ref, designerState);
          } else if (constraints.maxWidth > 600) {
            return _buildTabletLayout(context, ref, designerState);
          } else {
            return _buildMobileLayout(context, ref, designerState);
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(state.agencyName),
          Text(
            'Agency Designer',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withAlpha(204),
                ),
          ),
        ],
      ),
      actions: [
        // Unsaved changes indicator
        if (state.hasUnsavedChanges)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: const Text('Unsaved'),
              avatar: const Icon(Icons.circle, size: 12, color: Colors.orange),
              labelStyle: const TextStyle(fontSize: 12),
            ),
          ),
        
        // Save button
        IconButton(
          icon: state.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          onPressed: state.isSaving
              ? null
              : () {
                  ref
                      .read(agencyDesignerViewModelProvider(
                          (agencyId: agencyId, agencyName: agencyName)).notifier)
                      .saveProgress();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress saved'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
          tooltip: 'Save Progress',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Row(
      children: [
        // Vertical navigation rail
        NavigationRail(
          selectedIndex: DesignerSection.values.indexOf(state.activeSection),
          onDestinationSelected: (index) {
            ref
                .read(agencyDesignerViewModelProvider(
                    (agencyId: agencyId, agencyName: agencyName)).notifier)
                .navigateToSection(DesignerSection.values[index]);
          },
          labelType: NavigationRailLabelType.all,
          destinations: _buildNavigationDestinations(state),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Icon(
              Icons.design_services,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Main content area
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Column(
      children: [
        // Horizontal scrollable tab bar
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildTabButtons(context, ref, state),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return Column(
      children: [
        // Dropdown selector
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: DropdownButton<DesignerSection>(
            value: state.activeSection,
            isExpanded: true,
            items: DesignerSection.values.map((section) {
              final status = state.sectionCompletion[section] ??
                  SectionCompletionStatus.notStarted;
              
              return DropdownMenuItem(
                value: section,
                child: Row(
                  children: [
                    Icon(section.icon, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(section.displayName)),
                    Icon(
                      status.icon,
                      size: 16,
                      color: _getStatusColor(context, status),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (section) {
              if (section != null) {
                ref
                    .read(agencyDesignerViewModelProvider(
                        (agencyId: agencyId, agencyName: agencyName)).notifier)
                    .navigateToSection(section);
              }
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildSectionContent(state.activeSection),
        ),
      ],
    );
  }

  List<NavigationRailDestination> _buildNavigationDestinations(
    AgencyDesignerState state,
  ) {
    return DesignerSection.values.map((section) {
      final status = state.sectionCompletion[section] ??
          SectionCompletionStatus.notStarted;

      return NavigationRailDestination(
        icon: Badge(
          label: Icon(status.icon, size: 12),
          child: Icon(section.icon),
        ),
        label: Text(section.displayName),
      );
    }).toList();
  }

  List<Widget> _buildTabButtons(
    BuildContext context,
    WidgetRef ref,
    AgencyDesignerState state,
  ) {
    return DesignerSection.values.map((section) {
      final isActive = state.activeSection == section;
      final status = state.sectionCompletion[section] ??
          SectionCompletionStatus.notStarted;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(section.icon, size: 18),
              const SizedBox(width: 8),
              Text(section.displayName),
              const SizedBox(width: 8),
              Icon(
                status.icon,
                size: 14,
                color: _getStatusColor(context, status),
              ),
            ],
          ),
          selected: isActive,
          onSelected: (selected) {
            if (selected) {
              ref
                  .read(agencyDesignerViewModelProvider(
                      (agencyId: agencyId, agencyName: agencyName)).notifier)
                  .navigateToSection(section);
            }
          },
        ),
      );
    }).toList();
  }

  Widget _buildSectionContent(DesignerSection section) {
    switch (section) {
      case DesignerSection.introduction:
        return IntroductionSection(agencyId: agencyId);
      case DesignerSection.goals:
        return const GoalsSection();
      case DesignerSection.workItems:
        return const WorkItemsSection();
      case DesignerSection.roles:
        return const RolesSection();
      case DesignerSection.raciMatrix:
        return const RaciMatrixSection();
      case DesignerSection.workflows:
        return const WorkflowsSection();
      case DesignerSection.policy:
        return const PolicySection();
      case DesignerSection.admin:
        return const AdminSection();
    }
  }

  Color _getStatusColor(BuildContext context, SectionCompletionStatus status) {
    switch (status) {
      case SectionCompletionStatus.notStarted:
        return Theme.of(context).colorScheme.outline;
      case SectionCompletionStatus.inProgress:
        return Colors.orange;
      case SectionCompletionStatus.complete:
        return Colors.green;
    }
  }
}
