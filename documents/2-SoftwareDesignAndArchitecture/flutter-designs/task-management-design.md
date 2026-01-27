# Task Management Interface - Flutter Design Specification

**Document Version:** 1.0  
**Last Updated:** January 27, 2026  
**Target Platforms:** Web (Primary), iOS, Android, Desktop  
**Reference:** Nowa Todotask Template

## 1. Overview

This document specifies the Flutter architecture for a comprehensive task management interface that displays work items, tasks, and assignments. The design follows MVVM pattern with responsive layouts supporting mobile, tablet, and desktop viewports.

### 1.1 Key Features

- Task list organization by category (All, Important, Starred, Spam, Archive, Trash)
- Task card display with user assignments
- Status badges (New, Completed, Pending)
- Task actions (assign, view details, options)
- Responsive grid layout
- User avatar with task count indicators
- Quick action buttons per task

### 1.2 Design Principles

- **Clean Architecture**: MVVM with clear separation of concerns
- **Responsive First**: Adaptive layouts for all screen sizes
- **State Management**: Riverpod for reactive state updates
- **Reusability**: Modular widget components
- **Accessibility**: WCAG 2.1 AA compliance

## 2. Architecture Pattern: MVVM

### 2.1 Structure

```
View (Widgets) ←→ ViewModel (Business Logic) ←→ Model (Data)
```

### 2.2 Component Layers

- **Views**: StatelessWidget UI components
- **ViewModels**: ChangeNotifier/StateNotifier classes with business logic
- **Models**: Dart data classes for tasks, users, categories
- **Services**: API clients, repositories for data operations

## 3. Data Models

### 3.1 Task Model

```dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedUserId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> tags;
  final int assignedTaskCount;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedUserId,
    required this.createdAt,
    this.dueDate,
    required this.status,
    required this.priority,
    this.tags = const [],
    this.assignedTaskCount = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
}
```

### 3.2 Task Status Enum

```dart
enum TaskStatus {
  newTask('New', 'primary'),
  inProgress('In Progress', 'info'),
  completed('Completed', 'success'),
  pending('Pending', 'danger'),
  archived('Archived', 'secondary');

  final String label;
  final String colorVariant;

  const TaskStatus(this.label, this.colorVariant);
}
```

### 3.3 Task Priority Enum

```dart
enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;
  const TaskPriority(this.label);
}
```

### 3.4 Task Category Model

```dart
class TaskCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final int? badgeCount;

  TaskCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.badgeCount,
  });
}
```

### 3.5 User Model

```dart
class UserModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final String email;
  final int assignedTaskCount;

  UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.email,
    this.assignedTaskCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) { /* ... */ }
}
```

## 4. Widget Component Hierarchy

### 4.1 Main Layout Structure

```
TaskManagementView (StatelessWidget)
├─ Scaffold
│  ├─ AppBar (optional, based on layout mode)
│  ├─ Body: ResponsiveBuilder
│  │  ├─ Desktop/Tablet: Row
│  │  │  ├─ TaskSidebarPanel (left, 25% width)
│  │  │  └─ TaskContentArea (right, 75% width)
│  │  └─ Mobile: Column
│  │     ├─ TaskCategoryTabs
│  │     └─ TaskContentArea
│  └─ FloatingActionButton (Add Task)
```

### 4.2 Sidebar Component (Desktop/Tablet)

```
TaskSidebarPanel (StatelessWidget)
├─ Card
│  ├─ AddTaskButton (primary button)
│  └─ TaskCategoryList
│     └─ TaskCategoryItem (x6)
│        ├─ Icon (with colored background)
│        ├─ Label
│        └─ Badge (optional count)
```

### 4.3 Content Area Component

```
TaskContentArea (StatelessWidget)
├─ Column
│  ├─ TaskContentHeader
│  │  ├─ Title ("User Today Tasks")
│  │  └─ Actions (add icon)
│  └─ TaskGridView
│     └─ ResponsiveGridView
│        └─ TaskCard (multiple)
```

### 4.4 Task Card Component

