import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import 'breadcrumb.dart';

/// App-wide navigation AppBar with breadcrumbs and actions
class AppNavigationBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppNavigationBar({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return AppBar(
      title: title != null ? Text(title!) : const BreadcrumbWidget(),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            // Search functionality to be implemented
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search feature coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),

        // Theme toggle
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
        ),

        // Notifications
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications feature coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),

        // User profile menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle),
          tooltip: 'Account',
          onSelected: (value) {
            switch (value) {
              case 'profile':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile coming soon')),
                );
                break;
              case 'settings':
                context.go('/settings');
                break;
              case 'logout':
                // Handle logout
                context.go('/');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign Out'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
