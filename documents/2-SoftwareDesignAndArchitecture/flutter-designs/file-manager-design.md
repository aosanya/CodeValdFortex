# File Manager - Flutter Design Specification

**Document Version:** 1.0  
**Last Updated:** January 28, 2026  
**Target Platforms:** Web (Primary), iOS, Android, Desktop  
**Reference:** UBold File Manager Template

## 1. Overview

### Purpose and Key Features

The File Manager is a comprehensive document and asset management interface designed for organizing, viewing, and managing workflow artifacts in the CodeVald platform. It provides:

- **File Organization**: Hierarchical folder structure with categories (Work, Projects, Media, Documents)
- **Multiple View Modes**: Folder cards grid view + detailed table list view
- **Search & Filter**: Quick search, file type filtering, and sorting capabilities
- **File Operations**: Upload, download, share, edit, delete, and favorite files
- **User Collaboration**: Shared files with avatar groups showing collaborators
- **Responsive Layout**: Sidebar navigation with collapsible menu for mobile

### Design Principles

1. **Component Modularity**: All widgets ≤ 500 lines; complex components split into sub-widgets
2. **Responsive-First**: Adapts from mobile (single column) to desktop (multi-column with sidebar)
3. **State Management**: Centralized file state using Riverpod with MVVM pattern
4. **Performance**: Virtualized lists for large file collections, lazy loading
5. **Accessibility**: Keyboard navigation, screen reader support, ARIA labels

### Target Use Cases

- **Workflow Artifact Management**: Store and organize agent outputs, reports, analysis results
- **Team Collaboration**: Share files with team members, track modifications
- **Document Repository**: Central location for project documentation, specs, designs
- **Media Library**: Manage images, videos, audio files for projects

### Component Splitting Strategy

Given the complexity of the file manager interface, we'll split into:

1. **Layout Components** (3 files):
   - `file_manager_view.dart` - Main scaffold and layout (<300 lines)
   - `file_manager_sidebar.dart` - Navigation sidebar (<400 lines)
   - `file_manager_content.dart` - Content area coordinator (<300 lines)

2. **File Display Components** (6 files):
   - `folder_card_grid.dart` - Folder cards grid view (<400 lines)
   - `folder_card.dart` - Individual folder card (<250 lines)
   - `file_table.dart` - File table list view (<450 lines)
   - `file_table_row.dart` - Individual file row (<300 lines)
   - `file_icon.dart` - File type icons (<200 lines)
   - `avatar_group.dart` - User avatar cluster (<200 lines)

3. **Action Components** (4 files):
   - `file_manager_header.dart` - Search, filters, actions (<350 lines)
   - `file_actions_menu.dart` - Dropdown actions menu (<250 lines)
   - `file_upload_button.dart` - Upload functionality (<200 lines)
   - `file_filter_chips.dart` - Filter UI (<200 lines)

4. **Barrel Export**: `lib/widgets/file_manager/index.dart`

## 2. Architecture Pattern: MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                         View Layer                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ FileManagerView (Main Screen)                          │ │
│  │  ├─ FileManagerSidebar                                 │ │
│  │  │   ├─ CategoryList                                   │ │
│  │  │   └─ StorageInfo                                    │ │
│  │  └─ FileManagerContent                                 │ │
│  │      ├─ FileManagerHeader (Search, Filters)            │ │
│  │      ├─ FolderCardGrid                                 │ │
│  │      └─ FileTable                                      │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↕ (notifyListeners)
┌─────────────────────────────────────────────────────────────┐
│                      ViewModel Layer                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ FileManagerViewModel extends ChangeNotifier            │ │
│  │  - State: files, folders, selectedCategory, filters    │ │
│  │  - Methods: loadFiles, uploadFile, deleteFile, etc.    │ │
│  │  - Business Logic: sorting, filtering, search          │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                      Repository Layer                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ FileRepository                                          │ │
│  │  - getFiles(), getFolders()                            │ │
│  │  - uploadFile(), downloadFile()                        │ │
│  │  - shareFile(), deleteFile()                           │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Models: FileItem, FolderItem, FileCategory             │ │
│  │ API Client: HTTP requests to backend                   │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Component Layers

1. **View Layer**: Stateless widgets consuming ViewModel state
2. **ViewModel Layer**: State management, business logic, data transformation
3. **Repository Layer**: Data access abstraction, API calls
4. **Data Layer**: Models, DTOs, API clients

### Data Flow

1. User interacts with View (e.g., clicks upload button)
2. View calls ViewModel method (e.g., `uploadFile()`)
3. ViewModel uses Repository to perform API call
4. Repository returns data/result
5. ViewModel updates state and calls `notifyListeners()`
6. View rebuilds with new state

## 3. Data Models

### FileItem Model

```dart
// lib/models/file_item_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_item_model.freezed.dart';
part 'file_item_model.g.dart';

@freezed
class FileItem with _$FileItem {
  const factory FileItem({
    required String id,
    required String name,
    required String type, // 'MP4', 'PDF', 'Figma', 'MySQL', etc.
    required int size, // in bytes
    required DateTime modifiedDate,
    required UserInfo owner,
    required List<UserInfo> sharedWith,
    required String category, // 'work', 'projects', 'media', 'documents'
    @Default(false) bool isFavorite,
    @Default(false) bool isSelected,
    String? thumbnailUrl,
    String? downloadUrl,
    Map<String, dynamic>? metadata,
  }) = _FileItem;

  factory FileItem.fromJson(Map<String, dynamic> json) =>
      _$FileItemFromJson(json);
}

// Extension for file size formatting
extension FileItemX on FileItem {
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get fileExtension => type.toLowerCase();

  IconData get fileIcon {
    switch (type.toUpperCase()) {
      case 'MP4':
      case 'AVI':
      case 'MOV':
        return Icons.video_file;
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'FIGMA':
        return Icons.design_services;
      case 'MYSQL':
      case 'SQL':
        return Icons.storage;
      case 'MP3':
      case 'WAV':
      case 'AUDIO':
        return Icons.audio_file;
      case 'JS':
      case 'DART':
      case 'PYTHON':
        return Icons.code;
      case 'FOLDER':
        return Icons.folder;
      default:
        return Icons.insert_drive_file;
    }
  }
}
```

### FolderItem Model

