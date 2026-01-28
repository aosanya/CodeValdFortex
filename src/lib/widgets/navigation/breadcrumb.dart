import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Breadcrumb item data
class BreadcrumbItem {
  final String label;
  final String? path;

  const BreadcrumbItem({required this.label, this.path});
}

/// Breadcrumb widget that auto-generates navigation trail from current route
class BreadcrumbWidget extends StatelessWidget {
  const BreadcrumbWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final breadcrumbs = _generateBreadcrumbs(location);

    // Hide breadcrumbs on mobile
    if (MediaQuery.of(context).size.width < 600) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < breadcrumbs.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          _BreadcrumbLink(
            item: breadcrumbs[i],
            isLast: i == breadcrumbs.length - 1,
          ),
        ],
      ],
    );
  }

  List<BreadcrumbItem> _generateBreadcrumbs(String location) {
    final breadcrumbs = <BreadcrumbItem>[];

    // Always start with home
    breadcrumbs.add(const BreadcrumbItem(label: 'Home', path: '/'));

    // Parse location path
    final segments = location.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return breadcrumbs;

    String currentPath = '';
    for (int i = 0; i < segments.length; i++) {
      currentPath += '/${segments[i]}';
      final label = _formatLabel(segments[i]);

      // Don't make last item clickable
      final path = i < segments.length - 1 ? currentPath : null;

      breadcrumbs.add(BreadcrumbItem(label: label, path: path));
    }

    return breadcrumbs;
  }

  String _formatLabel(String segment) {
    // Handle special cases
    final labelMap = {
      'auth': 'Authentication',
      'work-items': 'Work Items',
      'agencies': 'Agencies',
      'agents': 'Agents',
      'settings': 'Settings',
      'dashboard': 'Dashboard',
      'login': 'Sign In',
      'register': 'Register',
      'create': 'Create',
    };

    if (labelMap.containsKey(segment)) {
      return labelMap[segment]!;
    }

    // Check if it's an ID (UUID or number pattern)
    if (RegExp(r'^[0-9a-f-]{8,}$').hasMatch(segment) ||
        RegExp(r'^\d+$').hasMatch(segment)) {
      return 'Details';
    }

    // Default: capitalize first letter and replace hyphens/underscores
    return segment
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _BreadcrumbLink extends StatelessWidget {
  const _BreadcrumbLink({required this.item, required this.isLast});

  final BreadcrumbItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
      color: isLast
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );

    if (item.path == null || isLast) {
      return Text(item.label, style: textStyle);
    }

    return InkWell(
      onTap: () => context.go(item.path!),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Text(
          item.label,
          style: textStyle?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
