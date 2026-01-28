import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';

/// Enhanced metric card with sparkline chart and comparison features
class MetricCard extends StatelessWidget {
  /// The title of the metric
  final String title;

  /// The main value to display
  final String value;

  /// Optional change percentage (e.g., "+12.5%")
  final String? changePercent;

  /// Whether the change is positive
  final bool isPositive;

  /// Icon to display
  final IconData icon;

  /// Color for the icon and chart
  final Color color;

  /// Data points for sparkline chart (optional)
  final List<double>? sparklineData;

  /// Comparison value label (e.g., "Last month")
  final String? comparisonLabel;

  /// Comparison value
  final String? comparisonValue;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.changePercent,
    this.isPositive = true,
    required this.icon,
    required this.color,
    this.sparklineData,
    this.comparisonLabel,
    this.comparisonValue,
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
              // Header: Icon and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.space16),

              // Value and Change
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (changePercent != null) ...[
                    const SizedBox(width: AppTheme.space8),
                    _buildChangeChip(context),
                  ],
                ],
              ),

              // Sparkline Chart
              if (sparklineData != null && sparklineData!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.space16),
                SizedBox(height: 60, child: _buildSparkline(context)),
              ],

              // Comparison
              if (comparisonLabel != null && comparisonValue != null) ...[
                const SizedBox(height: AppTheme.space12),
                _buildComparison(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangeChip(BuildContext context) {
    final changeColor = isPositive
        ? AppTheme.successColor
        : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space8,
        vertical: AppTheme.space4,
      ),
      decoration: BoxDecoration(
        color: changeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: changeColor,
            size: 12,
          ),
          const SizedBox(width: AppTheme.space4),
          Text(
            changePercent!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkline(BuildContext context) {
    if (sparklineData == null || sparklineData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = sparklineData!
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: (sparklineData!.length - 1).toDouble(),
        minY: sparklineData!.reduce((a, b) => a < b ? a : b) * 0.9,
        maxY: sparklineData!.reduce((a, b) => a > b ? a : b) * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison(BuildContext context) {
    return Row(
      children: [
        Text(
          '$comparisonLabel: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          comparisonValue!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