```dart
// lib/models/folder_item_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'folder_item_model.freezed.dart';
part 'folder_item_model.g.dart';

@freezed
class FolderItem with _$FolderItem {
  const factory FolderItem({
    required String id,
    required String name,
    required int size, // Total size in bytes
    required int fileCount,
    required DateTime modifiedDate,
    String? description,
    @Default([]) List<String> tags,
  }) = _FolderItem;

  factory FolderItem.fromJson(Map<String, dynamic> json) =>
      _$FolderItemFromJson(json);
}

extension FolderItemX on FolderItem {
  String get formattedSize {
    if (size < 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
```

### UserInfo Model

```dart
// lib/models/user_info_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String id,
    required String name,
    required String email,
    String? avatarUrl,
    String? role,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}
```

### FileCategory Enum

```dart
// lib/models/file_category.dart
enum FileCategory {
  myFiles('My Files', 'all'),
  sharedWithMe('Shared with Me', 'shared'),
  recent('Recent', 'recent'),
  favorites('Favorites', 'favorites'),
  downloads('Downloads', 'downloads'),
  trash('Trash', 'trash');

  const FileCategory(this.label, this.value);
  final String label;
  final String value;

  IconData get icon {
    switch (this) {
      case FileCategory.myFiles:
        return Icons.folder;
      case FileCategory.sharedWithMe:
        return Icons.people;
      case FileCategory.recent:
        return Icons.access_time;
      case FileCategory.favorites:
        return Icons.star;
      case FileCategory.downloads:
        return Icons.download;
      case FileCategory.trash:
        return Icons.delete;
    }
  }
}
```

### FileSortOption Enum

```dart
// lib/models/file_sort_option.dart
enum FileSortOption {
  nameAsc('Name (A-Z)', 'name', true),
  nameDesc('Name (Z-A)', 'name', false),
  dateNewest('Date (Newest)', 'modified', false),
  dateOldest('Date (Oldest)', 'modified', true),
  sizeSmallest('Size (Smallest)', 'size', true),
  sizeLargest('Size (Largest)', 'size', false);

  const FileSortOption(this.label, this.field, this.ascending);
  final String label;
  final String field;
  final bool ascending;
}
```

## 4. Widget Component Hierarchy

```
FileManagerView (Main Container)
├─ FileManagerSidebar
│  ├─ SidebarHeader
│  │  └─ UploadFileButton
│  ├─ CategoryListWidget
│  │  ├─ CategoryListItem (My Files) [Active]
│  │  ├─ CategoryListItem (Shared with Me)
│  │  ├─ CategoryListItem (Recent)
│  │  ├─ CategoryListItem (Favorites)
│  │  ├─ CategoryListItem (Downloads)
│  │  └─ CategoryListItem (Trash)
│  └─ TagCategoryList
│     ├─ CategoryDivider
│     ├─ TagCategoryItem (Work - Primary)
│     ├─ TagCategoryItem (Projects - Purple)
│     ├─ TagCategoryItem (Media - Info)
│     └─ TagCategoryItem (Documents - Warning)
│
└─ FileManagerContent
   ├─ FileManagerHeader
   │  ├─ SearchBar
   │  ├─ FilterChipGroup
   │  │  ├─ FileTypeFilterChip
   │  │  └─ RowsPerPageSelector
   │  └─ DeleteSelectedButton [Conditional]
   │
   ├─ FolderCardGrid
   │  └─ FolderCard (×8)
   │     ├─ FolderIcon
   │     ├─ FolderName
   │     ├─ FolderSize
   │     └─ FolderActionsMenu
   │
   ├─ FileTable
   │  ├─ FileTableHeader
   │  │  ├─ SelectAllCheckbox
   │  │  ├─ SortableColumnHeader (Name)
   │  │  ├─ SortableColumnHeader (Type)
   │  │  ├─ SortableColumnHeader (Modified)
   │  │  ├─ SortableColumnHeader (Owner)
   │  │  ├─ ColumnHeader (Shared With)
   │  │  └─ ColumnHeader (Action)
   │  │
   │  └─ FileTableBody
   │     └─ FileTableRow (×N)
   │        ├─ RowCheckbox
   │        ├─ FileInfoCell
   │        │  ├─ FileIcon
   │        │  ├─ FileName
   │        │  └─ FileSize
   │        ├─ FileTypeCell
   │        ├─ ModifiedDateCell
   │        ├─ OwnerCell
   │        │  ├─ OwnerAvatar
   │        │  └─ OwnerEmail
   │        ├─ SharedWithCell
   │        │  └─ AvatarGroup (×N)
   │        └─ ActionsCell
   │           ├─ FavoriteButton
   │           └─ FileActionsMenu
   │
   └─ TablePagination
      ├─ LoadingIndicator [Conditional]
      └─ PaginationControls
```

### Responsive Layout Variations

**Mobile (< 600px)**:
- Sidebar as bottom sheet/drawer (offcanvas)
- Single column layout
- Folder cards: 1 column
- Table: Horizontal scroll with simplified columns
- Hide "Shared With" column
- Stack search and filters vertically

**Tablet (600-899px)**:
- Persistent sidebar (collapsed/icon-only mode optional)
- Folder cards: 2 columns
- Table: Show all columns
- Search bar in header

**Desktop (900-1199px)**:
- Full sidebar with labels
- Folder cards: 3-4 columns
- Table: Full width with all columns
- Inline search and filters

**Wide (≥ 1200px)**:
- Maximum width sidebar
- Folder cards: 4 columns
- Table: Spacious column widths
- Additional filter options

## 5. Detailed Widget Specifications

### 5.1 FileManagerView (Main Layout)

**File**: `lib/views/file_manager/file_manager_view.dart`  
**Size Check**: ~280 lines ✓

```dart
// lib/views/file_manager/file_manager_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/file_manager/index.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import '../../utils/responsive_builder.dart';

class FileManagerView extends ConsumerWidget {
  const FileManagerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(fileManagerViewModelProvider);
    
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context, ref), // Mobile sidebar
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(context, ref),
        tablet: _buildTabletLayout(context, ref),
        desktop: _buildDesktopLayout(context, ref),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('File Manager'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Show search modal on mobile
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Show options menu
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: FileManagerSidebar(
        isDrawer: true,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return const FileManagerContent(
      showHeader: true,
      compactView: true,
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 240,
          child: FileManagerSidebar(isCompact: true),
        ),
        const Expanded(
          child: FileManagerContent(showHeader: true),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 280,
          child: FileManagerSidebar(),
        ),
        const Expanded(
          child: FileManagerContent(showHeader: true),
        ),
      ],
    );
  }
}
```