```
TaskCard (StatelessWidget)
├─ Card
│  ├─ TaskCardHeader
│  │  ├─ UserAvatarWithBadge
│  │  │  ├─ CircleAvatar
│  │  │  └─ Badge (task count)
│  │  └─ TaskActionButtons
│  │     ├─ FolderButton
│  │     ├─ InfoButton
│  │     └─ MoreOptionsButton (dropdown)
│  ├─ TaskCardContent
│  │  ├─ TaskItem (primary)
│  │  │  ├─ Timestamp
│  │  │  ├─ StatusBadge
│  │  │  └─ Title
│  │  └─ Divider
│  │  └─ TaskItem (secondary)
│  │     ├─ Timestamp
│  │     └─ Title
│  └─ TaskCardFooter
│     ├─ AssignButton
│     └─ ViewAllButton
```

## 5. Detailed Widget Specifications

### 5.1 TaskCard Widget

**File:** `lib/widgets/tasks/task_card.dart`

```dart
class TaskCard extends StatelessWidget {
  final TaskModel primaryTask;
  final TaskModel? secondaryTask;
  final UserModel assignedUser;
  final VoidCallback? onAssign;
  final VoidCallback? onViewAll;
  final VoidCallback? onFolderTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onMoreTap;

  const TaskCard({
    Key? key,
    required this.primaryTask,
    this.secondaryTask,
    required this.assignedUser,
    this.onAssign,
    this.onViewAll,
    this.onFolderTap,
    this.onInfoTap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildPrimaryTaskContent(context),
          if (secondaryTask != null) ...[
            Divider(),
            _buildSecondaryTaskContent(context),
          ],
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) { /* ... */ }
  Widget _buildPrimaryTaskContent(BuildContext context) { /* ... */ }
  Widget _buildSecondaryTaskContent(BuildContext context) { /* ... */ }
  Widget _buildFooter(BuildContext context) { /* ... */ }
}
```

**Responsive Behavior:**
- Mobile: Full width cards, single column
- Tablet: 2 columns grid
- Desktop: 3 columns grid (4 columns on wide screens)

### 5.2 UserAvatarWithBadge Widget

**File:** `lib/widgets/tasks/user_avatar_with_badge.dart`

```dart
class UserAvatarWithBadge extends StatelessWidget {
  final UserModel user;
  final double size;
  final Color? badgeColor;

  const UserAvatarWithBadge({
    Key? key,
    required this.user,
    this.size = 48.0,
    this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(user.name[0].toUpperCase())
              : null,
        ),
        if (user.assignedTaskCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
              child: Center(
                child: Text(
                  '${user.assignedTaskCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

### 5.3 TaskStatusBadge Widget

**File:** `lib/widgets/tasks/task_status_badge.dart`

```dart
class TaskStatusBadge extends StatelessWidget {
  final TaskStatus status;

