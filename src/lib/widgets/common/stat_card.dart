import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// A card widget for displaying key statistics with optional trend indicators
class StatCard extends StatelessWidget {
  /// The title of the statistic
  final String title;

  /// The main value to display
  final String value;

  /// Optional change value (e.g., "+123" or "-45")
  final String? change;

  /// Whether the change is positive (green) or negative (red)
  final bool isPositive;

  /// Icon to display
  final IconData icon;

  /// Color for the icon background
  final Color color;

  /// Optional subtitle text
  final String? subtitle;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Title and Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.space12),

              // Value
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              // Change indicator or subtitle
              if (change != null || subtitle != null) ...[
                const SizedBox(height: AppTheme.space8),
                if (change != null)
                  _buildChangeIndicator(context)
                else if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context) {
    final changeColor = isPositive
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Row(
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: changeColor,
          size: 16,
        ),
        const SizedBox(width: AppTheme.space4),
        Text(
          change!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: changeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppTheme.space4),
        Text(
          'vs last period',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
