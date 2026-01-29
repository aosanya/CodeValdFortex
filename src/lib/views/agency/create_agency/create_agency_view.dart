import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/agency/agency_form_viewmodel.dart';
import '../widgets/agency_form.dart';

/// Create new agency view
class CreateAgencyView extends ConsumerStatefulWidget {
  const CreateAgencyView({super.key});

  @override
  ConsumerState<CreateAgencyView> createState() => _CreateAgencyViewState();
}

class _CreateAgencyViewState extends ConsumerState<CreateAgencyView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clear any previous form state
    Future.microtask(() {
      ref.read(agencyFormViewModelProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(agencyFormViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Agency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header card
                        _buildHeader(context),
                        const SizedBox(height: 24),

                        // Form fields
                        AgencyForm(
                          formState: viewModel.formState,
                          onChanged: (field, value) {
                            ref
                                .read(agencyFormViewModelProvider.notifier)
                                .updateField(field, value);
                          },
                        ),

                        const SizedBox(height: 32),

                        // Action buttons
                        _buildActionButtons(context, viewModel),

                        // Error display
                        if (viewModel.error != null) ...[
                          const SizedBox(height: 16),
                          _buildErrorCard(context, viewModel.error!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_business,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Agency',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a new agency to organize work and manage agents',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AgencyFormViewModelState viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel button
        OutlinedButton(
          onPressed: viewModel.isLoading ? null : () => _handleCancel(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),

        // Create button
        FilledButton.icon(
          onPressed: viewModel.isLoading || !viewModel.isValid
              ? null
              : () => _handleCreate(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Agency'),
        ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(agencyFormViewModelProvider.notifier).create();

    if (success && context.mounted) {
      final createdId = ref.read(agencyFormViewModelProvider).createdId;
      final formState = ref.read(agencyFormViewModelProvider).formState;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agency created successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to agency designer to configure the agency
      if (createdId != null) {
        context.go(
          '/agencies/$createdId/designer',
          extra: {'name': formState.name},
        );
      } else {
        context.go('/agencies');
      }
    }
  }

  void _handleCancel(BuildContext context) {
    final hasChanges =
        ref.read(agencyFormViewModelProvider).hasUnsavedChanges;

    if (hasChanges) {
      _showDiscardDialog(context);
    } else {
      context.pop();
    }
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creating an Agency'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'An agency represents a collection of work items, roles, and agents organized around specific goals.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Agency Name', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Must be unique and descriptive'),
              Text('• Between 3-100 characters'),
              Text('• Will be used to identify this agency'),
              SizedBox(height: 12),
              Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Optional but recommended'),
              Text('• Describe the agency\'s purpose and scope'),
              Text('• Up to 500 characters'),
              SizedBox(height: 12),
              Text('Next Steps', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('After creation, you can:'),
              Text('• Configure agency goals and work items'),
              Text('• Define roles and workflows'),
              Text('• Deploy and manage agents'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}