  const TaskStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  Color _getBackgroundColor(BuildContext context) {
    switch (status.colorVariant) {
      case 'primary':
        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
      case 'danger':
        return Theme.of(context).colorScheme.error.withOpacity(0.1);
      case 'success':
        return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      case 'info':
        return Colors.blue.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (status.colorVariant) {
      case 'primary':
        return Theme.of(context).colorScheme.primary;
      case 'danger':
        return Theme.of(context).colorScheme.error;
      case 'success':
        return Theme.of(context).colorScheme.secondary;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _getTextColor(context),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
```

### 5.4 TaskCategoryItem Widget

**File:** `lib/widgets/tasks/task_category_item.dart`

```dart
class TaskCategoryItem extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskCategoryItem({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: category.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: category.iconColor,
            width: 1,
          ),
        ),
        child: Icon(
          category.icon,
          color: category.iconColor,
          size: 20,
        ),
      ),
      title: Text(
        category.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: category.badgeCount != null && category.badgeCount! > 0
          ? Badge(
              label: Text('${category.badgeCount}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
    );
  }
}
```

### 5.5 TaskActionButtons Widget

**File:** `lib/widgets/tasks/task_action_buttons.dart`

```dart
class TaskActionButtons extends StatelessWidget {
  final VoidCallback? onFolderTap;
  final VoidCallback? onInfoTap;
  final VoidCallback? onMoreTap;

  const TaskActionButtons({
    Key? key,
    this.onFolderTap,
    this.onInfoTap,
    this.onMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          context,
          icon: Icons.folder_outlined,
          onTap: onFolderTap,
        ),
        SizedBox(width: 4),
        _buildActionButton(
          context,
          icon: Icons.info_outline,
          onTap: onInfoTap,
        ),
        SizedBox(width: 4),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: primaryColor),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
            PopupMenuItem(value: 'archive', child: Text('Archive')),
          ],
          onSelected: (value) {
            if (onMoreTap != null) onMoreTap!();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }
}
```

## 6. ViewModel Architecture

### 6.1 TasksViewModel

**File:** `lib/viewmodels/tasks_viewmodel.dart`

```dart
class TasksViewModel extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final UserRepository _userRepository;

  // State
  List<TaskModel> _tasks = [];
  List<UserModel> _users = [];
  TaskCategory? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TaskModel> get tasks => _tasks;
  List<UserModel> get users => _users;
  TaskCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered tasks based on selected category
  List<TaskModel> get filteredTasks {
    if (_selectedCategory == null) return _tasks;
    
    switch (_selectedCategory!.id) {
      case 'all':
        return _tasks;
      case 'important':
        return _tasks.where((t) => t.priority == TaskPriority.high || 
                                    t.priority == TaskPriority.critical).toList();
      case 'starred':
        // Implement starred logic
        return _tasks;
      case 'spam':
        // Implement spam logic
        return _tasks;
      case 'archived':
        return _tasks.where((t) => t.status == TaskStatus.archived).toList();
      case 'trash':
        // Implement trash logic
        return _tasks;
      default:
        return _tasks;
    }
  }

  // Task categories
  List<TaskCategory> get categories => [
    TaskCategory(
      id: 'all',
      label: 'All Tasks',
      icon: Icons.code,
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.withOpacity(0.1),
    ),
    TaskCategory(
      id: 'important',
      label: 'Important',
      icon: Icons.warning_amber_outlined,
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.withOpacity(0.1),
      badgeCount: _tasks.where((t) => 
        t.priority == TaskPriority.high || 
        t.priority == TaskPriority.critical).length,
    ),
    TaskCategory(
      id: 'starred',
      label: 'Starred',
      icon: Icons.star_outline,
      iconColor: Colors.grey,
      backgroundColor: Colors.grey.withOpacity(0.1),
    ),
    TaskCategory(
      id: 'spam',
      label: 'Spam',
      icon: Icons.business_center_outlined,
      iconColor: Colors.teal,
      backgroundColor: Colors.teal.withOpacity(0.1),
    ),
    TaskCategory(
      id: 'archived',
      label: 'Archive',
      icon: Icons.notifications_outlined,
      iconColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.1),
      badgeCount: _tasks.where((t) => t.status == TaskStatus.archived).length,
    ),
    TaskCategory(
      id: 'trash',
      label: 'Trash',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
    ),
  ];

