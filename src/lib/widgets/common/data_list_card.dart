import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// A card for displaying structured lists with filtering and sorting
class DataListCard<T> extends StatelessWidget {
  /// The title of the list
  final String title;

  /// Optional subtitle or description
  final String? subtitle;

  /// List of data items
  final List<T> items;

  /// Widget builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional empty state widget
  final Widget? emptyWidget;

  /// Optional header actions
  final List<Widget>? actions;

  /// Whether to show dividers between items
  final bool showDividers;

  /// Maximum height of the list (scrollable if exceeds)
  final double? maxHeight;

  const DataListCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    required this.itemBuilder,
    this.emptyWidget,
    this.actions,
    this.showDividers = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppTheme.space4),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),

            const SizedBox(height: AppTheme.space16),

            // List content
            if (items.isEmpty)
              _buildEmptyState(context)
            else
              _buildList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return emptyWidget ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space24),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  'No items to display',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildList(BuildContext context) {
    final listWidget = ListView.separated(
      shrinkWrap: true,
      physics: maxHeight != null
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        if (!showDividers) return const SizedBox.shrink();
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );

    if (maxHeight != null) {
      return SizedBox(height: maxHeight, child: listWidget);
    }

    return listWidget;
  }
}

/// Simple list item widget for DataListCard
class DataListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const DataListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
    );
  }
}
