import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/agency/agency_status.dart';
import '../../../../providers/agency_provider.dart';

/// Filter chips for agency status filtering
class AgencyFilters extends ConsumerWidget {
  const AgencyFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyListState = ref.watch(agencyListProvider);

    return agencyListState.when(
      data: (state) => _buildFilters(context, ref, state.statusFilter),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    AgencyStatus? currentFilter,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Status:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              context: context,
              ref: ref,
              label: 'All',
              isSelected: currentFilter == null,
              onSelected: (_) {
                ref.read(agencyListProvider.notifier).clearStatusFilter();
              },
            ),
            const SizedBox(width: 8),
            ...AgencyStatus.values.map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  context: context,
                  ref: ref,
                  label: status.displayName,
                  isSelected: currentFilter == status,
                  badgeColor: status.badgeColor,
                  onSelected: (_) {
                    ref
                        .read(agencyListProvider.notifier)
                        .filterByStatus(status);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    Color? badgeColor,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor:
          badgeColor?.withValues(alpha: 0.2) ??
          Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: badgeColor ?? Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? (badgeColor ?? Theme.of(context).colorScheme.primary)
            : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
