# MVP-FL-101: Agency Selection Homepage

## Overview
**Priority**: P0  
**Effort**: Medium  
**Skills**: Flutter, Material Design, Riverpod  
**Dependencies**: MVP-FL-011 (Protected Routes & Permissions) ✅

Build homepage UI for listing and selecting agencies. Display agency cards with name, description, status badges (draft/validated/published/active). Implement search/filter, sorting. Navigate to selected agency. Migrated from Cortex MVP-022 (Agency Selection Homepage).

## Requirements

### Functional Requirements

1. **Agency Listing**
   - Display all user-accessible agencies in card/grid layout
   - Show agency metadata:
     - Name
     - Description/purpose
     - Status badge (draft/validated/published/active)
     - Last modified date
     - Creation date
   - Support both grid and list view modes
   - Responsive layout (mobile/tablet/desktop)

2. **Search & Filtering**
   - Global search by agency name/description
   - Filter by status (draft, validated, published, active)
   - Filter by date range (created/modified)
   - Clear all filters option
   - Show active filter count

3. **Sorting**
   - Sort by name (A-Z, Z-A)
   - Sort by date (newest first, oldest first)
   - Sort by status
   - Persist sort preference

4. **Agency Selection**
   - Click agency card to navigate to Agency Designer
   - Show loading state during navigation
   - Pass agency context to next screen

5. **Empty States**
   - "No agencies found" when list is empty
   - "Create your first agency" call-to-action
   - "No results" when search/filter yields nothing

6. **API Integration**
   - Fetch agencies via GET /api/v1/agencies
   - Handle loading states
   - Handle error states (network errors, auth failures)
   - Implement retry mechanism

### Non-Functional Requirements

1. **Performance**
   - Agency list renders in <500ms
   - Smooth scrolling (60fps)
   - Debounced search (300ms)
   - Cached agency data

2. **Responsive Design**
   - Mobile (<600px): Single column cards
   - Tablet (600-900px): 2 column grid
   - Desktop (900-1200px): 3 column grid
   - Wide (>1200px): 4 column grid

3. **Accessibility**
   - Screen reader support
   - Keyboard navigation
   - Focus management
   - High contrast mode support

4. **Security**
   - Only show agencies user has access to
   - Respect role-based permissions
   - Secure API calls with auth tokens

## Technical Specifications

### Architecture

#### Component Structure
```
lib/views/agency/
├── agency_selection/
│   ├── agency_selection_view.dart       # Main screen
│   └── widgets/
│       ├── agency_card.dart             # Individual agency card
│       ├── agency_grid.dart             # Grid layout
│       ├── agency_list_item.dart        # List view item
│       ├── agency_search_bar.dart       # Search widget
│       ├── agency_filters.dart          # Filter chips/dialog
│       ├── agency_empty_state.dart      # Empty state widget
│       └── index.dart                   # Barrel export
```

#### Models
```
lib/models/agency/
├── agency_model.dart                    # Agency data class
└── agency_status.dart                   # Status enum
```

#### ViewModels
```
lib/viewmodels/agency/
└── agency_list_viewmodel.dart           # Agency list state management
```

#### Repositories
```
lib/repositories/agency/
└── agency_repository.dart               # API integration
```

### Implementation Details

#### Agency Model
```dart
class Agency {
  final String id;
  final String name;
  final String description;
  final AgencyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Agency({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory Agency.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

enum AgencyStatus {
  draft,
  validated,
  published,
  active;
  
  Color get badgeColor => switch (this) {
    AgencyStatus.draft => Colors.grey,
    AgencyStatus.validated => Colors.blue,
    AgencyStatus.published => Colors.orange,
    AgencyStatus.active => Colors.green,
  };
}
```

#### Agency Repository
```dart
class AgencyRepository {
  final ApiClient _apiClient;
  
  Future<List<Agency>> getAgencies({
    String? search,
    AgencyStatus? status,
    String? sortBy,
    bool sortAscending = true,
  }) async {
    // GET /api/v1/agencies with query params
    // Transform API response to Agency models
  }
  
  Future<Agency> getAgencyById(String id);
}
```

#### Agency List ViewModel (Riverpod)
```dart
@riverpod
class AgencyListViewModel extends _$AgencyListViewModel {
  @override
  Future<AgencyListState> build() async {
    return _fetchAgencies();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAgencies());
  }
  
  void search(String query) {
    // Update search query, debounce, refresh
  }
  
  void filterByStatus(AgencyStatus? status) {
    // Update filter, refresh
  }
  
  void sortBy(String field, bool ascending) {
    // Update sort, refresh
  }
  
  Future<AgencyListState> _fetchAgencies() async {
    final repo = ref.read(agencyRepositoryProvider);
    final agencies = await repo.getAgencies(
      search: _searchQuery,
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
  }
}
```

