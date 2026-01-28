import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// A card container for displaying charts and visualizations
class ChartCard extends StatelessWidget {
  /// The title of the chart
  final String title;

  /// Optional subtitle or description
  final String? subtitle;

  /// The chart widget to display
  final Widget chart;

  /// Optional legend widget
  final Widget? legend;

  /// Optional action button
  final Widget? action;

  /// Card height (defaults to 300)
  final double? height;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.legend,
    this.action,
    this.height,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                  if (action != null) action!,
                ],
              ),

              const SizedBox(height: AppTheme.space16),

              // Chart
              SizedBox(height: height ?? 300, child: chart),

              // Legend
              if (legend != null) ...[
                const SizedBox(height: AppTheme.space16),
                legend!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Legend item for charts
class ChartLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String? value;

  const ChartLegendItem({
    super.key,
    required this.color,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
        const SizedBox(width: AppTheme.space8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        if (value != null) ...[
          const SizedBox(width: AppTheme.space4),
          Text(
            value!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

/// Horizontal legend for charts
class ChartLegend extends StatelessWidget {
  final List<ChartLegendItem> items;
  final MainAxisAlignment alignment;

  const ChartLegend({
    super.key,
    required this.items,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.space16,
      runSpacing: AppTheme.space8,
      alignment: WrapAlignment.center,
      children: items,
    );
  }
}