### 5.2 FileManagerSidebar

**File**: `lib/widgets/file_manager/file_manager_sidebar.dart`  
**Size Check**: ~380 lines ✓

```dart
// lib/widgets/file_manager/file_manager_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import '../../models/file_category.dart';

class FileManagerSidebar extends ConsumerWidget {
  final bool isDrawer;
  final bool isCompact;
  final VoidCallback? onClose;

  const FileManagerSidebar({
    Key? key,
    this.isDrawer = false,
    this.isCompact = false,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(fileManagerViewModelProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          if (isDrawer) _buildDrawerHeader(context),
          _buildUploadButton(context, ref),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildCategorySection(context, ref, viewModel),
                const Divider(height: 32),
                _buildTagSection(context, ref, viewModel),
              ],
            ),
          ),
          _buildStorageInfo(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'File Manager',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleUpload(context, ref),
          icon: const Icon(Icons.upload_file),
          label: Text(isCompact ? 'Upload' : 'Upload Files'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: FileCategory.values.map((category) {
        final isActive = viewModel.selectedCategory == category;
        return _CategoryListTile(
          category: category,
          isActive: isActive,
          isCompact: isCompact,
          onTap: () {
            ref
                .read(fileManagerViewModelProvider.notifier)
                .selectCategory(category);
            if (isDrawer && onClose != null) onClose!();
          },
        );
      }).toList(),
    );
  }

  Widget _buildTagSection(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Categories',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
          ),
        ),
        _TagCategoryTile(
          label: 'Work',
          color: Colors.blue,
          icon: Icons.work,
          isCompact: isCompact,
          onTap: () => _selectTag(ref, 'work'),
        ),
        _TagCategoryTile(
          label: 'Projects',
          color: Colors.purple,
          icon: Icons.folder_special,
          isCompact: isCompact,
          onTap: () => _selectTag(ref, 'projects'),
        ),
        _TagCategoryTile(
          label: 'Media',
          color: Colors.cyan,
          icon: Icons.perm_media,
          isCompact: isCompact,
          onTap: () => _selectTag(ref, 'media'),
        ),
        _TagCategoryTile(
          label: 'Documents',
          color: Colors.orange,
          icon: Icons.description,
          isCompact: isCompact,
          onTap: () => _selectTag(ref, 'documents'),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(BuildContext context) {
    if (isCompact) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.65, // 65% used
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 4),
          Text(
            '6.5 GB of 10 GB used',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _handleUpload(BuildContext context, WidgetRef ref) {
    ref.read(fileManagerViewModelProvider.notifier).uploadFiles();
  }

  void _selectTag(WidgetRef ref, String tag) {
    ref.read(fileManagerViewModelProvider.notifier).filterByTag(tag);
    if (isDrawer && onClose != null) onClose!();
  }
}

// Sub-widgets
class _CategoryListTile extends StatelessWidget {
  final FileCategory category;
  final bool isActive;
  final bool isCompact;
  final VoidCallback onTap;

  const _CategoryListTile({
    required this.category,
    required this.isActive,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        category.icon,
        size: 20,
        color: isActive ? theme.colorScheme.primary : Colors.grey[600],
      ),
      title: isCompact
          ? null
          : Text(
              category.label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? theme.colorScheme.primary : null,
              ),
            ),
      trailing: isCompact || category != FileCategory.myFiles
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '12',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      selected: isActive,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }
}

class _TagCategoryTile extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isCompact;
  final VoidCallback onTap;

  const _TagCategoryTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 16, color: color),
      title: isCompact
          ? null
          : Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
    );
  }
}
```

### 5.3 FileManagerContent

**File**: `lib/widgets/file_manager/file_manager_content.dart`  
**Size Check**: ~250 lines ✓

```dart
// lib/widgets/file_manager/file_manager_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import 'file_manager_header.dart';
import 'folder_card_grid.dart';
import 'file_table.dart';

class FileManagerContent extends ConsumerWidget {
  final bool showHeader;
  final bool compactView;

  const FileManagerContent({
    Key? key,
    this.showHeader = true,
    this.compactView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(fileManagerViewModelProvider);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          if (showHeader)
            FileManagerHeader(
              compactView: compactView,
            ),
          Expanded(
            child: viewModel.isLoading
                ? _buildLoadingState()
                : viewModel.hasError
                    ? _buildErrorState(viewModel.errorMessage)
                    : _buildContent(context, ref, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Folder cards grid
        if (viewModel.folders.isNotEmpty) ...[
          FolderCardGrid(
            folders: viewModel.folders,
            compactView: compactView,
          ),
          const SizedBox(height: 24),
        ],

        // Files table
        if (viewModel.files.isNotEmpty)
          FileTable(
            files: viewModel.files,
            compactView: compactView,
          ),

        // Empty state
        if (viewModel.files.isEmpty && viewModel.folders.isEmpty)
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'An error occurred',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No files or folders',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload files to get started',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.4 FileManagerHeader

**File**: `lib/widgets/file_manager/file_manager_header.dart`  
**Size Check**: ~320 lines ✓

```dart
// lib/widgets/file_manager/file_manager_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/file_manager_viewmodel.dart';

class FileManagerHeader extends ConsumerWidget {
  final bool compactView;

