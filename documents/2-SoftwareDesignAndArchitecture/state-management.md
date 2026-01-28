# State Management Architecture

## Overview

CodeVald Fortex uses the **MVVM (Model-View-ViewModel)** architectural pattern with **Riverpod** for state management. This document describes the state management conventions, patterns, and best practices used throughout the application.

## Architecture Components

### 1. Models (`lib/models/`)

Models represent data structures used throughout the application. They should be:
- Immutable (use `final` fields)
- Extend `Equatable` for value equality
- Include `copyWith()` methods for updates
- Provide factory constructors for common scenarios (empty, mock, from JSON)

**Example:**
```dart
class StatsData extends Equatable {
  final int todayOrders;
  final double todayEarnings;
  
  const StatsData({
    required this.todayOrders,
    required this.todayEarnings,
  });
  
  StatsData copyWith({int? todayOrders, double? todayEarnings}) {
    return StatsData(
      todayOrders: todayOrders ?? this.todayOrders,
      todayEarnings: todayEarnings ?? this.todayEarnings,
    );
  }
  
  @override
  List<Object?> get props => [todayOrders, todayEarnings];
}
```

### 2. State Classes (`lib/viewmodels/*/states/`)

State classes represent the current state of a feature or screen. All state classes should:
- Extend `BaseState<T>` from `lib/core/state/`
- Use `StateStatus` enum to track loading/success/error states
- Be immutable
- Implement factory constructors for common states

**Example:**
```dart
class DashboardState extends BaseState<DashboardData> {
  const DashboardState({
    super.status,
    super.data,
    super.errorMessage,
    super.error,
  });
  
  factory DashboardState.initial() {
    return const DashboardState(status: StateStatus.initial);
  }
  
  factory DashboardState.loading({DashboardData? data}) {
    return DashboardState(status: StateStatus.loading, data: data);
  }
  
  factory DashboardState.success(DashboardData data) {
    return DashboardState(status: StateStatus.success, data: data);
  }
  
  factory DashboardState.error(String message, {dynamic error, DashboardData? data}) {
    return DashboardState(
      status: StateStatus.error,
      errorMessage: message,
      error: error,
      data: data,
    );
  }
  
  @override
  DashboardState copyWith({
    StateStatus? status,
    DashboardData? data,
    String? errorMessage,
    dynamic error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
    );
  }
}
```

### 3. ViewModels (`lib/viewmodels/`)

ViewModels manage the business logic and state for screens/features. All ViewModels should:
- Extend `BaseViewModel<TState>` from `lib/core/state/`
- Use `executeAsync()` for async operations with automatic error handling
- Call `setState()` to update state and notify listeners
- Override `_createLoadingState()`, `_createErrorState()`, and `_createInitialState()` as needed

**Example:**
```dart
class DashboardViewModel extends BaseViewModel<DashboardState> {
  DashboardViewModel() : super(DashboardState.initial());
  
  Future<void> fetchDashboardData() async {
    await executeAsync<DashboardData>(
      operation: () => _loadDashboardData(),
      onSuccess: (data) => DashboardState.success(data),
      onError: (error, stackTrace) => DashboardState.error(
        'Failed to load dashboard data',
        error: error,
        data: state.data,
      ),
    );
  }
  
  Future<DashboardData> _loadDashboardData() async {
    // Call repository/service to fetch data
    return DashboardData.mock();
  }
}
```

### 4. Providers (`lib/providers/`)

Providers expose ViewModels and state to the widget tree. Use:
- `ChangeNotifierProvider` for ViewModels
- `Provider` for computed/derived state
- Group related providers in feature-specific files

**Example:**
```dart
// ViewModel provider
final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((ref) {
  return DashboardViewModel();
});

// State provider (derived from ViewModel)
final dashboardStateProvider = Provider<DashboardState>((ref) {
  return ref.watch(dashboardViewModelProvider).state;
});

// Computed providers for specific state checks
final isDashboardLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(dashboardStateProvider);
  return state.isLoading;
});
```

### 5. Views (`lib/views/`)

Views (screens/widgets) consume state via Riverpod providers. Use:
- `ConsumerWidget` or `ConsumerStatefulWidget` for widgets that need providers
- `ref.watch()` to listen to provider changes
- `ref.read()` to access providers without listening (e.g., in callbacks)

**Example:**
```dart
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dashboardViewModelProvider);
    final state = ref.watch(dashboardStateProvider);
    
    // React to state changes
    if (state.isLoading) {
      return const LoadingWidget();
    }
    
    if (state.isError) {
      return ErrorWidget(message: state.errorMessage);
    }
    
    if (state.hasData) {
      return DashboardContent(data: state.data!);
    }
    
    return const EmptyStateWidget();
  }
}
```

