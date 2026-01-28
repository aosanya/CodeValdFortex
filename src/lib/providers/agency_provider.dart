import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agency/agency_model.dart';
import '../models/agency/agency_status.dart';
import '../repositories/agency_repository.dart';

/// Provider for AgencyRepository
final agencyRepositoryProvider = Provider<AgencyRepository>((ref) {
  return AgencyRepository();
});

/// State class for agency list
class AgencyListState {
  final List<Agency> agencies;
  final String searchQuery;
  final AgencyStatus? statusFilter;
  final String? sortField;
  final bool sortAscending;
  final bool isLoading;
  final String? errorMessage;

  const AgencyListState({
    required this.agencies,
    this.searchQuery = '',
    this.statusFilter,
    this.sortField,
    this.sortAscending = true,
    this.isLoading = false,
    this.errorMessage,
  });

  AgencyListState copyWith({
    List<Agency>? agencies,
    String? searchQuery,
    AgencyStatus? statusFilter,
    bool clearStatusFilter = false,
    String? sortField,
    bool? sortAscending,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AgencyListState(
      agencies: agencies ?? this.agencies,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Agency list notifier
class AgencyListNotifier extends StateNotifier<AsyncValue<AgencyListState>> {
  final AgencyRepository _repository;

  // Internal filters
  String _searchQuery = '';
  AgencyStatus? _statusFilter;
  String? _sortField = 'updated_at';
  bool _sortAscending = false;

  AgencyListNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Load agencies on initialization
    loadAgencies();
  }

  /// Load agencies with current filters
  Future<void> loadAgencies() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final agencies = await _repository.getAgencies(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter,
        sortBy: _sortField,
        sortAscending: _sortAscending,
      );

      return AgencyListState(
        agencies: agencies,
        searchQuery: _searchQuery,
        statusFilter: _statusFilter,
        sortField: _sortField,
        sortAscending: _sortAscending,
      );
    });
  }

  /// Refresh agencies
  Future<void> refresh() async {
    await loadAgencies();
  }

  /// Search agencies by query
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadAgencies();
  }

  /// Filter by status
  Future<void> filterByStatus(AgencyStatus? status) async {
    _statusFilter = status;
    await loadAgencies();
  }

  /// Clear status filter
  Future<void> clearStatusFilter() async {
    _statusFilter = null;
    await loadAgencies();
  }

  /// Sort agencies
  Future<void> sortBy(String field, bool ascending) async {
    _sortField = field;
    _sortAscending = ascending;
    await loadAgencies();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _searchQuery = '';
    _statusFilter = null;
    await loadAgencies();
  }
}

/// Provider for agency list state
final agencyListProvider =
    StateNotifierProvider<AgencyListNotifier, AsyncValue<AgencyListState>>((
      ref,
    ) {
      final repository = ref.watch(agencyRepositoryProvider);
      return AgencyListNotifier(repository);
    });

/// Provider for individual agency
final agencyProvider = FutureProvider.family<Agency, String>((ref, id) async {
  final repository = ref.watch(agencyRepositoryProvider);
  return repository.getAgencyById(id);
});