  TasksViewModel({
    required TaskRepository taskRepository,
    required UserRepository userRepository,
  })  : _taskRepository = taskRepository,
        _userRepository = userRepository {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskRepository.fetchTasks();
      _users = await _userRepository.fetchUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(TaskCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> assignTask(String taskId, String userId) async {
    try {
      await _taskRepository.assignTask(taskId, userId);
      await loadTasks(); // Reload to get updated data
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _taskRepository.updateTaskStatus(taskId, status);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }
}
```

### 6.2 Riverpod Provider Setup

**File:** `lib/providers/task_providers.dart`

```dart
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(apiClient: ref.read(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(apiClient: ref.read(apiClientProvider));
});

final tasksViewModelProvider = ChangeNotifierProvider<TasksViewModel>((ref) {
  return TasksViewModel(
    taskRepository: ref.read(taskRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
  );
});

// Selector for filtered tasks
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final viewModel = ref.watch(tasksViewModelProvider);
  return viewModel.filteredTasks;
});

// Selector for categories
final categoriesProvider = Provider<List<TaskCategory>>((ref) {
  final viewModel = ref.watch(tasksViewModelProvider);
  return viewModel.categories;
});
```

## 7. View Implementation

### 7.1 TaskManagementView (Main View)

**File:** `lib/views/tasks/task_management_view.dart`

```dart
class TaskManagementView extends ConsumerWidget {
  const TaskManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(tasksViewModelProvider);
    
    return Scaffold(
      appBar: _buildAppBar(context),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('Error: ${viewModel.error}'))
              : ResponsiveBuilder(
                  mobile: _buildMobileLayout(context, ref),
                  tablet: _buildTabletLayout(context, ref),
                  desktop: _buildDesktopLayout(context, ref),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add New Task',
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Task Management'),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            // Refresh tasks
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            // Show filter options
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TaskCategoryTabBar(),
        Expanded(child: TaskContentArea()),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: TaskSidebarPanel(),
        ),
        Expanded(child: TaskContentArea()),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 320,
          child: TaskSidebarPanel(),
        ),
        Expanded(child: TaskContentArea()),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    // Show add task dialog
  }
}
```

### 7.2 TaskContentArea Widget

**File:** `lib/views/tasks/task_content_area.dart`

```dart
class TaskContentArea extends ConsumerWidget {
  const TaskContentArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final viewModel = ref.watch(tasksViewModelProvider);

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState(context)
              : _buildTaskGrid(context, tasks, viewModel),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            'User Today Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Add task action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskGrid(BuildContext context, List<TaskModel> tasks, TasksViewModel viewModel) {
    return ResponsiveGridView(
      padding: EdgeInsets.all(16),
      crossAxisCount: _getCrossAxisCount(context),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: tasks.map((task) {
        final user = viewModel.getUserById(task.assignedUserId);
        
        return TaskCard(
          primaryTask: task,
          assignedUser: user ?? UserModel(id: '', name: 'Unknown', email: ''),
          onAssign: () => _handleAssign(context, task),
          onViewAll: () => _handleViewAll(context, user),
          onFolderTap: () => _handleFolder(context, task),
          onInfoTap: () => _handleInfo(context, task),
          onMoreTap: () => _handleMore(context, task),
        );
      }).toList(),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1800) return 4;
    if (width >= 1200) return 3;
    if (width >= 900) return 2;
    return 1;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Create a new task to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleAssign(BuildContext context, TaskModel task) { /* ... */ }
  void _handleViewAll(BuildContext context, UserModel? user) { /* ... */ }
  void _handleFolder(BuildContext context, TaskModel task) { /* ... */ }
  void _handleInfo(BuildContext context, TaskModel task) { /* ... */ }
  void _handleMore(BuildContext context, TaskModel task) { /* ... */ }
}
```

## 8. Responsive Design

### 8.1 Breakpoints

```dart
class TaskBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1800;
}
```

### 8.2 Layout Adaptations

| Screen Size | Sidebar | Grid Columns | Card Layout |
|-------------|---------|--------------|-------------|
| < 600px | Hidden (tabs) | 1 | Full width |
| 600-899px | Drawer | 2 | Half width |
| 900-1199px | Fixed 280px | 2 | Third width |
| 1200-1799px | Fixed 320px | 3 | Quarter width |
| ≥ 1800px | Fixed 320px | 4 | Fifth width |

### 8.3 ResponsiveBuilder Widget

**File:** `lib/widgets/common/responsive_builder.dart`

```dart
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= TaskBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= TaskBreakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

## 9. File Structure

```
lib/
├── models/
│   ├── task_model.dart
│   ├── user_model.dart
│   ├── task_category.dart
│   └── enums/
│       ├── task_status.dart
│       └── task_priority.dart
├── viewmodels/
│   └── tasks_viewmodel.dart
├── views/
│   └── tasks/
│       ├── task_management_view.dart
│       ├── task_content_area.dart
│       ├── task_sidebar_panel.dart
│       └── task_category_tab_bar.dart
├── widgets/
│   ├── common/
│   │   ├── responsive_builder.dart
│   │   └── responsive_grid_view.dart
│   └── tasks/
│       ├── task_card.dart
│       ├── user_avatar_with_badge.dart
│       ├── task_status_badge.dart
│       ├── task_category_item.dart
│       └── task_action_buttons.dart
├── repositories/
│   ├── task_repository.dart
│   └── user_repository.dart
├── services/
│   └── api/
│       ├── task_api_client.dart
│       └── user_api_client.dart
└── providers/
    └── task_providers.dart
```