#### Agency Selection View
```dart
class AgencySelectionView extends ConsumerWidget {
  const AgencySelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agencyListState = ref.watch(agencyListViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Agency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/agency/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          const AgencySearchBar(),
          const AgencyFilters(),
          Expanded(
            child: agencyListState.when(
              data: (state) {
                if (state.agencies.isEmpty) {
                  return const AgencyEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(agencyListViewModelProvider.future),
                  child: AgencyGrid(agencies: state.agencies),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorWidget(error: error),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Agency Card Widget
```dart
class AgencyCard extends StatelessWidget {
  final Agency agency;
  final VoidCallback? onTap;

  const AgencyCard({
    Key? key,
    required this.agency,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      agency.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      agency.status.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: agency.status.badgeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                agency.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatDate(agency.updatedAt)}',
                    style: Theme.of(context).textTheme.caption?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}
```

### State Management

**Riverpod Providers:**
```dart
@riverpod
AgencyRepository agencyRepository(AgencyRepositoryRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AgencyRepository(apiClient);
}

@riverpod
class AgencyListViewModel extends _$AgencyListViewModel {
  // State management for agency list
}
```

### Routing Integration

**go_router configuration:**
```dart
GoRoute(
  path: '/agencies',
  name: 'agencies',
  builder: (context, state) => const AgencySelectionView(),
),
GoRoute(
  path: '/agencies/:id/designer',
  name: 'agency-designer',
  builder: (context, state) {
    final agencyId = state.pathParameters['id']!;
    return AgencyDesignerView(agencyId: agencyId);
  },
),
```

### API Integration

**Endpoint:** GET /api/v1/agencies

**Query Parameters:**
- `search`: string (optional)
- `status`: enum (draft|validated|published|active) (optional)
- `sort_by`: string (name|created_at|updated_at) (optional)
- `sort_order`: string (asc|desc) (optional)
- `page`: int (optional)
- `limit`: int (optional)

**Response:**
```json
{
  "agencies": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string",
      "status": "draft|validated|published|active",
      "created_at": "ISO8601",
      "updated_at": "ISO8601",
      "metadata": {}
    }
  ],
  "total": 0,
  "page": 1,
  "limit": 20
}
```

## Acceptance Criteria

- [ ] Agency listing displays all accessible agencies from API
- [ ] Agency cards show name, description, status badge, last updated
- [ ] Search filters agencies by name/description in real-time
- [ ] Status filter works for all status types
- [ ] Sort options work correctly (name, date)
- [ ] Responsive layout adapts to mobile/tablet/desktop breakpoints
- [ ] Grid view displays 1-4 columns based on screen size
- [ ] Clicking agency card navigates to Agency Designer with agency ID
- [ ] Empty state shows when no agencies exist
- [ ] Loading spinner shows during API fetch
- [ ] Error state displays on API failure with retry option
- [ ] Pull-to-refresh works on mobile
- [ ] Debounced search prevents excessive API calls
- [ ] Agency data is cached for performance
- [ ] Screen reader announces agency information
- [ ] Keyboard navigation works for all interactive elements
- [ ] Code passes `flutter analyze` with no errors
- [ ] Code formatted with `dart format`

## Testing Requirements

### Unit Tests
- Agency model serialization/deserialization
- AgencyRepository API calls with mocked responses
- AgencyListViewModel state transitions
- Search/filter/sort logic

### Widget Tests
- AgencyCard renders correctly
- AgencyGrid layout with different screen sizes
- AgencySearchBar input handling
- AgencyFilters chip selection
- AgencyEmptyState display

### Integration Tests
- Full agency selection flow (load → search → filter → select)
- API error handling
- Navigation to agency designer
- Refresh functionality

## Design Reference

**Pattern Reference:**
- Dashboard card layout: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/design-patterns.md` - StatCard pattern
- Responsive grid: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md` - ResponsiveGrid
- MVVM architecture: `/documents/2-SoftwareDesignAndArchitecture/flutter-designs/dashboard-design.md` - ViewModel pattern

**UI/UX:**
- Material Design 3 components
- Card-based layout with elevation
- Status badges with semantic colors
- Search with real-time filtering
- Responsive breakpoints per design specs

## Migration Notes

**From Cortex MVP-022:**
- Original implementation used Go Templ templates + HTMX
- Backend API endpoint GET /api/v1/agencies already exists
- Backend handles filtering, sorting, and pagination
- Flutter implementation should match existing API contract
- No backend changes required for this task
