import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/agency_provider.dart';
import '../../../models/agency/agency_model.dart';
import 'widgets/index.dart';

/// Main agency selection screen
class AgencySelectionView extends ConsumerWidget {
  const AgencySelectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyListState = ref.watch(agencyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Agency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Agency',
            onPressed: () => _onCreateAgency(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(agencyListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          AgencySearchBar(
            onSearch: (query) {
              ref.read(agencyListProvider.notifier).search(query);
            },
          ),

          // Filter chips
          const AgencyFilters(),

          // Agency list
          Expanded(
            child: agencyListState.when(
              data: (state) => _buildAgencyList(context, ref, state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  _buildErrorState(context, ref, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyList(
    BuildContext context,
    WidgetRef ref,
    AgencyListState state,
  ) {
    if (state.agencies.isEmpty) {
      // Determine if it's a search/filter result or truly empty
      final hasActiveFilters =
          state.searchQuery.isNotEmpty || state.statusFilter != null;

      return AgencyEmptyState(
        message: hasActiveFilters ? 'No agencies found' : 'No agencies yet',
        onCreateAgency: hasActiveFilters
            ? null
            : () => _onCreateAgency(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(agencyListProvider.notifier).refresh(),
      child: AgencyGrid(
        agencies: state.agencies,
        onAgencyTap: (agency) => _onAgencyTap(context, agency),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String errorMessage,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load agencies',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(agencyListProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _onAgencyTap(BuildContext context, Agency agency) {
    // Navigate to agency designer with agency ID
    context.go('/agencies/${agency.id}/designer');
  }

  void _onCreateAgency(BuildContext context) {
    // Navigate to agency creation screen
    context.go('/agencies/create');
  }
}