## State Status Flow

The `StateStatus` enum defines the lifecycle of async operations:

```
Initial → Loading → Success/Error
              ↓
         Refreshing → Success/Error
```

- **Initial**: No data loaded yet
- **Loading**: First-time data fetch in progress
- **Success**: Data loaded successfully
- **Error**: Operation failed
- **Refreshing**: Subsequent data refresh (e.g., pull-to-refresh)

## Best Practices

### 1. Immutability
- All state objects should be immutable
- Use `final` fields and `const` constructors
- Use `copyWith()` for updates

### 2. Separation of Concerns
- **Models**: Data structures only, no logic
- **ViewModels**: Business logic, API calls, state management
- **Views**: UI rendering, user interaction

### 3. Error Handling
- Use `executeAsync()` for consistent error handling
- Preserve existing data when errors occur
- Provide user-friendly error messages

### 4. Loading States
- Show loading indicators for initial loads (`isLoading`)
- Show different UI for refreshes (`isRefreshing`)
- Preserve existing data during refreshes

### 5. Provider Organization
```
lib/providers/
  ├── dashboard_providers.dart   # Dashboard-specific providers
  ├── auth_providers.dart        # Authentication providers
  ├── theme_provider.dart        # Theme/settings providers
  └── ...
```

### 6. ViewModel Organization
```
lib/viewmodels/
  ├── dashboard/
  │   ├── dashboard_state.dart
  │   ├── dashboard_view_model.dart
  │   ├── stats_state.dart
  │   └── stats_view_model.dart
  ├── auth/
  │   ├── auth_state.dart
  │   └── auth_view_model.dart
  └── ...
```

## Testing

### Unit Testing ViewModels
```dart
test('should load dashboard data successfully', () async {
  final viewModel = DashboardViewModel();
  
  await viewModel.fetchDashboardData();
  
  expect(viewModel.state.isSuccess, true);
  expect(viewModel.state.hasData, true);
});
```

### Testing State Transitions
```dart
test('should transition from loading to success', () async {
  final viewModel = DashboardViewModel();
  final states = <StateStatus>[];
  
  viewModel.addListener(() {
    states.add(viewModel.state.status);
  });
  
  await viewModel.fetchDashboardData();
  
  expect(states, [StateStatus.loading, StateStatus.success]);
});
```

## Migration Guide

### Converting Existing Screens to MVVM

1. **Create Model** (if not exists)
```dart
class MyData extends Equatable {
  final String name;
  // ...
}
```

2. **Create State Class**
```dart
class MyState extends BaseState<MyData> {
  // Factory constructors...
}
```

3. **Create ViewModel**
```dart
class MyViewModel extends BaseViewModel<MyState> {
  MyViewModel() : super(MyState.initial());
  
  Future<void> loadData() async {
    await executeAsync(/* ... */);
  }
}
```

4. **Create Provider**
```dart
final myViewModelProvider = ChangeNotifierProvider<MyViewModel>((ref) {
  return MyViewModel();
});
```

5. **Update View**
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myViewModelProvider).state;
    // ...
  }
}
```

## Common Patterns

### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(dashboardViewModelProvider).refreshDashboardData();
  },
  child: ListView(/* ... */),
)
```

### Optimistic Updates
```dart
void updateItem(Item item) {
  // Update UI immediately
  final updatedData = state.data!.copyWith(item: item);
  setState(MyState.success(updatedData));
  
  // Sync with backend
  _repository.updateItem(item).catchError((error) {
    // Revert on error
    fetchData();
  });
}
```

### Pagination
```dart
class ListViewModel extends BaseViewModel<ListState> {
  int _page = 1;
  
  Future<void> loadMore() async {
    _page++;
    final newItems = await _repository.fetchPage(_page);
    final allItems = [...state.data!.items, ...newItems];
    setState(ListState.success(allItems));
  }
}
```

## Debugging

### Enable Logging
ViewModels automatically log state transitions in debug mode:
```
MVP-FL-004-DEBUG: DashboardViewModel state changed: loading -> success
```

### Riverpod DevTools
- Use Riverpod Inspector in Flutter DevTools
- Monitor provider state changes
- Track provider dependencies

### State Inspection
```dart
// Add listener to ViewModel for debugging
viewModel.addListener(() {
  debugPrint('State: ${viewModel.state}');
});
```

## References

- [BaseState](/lib/core/state/base_state.dart)
- [BaseViewModel](/lib/core/state/base_view_model.dart)
- [StateStatus](/lib/core/state/state_status.dart)
- [Riverpod Documentation](https://riverpod.dev/)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