  const FileManagerHeader({
    Key? key,
    this.compactView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(fileManagerViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: compactView
          ? _buildCompactHeader(context, ref, viewModel)
          : _buildFullHeader(context, ref, viewModel),
    );
  }

  Widget _buildCompactHeader(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return Column(
      children: [
        _SearchBar(
          searchQuery: viewModel.searchQuery,
          onSearchChanged: (query) {
            ref
                .read(fileManagerViewModelProvider.notifier)
                .updateSearchQuery(query);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FileTypeFilter(
                selectedType: viewModel.selectedFileType,
                onTypeChanged: (type) {
                  ref
                      .read(fileManagerViewModelProvider.notifier)
                      .filterByType(type);
                },
              ),
            ),
            const SizedBox(width: 8),
            _RowsPerPageSelector(
              rowsPerPage: viewModel.rowsPerPage,
              onChanged: (value) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .setRowsPerPage(value);
              },
            ),
          ],
        ),
        if (viewModel.selectedFilesCount > 0) ...[
          const SizedBox(height: 12),
          _DeleteSelectedButton(
            count: viewModel.selectedFilesCount,
            onPressed: () {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .deleteSelectedFiles();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFullHeader(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: _SearchBar(
                  searchQuery: viewModel.searchQuery,
                  onSearchChanged: (query) {
                    ref
                        .read(fileManagerViewModelProvider.notifier)
                        .updateSearchQuery(query);
                  },
                ),
              ),
              if (viewModel.selectedFilesCount > 0) ...[
                const SizedBox(width: 12),
                _DeleteSelectedButton(
                  count: viewModel.selectedFilesCount,
                  onPressed: () {
                    ref
                        .read(fileManagerViewModelProvider.notifier)
                        .deleteSelectedFiles();
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Filter By:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 150,
          child: _FileTypeFilter(
            selectedType: viewModel.selectedFileType,
            onTypeChanged: (type) {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .filterByType(type);
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: _RowsPerPageSelector(
            rowsPerPage: viewModel.rowsPerPage,
            onChanged: (value) {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .setRowsPerPage(value);
            },
          ),
        ),
      ],
    );
  }
}

// Sub-widgets
class _SearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _SearchBar({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search files...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: onSearchChanged,
    );
  }
}

class _FileTypeFilter extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  const _FileTypeFilter({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'File Type',
        prefixIcon: const Icon(Icons.file_present, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Types')),
        DropdownMenuItem(value: 'Folder', child: Text('Folder')),
        DropdownMenuItem(value: 'MP4', child: Text('Video (MP4)')),
        DropdownMenuItem(value: 'PDF', child: Text('PDF')),
        DropdownMenuItem(value: 'Figma', child: Text('Figma')),
        DropdownMenuItem(value: 'MySQL', child: Text('Database')),
        DropdownMenuItem(value: 'Audio', child: Text('Audio')),
      ],
      onChanged: onTypeChanged,
    );
  }
}

class _RowsPerPageSelector extends StatelessWidget {
  final int rowsPerPage;
  final ValueChanged<int> onChanged;

  const _RowsPerPageSelector({
    required this.rowsPerPage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: rowsPerPage,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      items: const [
        DropdownMenuItem(value: 5, child: Text('5')),
        DropdownMenuItem(value: 10, child: Text('10')),
        DropdownMenuItem(value: 15, child: Text('15')),
        DropdownMenuItem(value: 20, child: Text('20')),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _DeleteSelectedButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _DeleteSelectedButton({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete),
      label: Text('Delete ($count)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      ),
    );
  }
}
```

### 5.5 FolderCardGrid

**File**: `lib/widgets/file_manager/folder_card_grid.dart`  
**Size Check**: ~180 lines ✓

```dart
// lib/widgets/file_manager/folder_card_grid.dart
import 'package:flutter/material.dart';
import '../../models/folder_item_model.dart';
import '../../utils/responsive_builder.dart';
import 'folder_card.dart';

class FolderCardGrid extends StatelessWidget {
  final List<FolderItem> folders;
  final bool compactView;

  const FolderCardGrid({
    Key? key,
    required this.folders,
    this.compactView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildGrid(context, crossAxisCount: 1),
      tablet: _buildGrid(context, crossAxisCount: 2),
      desktop: _buildGrid(context, crossAxisCount: compactView ? 3 : 4),
    );
  }

  Widget _buildGrid(BuildContext context, {required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        return FolderCard(folder: folders[index]);
      },
    );
  }
}
```

### 5.6 FolderCard

**File**: `lib/widgets/file_manager/folder_card.dart`  
**Size Check**: ~240 lines ✓

```dart
// lib/widgets/file_manager/folder_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/folder_item_model.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import 'file_actions_menu.dart';

class FolderCard extends ConsumerWidget {
  final FolderItem folder;

  const FolderCard({
    Key? key,
    required this.folder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleFolderTap(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildFolderIcon(theme),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFolderInfo(theme),
              ),
              _buildActionsMenu(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder,
        size: 28,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildFolderInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          folder.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          folder.formattedSize,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, WidgetRef ref) {
    return FileActionsMenu(
      onShare: () => _handleShare(context, ref),
      onDownload: () => _handleDownload(context, ref),
      onDelete: () => _handleDelete(context, ref),
      onRename: () => _handleRename(context, ref),
    );
  }

  void _handleFolderTap(BuildContext context, WidgetRef ref) {
    ref
        .read(fileManagerViewModelProvider.notifier)
        .openFolder(folder.id);
  }

  void _handleShare(BuildContext context, WidgetRef ref) {
    // Implement share functionality
  }

  void _handleDownload(BuildContext context, WidgetRef ref) {
    ref
        .read(fileManagerViewModelProvider.notifier)
        .downloadFolder(folder.id);
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    _showDeleteConfirmation(context, ref);
  }

  void _handleRename(BuildContext context, WidgetRef ref) {
    // Show rename dialog
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Are you sure you want to delete "${folder.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .deleteFolder(folder.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

### 5.7 FileTable

**File**: `lib/widgets/file_manager/file_table.dart`  
**Size Check**: ~450 lines ✓

```dart
// lib/widgets/file_manager/file_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/file_item_model.dart';
import '../../models/file_sort_option.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import '../../utils/responsive_builder.dart';
import 'file_table_row.dart';

class FileTable extends ConsumerWidget {
  final List<FileItem> files;
  final bool compactView;

  const FileTable({
    Key? key,
    required this.files,
    this.compactView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(fileManagerViewModelProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(context, ref, viewModel),
          _buildTableBody(context, ref),
          if (viewModel.isLoadingMore) _buildLoadingIndicator(),
          _buildPagination(context, ref, viewModel),
        ],
      ),
    );
  }

  Widget _buildTableHeader(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return ResponsiveBuilder(
      mobile: _buildMobileHeader(context, ref, viewModel),
      tablet: _buildFullHeader(context, ref, viewModel, compact: true),
      desktop: _buildFullHeader(context, ref, viewModel),
    );
  }

  Widget _buildMobileHeader(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: viewModel.allFilesSelected,
            tristate: true,
            onChanged: (value) {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .toggleSelectAll();
            },
          ),
          const Expanded(
            child: Text(
              'Files',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<FileSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              ref
                  .read(fileManagerViewModelProvider.notifier)
                  .setSortOption(option);
            },
            itemBuilder: (context) => FileSortOption.values
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Text(option.label),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHeader(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel, {
    bool compact = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: viewModel.allFilesSelected,
              tristate: true,
              onChanged: (value) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .toggleSelectAll();
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: _SortableHeader(
              label: 'Name',
              field: 'name',
              currentSort: viewModel.sortOption,
              onSort: (option) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .setSortOption(option);
              },
            ),
          ),
          Expanded(
            child: _SortableHeader(
              label: 'Type',
              field: 'type',
              currentSort: viewModel.sortOption,
              onSort: (option) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .setSortOption(option);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeader(
              label: 'Modified',
              field: 'modified',
              currentSort: viewModel.sortOption,
              onSort: (option) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .setSortOption(option);
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: _SortableHeader(
              label: 'Owner',
              field: 'owner',
              currentSort: viewModel.sortOption,
              onSort: (option) {
                ref
                    .read(fileManagerViewModelProvider.notifier)
                    .setSortOption(option);
              },
            ),
          ),
          if (!compact)
            const Expanded(
              flex: 2,
              child: Text(
                'Shared With',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(
            width: 100,
            child: Text(
              'Action',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (context, index) {
        return FileTableRow(
          file: files[index],
          compactView: compactView,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading...'),
        ],
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    WidgetRef ref,
    FileManagerViewModel viewModel,
  ) {
    if (!viewModel.hasPagination) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: viewModel.canGoPreviousPage
                ? () {
                    ref
                        .read(fileManagerViewModelProvider.notifier)
                        .previousPage();
                  }
                : null,
          ),
          Text(
            'Page ${viewModel.currentPage} of ${viewModel.totalPages}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: viewModel.canGoNextPage
                ? () {
                    ref.read(fileManagerViewModelProvider.notifier).nextPage();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// Sub-widget for sortable headers
class _SortableHeader extends StatelessWidget {
  final String label;
  final String field;
  final FileSortOption? currentSort;
  final ValueChanged<FileSortOption> onSort;

  const _SortableHeader({
    required this.label,
    required this.field,
    required this.currentSort,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentSort?.field == field;
    final isAscending = currentSort?.ascending ?? true;

    return InkWell(
      onTap: () {
        // Toggle ascending/descending
        final newOption = FileSortOption.values.firstWhere(
          (opt) => opt.field == field && opt.ascending == !isAscending,
          orElse: () => FileSortOption.values.firstWhere(
            (opt) => opt.field == field,
          ),
        );
        onSort(newOption);
      },
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}
```

### 5.8 FileTableRow

**File**: `lib/widgets/file_manager/file_table_row.dart`  
**Size Check**: ~280 lines ✓

```dart
// lib/widgets/file_manager/file_table_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/file_item_model.dart';
import '../../viewmodels/file_manager_viewmodel.dart';
import '../../utils/responsive_builder.dart';
import 'avatar_group.dart';
import 'file_actions_menu.dart';

class FileTableRow extends ConsumerWidget {
  final FileItem file;
  final bool compactView;

  const FileTableRow({
    Key? key,
    required this.file,
    this.compactView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      mobile: _buildMobileRow(context, ref),
      tablet: _buildFullRow(context, ref, compact: true),
      desktop: _buildFullRow(context, ref),
    );
  }

  Widget _buildMobileRow(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: file.isSelected,
        onChanged: (value) {
          ref
              .read(fileManagerViewModelProvider.notifier)
              .toggleFileSelection(file.id);
        },
      ),
      title: Row(
        children: [
          Icon(file.fileIcon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              file.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${file.formattedSize} • ${file.type}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFavoriteButton(context, ref),
          _buildActionsMenu(context, ref),
        ],
      ),
      onTap: () => _handleFileTap(context, ref),
    );
  }

  Widget _buildFullRow(BuildContext context, WidgetRef ref, {bool compact = false}) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _handleFileTap(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: file.isSelected,
                onChanged: (value) {
                  ref
                      .read(fileManagerViewModelProvider.notifier)
                      .toggleFileSelection(file.id);
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildFileInfo(theme),
            ),
            Expanded(
              child: Text(
                file.type,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('MMM d, yyyy').format(file.modifiedDate),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildOwnerInfo(theme),
            ),
            if (!compact)
              Expanded(
                flex: 2,
                child: AvatarGroup(users: file.sharedWith, maxVisible: 4),
              ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildFavoriteButton(context, ref),
                  _buildActionsMenu(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            file.fileIcon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                file.formattedSize,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: file.owner.avatarUrl != null
              ? NetworkImage(file.owner.avatarUrl!)
              : null,
          child: file.owner.avatarUrl == null
              ? Text(
                  file.owner.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            file.owner.email,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        file.isFavorite ? Icons.star : Icons.star_border,
        color: file.isFavorite ? Colors.amber : Colors.grey,
        size: 20,
      ),
      onPressed: () {
        ref
            .read(fileManagerViewModelProvider.notifier)
            .toggleFavorite(file.id);
      },
    );
  }

  Widget _buildActionsMenu(BuildContext context, WidgetRef ref) {
    return FileActionsMenu(
      onShare: () => _handleShare(context, ref),
      onDownload: () => _handleDownload(context, ref),
      onDelete: () => _handleDelete(context, ref),
      onRename: () => _handleRename(context, ref),
    );
  }

  void _handleFileTap(BuildContext context, WidgetRef ref) {
    ref.read(fileManagerViewModelProvider.notifier).openFile(file.id);
  }

  void _handleShare(BuildContext context, WidgetRef ref) {
    // Show share dialog
  }

  void _handleDownload(BuildContext context, WidgetRef ref) {
    ref.read(fileManagerViewModelProvider.notifier).downloadFile(file.id);
  }

  void _handleDelete(BuildContext context, WidgetRef ref) {
    // Show delete confirmation
  }

  void _handleRename(BuildContext context, WidgetRef ref) {
    // Show rename dialog
  }
}
```

### 5.9 AvatarGroup

**File**: `lib/widgets/file_manager/avatar_group.dart`  
**Size Check**: ~150 lines ✓

```dart
// lib/widgets/file_manager/avatar_group.dart
import 'package:flutter/material.dart';
import '../../models/user_info_model.dart';

class AvatarGroup extends StatelessWidget {
  final List<UserInfo> users;
  final int maxVisible;
  final double size;

  const AvatarGroup({
    Key? key,
    required this.users,
    this.maxVisible = 3,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    final visibleUsers = users.take(maxVisible).toList();
    final extraCount = users.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleUsers.map((user) => _buildAvatar(user)),
        if (extraCount > 0) _buildExtraCount(extraCount),
      ],
    );
  }

  Widget _buildAvatar(UserInfo user) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: user.name,
        child: CircleAvatar(
          radius: size / 2,
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(fontSize: size * 0.4),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildExtraCount(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey[300],
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
```

### 5.10 FileActionsMenu

**File**: `lib/widgets/file_manager/file_actions_menu.dart`  
**Size Check**: ~180 lines ✓

```dart
// lib/widgets/file_manager/file_actions_menu.dart
import 'package:flutter/material.dart';

class FileActionsMenu extends StatelessWidget {
  final VoidCallback? onShare;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;
  final VoidCallback? onPin;
  final VoidCallback? onGetLink;

  const FileActionsMenu({
    Key? key,
    this.onShare,
    this.onDownload,
    this.onDelete,
    this.onRename,
    this.onPin,
    this.onGetLink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      offset: const Offset(0, 40),
      itemBuilder: (context) => [
        if (onShare != null)
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, size: 18),
                SizedBox(width: 12),
                Text('Share'),
              ],
            ),
          ),
        if (onGetLink != null)
          const PopupMenuItem(
            value: 'link',
            child: Row(
              children: [
                Icon(Icons.link, size: 18),
                SizedBox(width: 12),
                Text('Get Shareable Link'),
              ],
            ),
          ),
        if (onDownload != null)
          const PopupMenuItem(
            value: 'download',
            child: Row(
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 12),
                Text('Download'),
              ],
            ),
          ),
        if (onPin != null)
          const PopupMenuItem(
            value: 'pin',
            child: Row(
              children: [
                Icon(Icons.push_pin, size: 18),
                SizedBox(width: 12),
                Text('Pin'),
              ],
            ),
          ),
        if (onRename != null)
          const PopupMenuItem(
            value: 'rename',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 12),
                Text('Rename'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: Colors.red),
                SizedBox(width: 12),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'share':
            onShare?.call();
            break;
          case 'link':
            onGetLink?.call();
            break;
          case 'download':
            onDownload?.call();
            break;
          case 'pin':
            onPin?.call();
            break;
          case 'rename':
            onRename?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
    );
  }
}
```

## 6. ViewModel Architecture

```dart
// lib/viewmodels/file_manager_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/file_item_model.dart';
import '../models/folder_item_model.dart';
import '../models/file_category.dart';
import '../models/file_sort_option.dart';
import '../repositories/file_repository.dart';

class FileManagerViewModel extends ChangeNotifier {
  final FileRepository _repository;

  FileManagerViewModel({required FileRepository repository})
      : _repository = repository;

  // State properties
  List<FileItem> _files = [];
  List<FolderItem> _folders = [];
  FileCategory _selectedCategory = FileCategory.myFiles;
  String? _selectedFileType;
  String? _selectedTag;
  String _searchQuery = '';
  FileSortOption _sortOption = FileSortOption.nameAsc;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalPages = 1;

  // Getters
  List<FileItem> get files => _files;
  List<FolderItem> get folders => _folders;
  FileCategory get selectedCategory => _selectedCategory;
  String? get selectedFileType => _selectedFileType;
  String searchQuery => _searchQuery;
  FileSortOption get sortOption => _sortOption;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  int get rowsPerPage => _rowsPerPage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasPagination => _totalPages > 1;
  bool get canGoPreviousPage => _currentPage > 1;
  bool get canGoNextPage => _currentPage < _totalPages;

  int get selectedFilesCount => _files.where((f) => f.isSelected).length;
  bool get allFilesSelected {
    if (_files.isEmpty) return false;
    return _files.every((f) => f.isSelected);
  }

  // Business logic methods
  Future<void> initialize() async {
    await loadFiles();
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getFiles(
        category: _selectedCategory.value,
        fileType: _selectedFileType,
        tag: _selectedTag,
        searchQuery: _searchQuery,
        sortBy: _sortOption.field,
        ascending: _sortOption.ascending,
        page: _currentPage,
        limit: _rowsPerPage,
      );

      _files = result.files;
      _folders = result.folders;
      _totalPages = result.totalPages;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreFiles() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.getFiles(
        category: _selectedCategory.value,
        fileType: _selectedFileType,
        tag: _selectedTag,
        searchQuery: _searchQuery,
        sortBy: _sortOption.field,
        ascending: _sortOption.ascending,
        page: _currentPage + 1,
        limit: _rowsPerPage,
      );

      _files.addAll(result.files);
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void selectCategory(FileCategory category) {
    _selectedCategory = category;
    _currentPage = 1;
    loadFiles();
  }

  void filterByType(String? type) {
    _selectedFileType = type;
    _currentPage = 1;
    loadFiles();
  }

  void filterByTag(String tag) {
    _selectedTag = tag;
    _currentPage = 1;
    loadFiles();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    // Debounce search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchQuery == query) {
        loadFiles();
      }
    });
  }

  void setSortOption(FileSortOption option) {
    _sortOption = option;
    _sortFiles();
    notifyListeners();
  }

  void setRowsPerPage(int rows) {
    _rowsPerPage = rows;
    _currentPage = 1;
    loadFiles();
  }

  void nextPage() {
    if (canGoNextPage) {
      _currentPage++;
      loadFiles();
    }
  }

  void previousPage() {
    if (canGoPreviousPage) {
      _currentPage--;
      loadFiles();
    }
  }

  void toggleFileSelection(String fileId) {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(
        isSelected: !_files[index].isSelected,
      );
      notifyListeners();
    }
  }

  void toggleSelectAll() {
    final shouldSelectAll = !allFilesSelected;
    _files = _files
        .map((f) => f.copyWith(isSelected: shouldSelectAll))
        .toList();
    notifyListeners();
  }

  void toggleFavorite(String fileId) async {
    final index = _files.indexWhere((f) => f.id == fileId);
    if (index != -1) {
      final newFavoriteStatus = !_files[index].isFavorite;
      _files[index] = _files[index].copyWith(isFavorite: newFavoriteStatus);
      notifyListeners();

      try {
        await _repository.updateFileFavorite(fileId, newFavoriteStatus);
      } catch (e) {
        // Revert on error
        _files[index] = _files[index].copyWith(isFavorite: !newFavoriteStatus);
        notifyListeners();
      }
    }
  }

  Future<void> uploadFiles() async {
    // Implement file upload logic
    try {
      await _repository.uploadFiles();
      await loadFiles();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> downloadFile(String fileId) async {
    try {
      await _repository.downloadFile(fileId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> downloadFolder(String folderId) async {
    try {
      await _repository.downloadFolder(folderId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _repository.deleteFile(fileId);
      _files.removeWhere((f) => f.id == fileId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      await _repository.deleteFolder(folderId);
      _folders.removeWhere((f) => f.id == folderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSelectedFiles() async {
    final selectedIds = _files
        .where((f) => f.isSelected)
        .map((f) => f.id)
        .toList();

    try {
      await _repository.deleteFiles(selectedIds);
      _files.removeWhere((f) => f.isSelected);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void openFile(String fileId) {
    // Navigate to file preview/editor
  }

  void openFolder(String folderId) {
    // Navigate into folder
  }

  void _sortFiles() {
    _files.sort((a, b) {
      int comparison;
      switch (_sortOption.field) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'modified':
          comparison = a.modifiedDate.compareTo(b.modifiedDate);
          break;
        case 'size':
          comparison = a.size.compareTo(b.size);
          break;
        case 'owner':
          comparison = a.owner.email.compareTo(b.owner.email);
          break;
        default:
          comparison = 0;
      }
      return _sortOption.ascending ? comparison : -comparison;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

## 7. Riverpod Provider Setup

```dart
// lib/providers/file_manager_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/file_manager_viewmodel.dart';
import '../repositories/file_repository.dart';
import '../services/api_client.dart';

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Repository provider
final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FileRepository(apiClient: apiClient);
});

// ViewModel provider
final fileManagerViewModelProvider =
    ChangeNotifierProvider<FileManagerViewModel>((ref) {
  final repository = ref.watch(fileRepositoryProvider);
  final viewModel = FileManagerViewModel(repository: repository);
  viewModel.initialize();
  return viewModel;
});

// Selector providers for specific state slices
final filesProvider = Provider<List<FileItem>>((ref) {
  return ref.watch(fileManagerViewModelProvider).files;
});

final foldersProvider = Provider<List<FolderItem>>((ref) {
  return ref.watch(fileManagerViewModelProvider).folders;
});

final selectedCategoryProvider = Provider<FileCategory>((ref) {
  return ref.watch(fileManagerViewModelProvider).selectedCategory;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fileManagerViewModelProvider).isLoading;
});
```

## 8. View Implementation

Already covered in Section 5.1 (FileManagerView).

## 9. Responsive Design

### Breakpoint Definitions

```dart
// lib/utils/responsive_breakpoints.dart
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;
}
```

### Layout Adaptations Table

| Feature | Mobile (< 600px) | Tablet (600-899px) | Desktop (≥ 900px) |
|---------|------------------|-------------------|-------------------|
| **Sidebar** | Drawer/Bottom sheet | Collapsed (icon only) | Full width (280px) |
| **Folder Cards** | 1 column | 2 columns | 3-4 columns |
| **File Table** | Simplified (horizontal scroll) | All columns | Spacious columns |
| **Search Bar** | Full width | Header inline | Header inline |
| **Filter Chips** | Vertical stack | Horizontal row | Horizontal row |
| **Actions Menu** | Condensed | Full | Full |
| **Shared With Column** | Hidden | Visible | Visible |
| **Avatar Group** | Max 2 visible | Max 3 visible | Max 4 visible |

### ResponsiveBuilder Pattern

```dart
// lib/utils/responsive_builder.dart
import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

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
        if (ResponsiveBreakpoints.isDesktop(constraints.maxWidth)) {
          return desktop ?? tablet ?? mobile;
        } else if (ResponsiveBreakpoints.isTablet(constraints.maxWidth)) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

## 10. File Structure

```
lib/
├── main.dart
├── models/
│   ├── file_item_model.dart
│   ├── file_item_model.freezed.dart
│   ├── file_item_model.g.dart
│   ├── folder_item_model.dart
│   ├── folder_item_model.freezed.dart
│   ├── folder_item_model.g.dart
│   ├── user_info_model.dart
│   ├── user_info_model.freezed.dart
│   ├── user_info_model.g.dart
│   ├── file_category.dart
│   └── file_sort_option.dart
│
├── viewmodels/
│   └── file_manager_viewmodel.dart
│
├── views/
│   └── file_manager/
│       └── file_manager_view.dart
│
├── widgets/
│   └── file_manager/
│       ├── index.dart                        # Barrel export
│       ├── file_manager_sidebar.dart
│       ├── file_manager_content.dart
│       ├── file_manager_header.dart
│       ├── folder_card_grid.dart
│       ├── folder_card.dart
│       ├── file_table.dart
│       ├── file_table_row.dart
│       ├── avatar_group.dart
│       └── file_actions_menu.dart
│
├── repositories/
│   └── file_repository.dart
│
├── services/
│   └── api_client.dart
│
├── providers/
│   └── file_manager_providers.dart
│
└── utils/
    ├── responsive_breakpoints.dart
    └── responsive_builder.dart
```

### Barrel Export Example

```dart
// lib/widgets/file_manager/index.dart
export 'file_manager_sidebar.dart';
export 'file_manager_content.dart';
export 'file_manager_header.dart';
export 'folder_card_grid.dart';
export 'folder_card.dart';
export 'file_table.dart';
export 'file_table_row.dart';
export 'avatar_group.dart';
export 'file_actions_menu.dart';
```

## 11. Required Packages

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # HTTP & API
  dio: ^5.4.0
  
  # Date & Time
  intl: ^0.18.1
  
  # File Operations
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  
  # Utilities
  equatable: ^2.0.5

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.6
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
```

### Package Purposes

- **flutter_riverpod**: State management with dependency injection
- **freezed**: Immutable data classes with code generation
- **dio**: HTTP client for API requests
- **intl**: Date/time formatting and internationalization
- **file_picker**: Platform file picker for uploads
- **cached_network_image**: Efficient image loading with caching
- **flutter_svg**: SVG icon support

## 12. Theme Configuration

```dart
// lib/theme/file_manager_theme.dart
import 'package:flutter/material.dart';

class FileManagerTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6658DD), // Primary purple from template
      brightness: Brightness.light,
    ),
    
    // Card theme
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
    
    // List tile theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
      dense: true,
    ),
    
    // Divider theme
    dividerTheme: const DividerThemeData(
      thickness: 1,
      space: 1,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6658DD),
      brightness: Brightness.dark,
    ),
    // Same theme configurations as light theme
  );
}

