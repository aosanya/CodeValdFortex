import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation menu item data
class NavMenuItem {
  final String label;
  final IconData icon;
  final String path;
  final List<NavMenuItem>? children;

  const NavMenuItem({
    required this.label,
    required this.icon,
    required this.path,
    this.children,
  });
}

/// Navigation menu items
const List<NavMenuItem> navMenuItems = [
  NavMenuItem(label: 'Dashboard', icon: Icons.dashboard, path: '/dashboard'),
  NavMenuItem(label: 'Work Items', icon: Icons.work, path: '/work-items'),
  NavMenuItem(label: 'Agencies', icon: Icons.business, path: '/agencies'),
  NavMenuItem(label: 'Agents', icon: Icons.smart_toy, path: '/agents'),
  NavMenuItem(label: 'Settings', icon: Icons.settings, path: '/settings'),
];

/// App Drawer navigation for mobile/tablet
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.radar,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 8),
                Text(
                  'CodeVald Fortex',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Agency Management',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          ...navMenuItems.map(
            (item) => _buildMenuItem(context, item, currentLocation),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    NavMenuItem item,
    String currentLocation,
  ) {
    final isSelected = currentLocation.startsWith(item.path);

    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      selected: isSelected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.go(item.path);
      },
    );
  }
}