## 10. Required Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # UI Components
  badges: ^3.1.2
  
  # HTTP & API
  dio: ^5.4.0
  
  # Utilities
  intl: ^0.18.1
  
  # Routing
  go_router: ^13.0.0
```

## 11. Theme Configuration

### 11.1 Task Card Theme

```dart
class TaskCardTheme {
  static CardTheme cardTheme(ColorScheme colorScheme) {
    return CardTheme(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static BoxDecoration actionButtonDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(4),
    );
  }
}
```

### 11.2 Color Schemes for Task Status

```dart
class TaskStatusColors {
  static const Map<String, Color> backgrounds = {
    'primary': Color(0xFFE3F2FD),
    'danger': Color(0xFFFFEBEE),
    'success': Color(0xFFE8F5E9),
    'info': Color(0xFFE1F5FE),
    'secondary': Color(0xFFF5F5F5),
  };

  static const Map<String, Color> text = {
    'primary': Color(0xFF1976D2),
    'danger': Color(0xFFD32F2F),
    'success': Color(0xFF388E3C),
    'info': Color(0xFF0288D1),
    'secondary': Color(0xFF616161),
  };
}
```

## 12. API Integration

### 12.1 Task Repository

**File:** `lib/repositories/task_repository.dart`

```dart
class TaskRepository {
  final TaskApiClient _apiClient;

  TaskRepository({required TaskApiClient apiClient}) : _apiClient = apiClient;

  Future<List<TaskModel>> fetchTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedUserId,
  }) async {
    final response = await _apiClient.getTasks(
      status: status,
      priority: priority,
      assignedUserId: assignedUserId,
    );
    return (response['tasks'] as List)
        .map((json) => TaskModel.fromJson(json))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await _apiClient.createTask(task.toJson());
    return TaskModel.fromJson(response);
  }

  Future<void> assignTask(String taskId, String userId) async {
    await _apiClient.assignTask(taskId, userId);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _apiClient.updateTaskStatus(taskId, status.name);
  }

  Future<void> deleteTask(String taskId) async {
    await _apiClient.deleteTask(taskId);
  }
}
```

## 13. Implementation Notes

### 13.1 Task Grouping Strategy

For the HTML reference that shows multiple tasks per card:
- Primary approach: Display single task per card for clarity
- Alternative: Group related tasks by user or project
- Card footer "View All" button navigates to detailed task list for that user/project

### 13.2 Real-time Updates

Consider implementing real-time task updates:
- WebSocket connection for task status changes
- Optimistic UI updates for immediate feedback
- Background refresh with pull-to-refresh support

### 13.3 Accessibility Features

- Screen reader support for task status badges
- Keyboard navigation for task actions
- High contrast mode support for status colors
- Focus indicators on interactive elements

### 13.4 Performance Optimization

- Lazy loading for large task lists
- Pagination for API requests
- Image caching for user avatars
- Debouncing for search/filter operations

## 14. Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        cardTheme: TaskCardTheme.cardTheme(
          ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
      ),
      home: TaskManagementView(),
    );
  }
}
```

## 15. Testing Strategy

### 15.1 Widget Tests

- Test TaskCard rendering with different task statuses
- Test UserAvatarWithBadge badge display logic
- Test TaskStatusBadge color mapping
- Test responsive layout switching

### 15.2 ViewModel Tests

- Test task filtering by category
- Test task assignment logic
- Test status update operations
- Test error handling

### 15.3 Integration Tests

- Test complete task creation flow
- Test task assignment workflow
- Test category filtering
- Test search and filter operations

---

**Related Documents:**
- [Dashboard Design](dashboard-design.md) - Main dashboard layout
- [Design Patterns](design-patterns.md) - Reusable widget patterns
- [MVP Tasks](../../3-SofwareDevelopment/mvp.md) - Implementation roadmap