// Design tokens
class FileManagerDesignTokens {
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  
  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  
  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  
  // Avatar sizes
  static const double avatarSmall = 24.0;
  static const double avatarMedium = 32.0;
  static const double avatarLarge = 48.0;
  
  // File type colors
  static const Color colorVideo = Color(0xFF6658DD);
  static const Color colorPDF = Color(0xFFE63946);
  static const Color colorFigma = Color(0xFFA855F7);
  static const Color colorDatabase = Color(0xFF0EA5E9);
  static const Color colorAudio = Color(0xFFF59E0B);
  static const Color colorCode = Color(0xFF10B981);
  static const Color colorFolder = Color(0xFF6366F1);
}
```

## 13. API Integration

### Repository Pattern

```dart
// lib/repositories/file_repository.dart
import 'package:dio/dio.dart';
import '../models/file_item_model.dart';
import '../models/folder_item_model.dart';
import '../services/api_client.dart';

class FileListResult {
  final List<FileItem> files;
  final List<FolderItem> folders;
  final int totalPages;

  FileListResult({
    required this.files,
    required this.folders,
    required this.totalPages,
  });
}

class FileRepository {
  final ApiClient _apiClient;

  FileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<FileListResult> getFiles({
    String? category,
    String? fileType,
    String? tag,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/files',
        queryParameters: {
          if (category != null) 'category': category,
          if (fileType != null) 'type': fileType,
          if (tag != null) 'tag': tag,
          if (searchQuery != null) 'search': searchQuery,
          if (sortBy != null) 'sortBy': sortBy,
          'ascending': ascending,
          'page': page,
          'limit': limit,
        },
      );

      final files = (response.data['files'] as List)
          .map((json) => FileItem.fromJson(json))
          .toList();

      final folders = (response.data['folders'] as List)
          .map((json) => FolderItem.fromJson(json))
          .toList();

      return FileListResult(
        files: files,
        folders: folders,
        totalPages: response.data['totalPages'] ?? 1,
      );
    } catch (e) {
      throw Exception('Failed to load files: $e');
    }
  }

  Future<void> uploadFiles() async {
    // Implement file upload
    // Use file_picker to select files, then upload via multipart
  }

  Future<void> downloadFile(String fileId) async {
    try {
      await _apiClient.download('/files/$fileId/download');
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<void> downloadFolder(String folderId) async {
    try {
      await _apiClient.download('/folders/$folderId/download');
    } catch (e) {
      throw Exception('Failed to download folder: $e');
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _apiClient.delete('/files/$fileId');
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Future<void> deleteFolder(String folderId) async {
    try {
      await _apiClient.delete('/folders/$folderId');
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  Future<void> deleteFiles(List<String> fileIds) async {
    try {
      await _apiClient.post('/files/batch-delete', data: {
        'ids': fileIds,
      });
    } catch (e) {
      throw Exception('Failed to delete files: $e');
    }
  }

  Future<void> updateFileFavorite(String fileId, bool isFavorite) async {
    try {
      await _apiClient.patch('/files/$fileId', data: {
        'isFavorite': isFavorite,
      });
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }
}
```

### API Client

```dart
// lib/services/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.codevald.com/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
  }) async {
    return await _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<void> download(String path) async {
    // Implement file download logic
  }
}
```

## 14. Implementation Notes

### Special Considerations

1. **File Upload**: Use `file_picker` package with multipart/form-data uploads
2. **Large File Lists**: Implement virtual scrolling with `ListView.builder` and pagination
3. **File Previews**: Different preview widgets based on file type (PDF viewer, video player, etc.)
4. **Drag & Drop**: Future enhancement for desktop - use `desktop_drop` package
5. **Offline Support**: Cache file metadata locally with `sqflite`

### Performance Optimizations

1. **Image Caching**: Use `cached_network_image` for avatar and thumbnail caching
2. **List Virtualization**: Use `ListView.builder` instead of `Column` for file lists
3. **Debounced Search**: Implement 300ms debounce on search input
4. **Lazy Loading**: Load folders first, then files progressively
5. **Memo ization**: Use `useMemoized` hook for expensive computations

### Accessibility Features

1. **Semantic Labels**: Add `Semantics` widgets for screen readers
2. **Keyboard Navigation**: Support Tab, Arrow keys, Enter for selection
3. **Focus Management**: Proper focus order through form fields and buttons
4. **Color Contrast**: WCAG AA compliant color ratios (4.5:1 for text)
5. **Screen Reader Announcements**: Use `SemanticsService.announce()` for actions

### Testing Strategies

1. **Unit Tests**: Test ViewModel business logic, sorting, filtering
2. **Widget Tests**: Test individual widgets (FolderCard, FileTableRow)
3. **Integration Tests**: Test complete file manager flow
4. **Golden Tests**: Visual regression testing for layouts
5. **Mock Data**: Use `mockito` to mock FileRepository responses

## 15. Usage Example

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'views/file_manager/file_manager_view.dart';
import 'theme/file_manager_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeVald File Manager',
      theme: FileManagerTheme.lightTheme,
      darkTheme: FileManagerTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const FileManagerView(),
    );
  }
}
```

### Integration Example in Existing App

```dart
// Navigate to File Manager from dashboard
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FileManagerView(),
  ),
);

// Or use go_router
context.go('/file-manager');
```

## 16. Related Documents

- [Dashboard Design](dashboard-design.md) - Main layout and navigation patterns
- [Design Patterns](design-patterns.md) - Reusable widget components
- [Responsive Framework](responsive-framework.md) - Responsive design system
- [Theme Configuration](theme-configuration.md) - App-wide theming
- [API Integration Guide](api-integration.md) - Backend API patterns

### MVP Task References

- **MVP-FL-004**: File Manager Implementation
- **MVP-FL-001**: Dashboard & Navigation
- **MVP-FL-006**: Workflow Artifacts Viewer
- **MVP-BE-003**: File Storage & Management API

---

**Implementation Priority**: High  
**Estimated Effort**: 5-7 days  
**Dependencies**: API endpoints for file CRUD operations, authentication  
**Next Steps**: 
1. Implement base models and repositories
2. Create core widgets (sidebar, header, content)
3. Build file table with sorting/filtering
4. Add upload/download functionality
5. Implement responsive layouts
6. Add tests and polish UI

**Notes**: This design follows the 500-line rule with all widgets properly split. The file manager can be easily extended with features like file sharing, version history, and collaborative editing.
