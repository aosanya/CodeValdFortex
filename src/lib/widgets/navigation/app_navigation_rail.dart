import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

/// NavigationRail for desktop sidebar navigation
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({super.key, this.extended = true});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _getSelectedIndex(currentLocation);

    return NavigationRail(
      extended: extended,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index >= 0 && index < navMenuItems.length) {
          context.go(navMenuItems[index].path);
        }
      },
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Icon(
              Icons.radar,
              size: extended ? 40 : 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (extended) ...[
              const SizedBox(height: 8),
              Text(
                'CodeVald',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () => context.go('/'),
            ),
          ),
        ),
      ),
      destinations: navMenuItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }

  int _getSelectedIndex(String currentLocation) {
    for (int i = 0; i < navMenuItems.length; i++) {
      if (currentLocation.startsWith(navMenuItems[i].path)) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }
}
