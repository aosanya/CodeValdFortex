import 'package:equatable/equatable.dart';

/// Model representing dashboard statistics data
class StatsData extends Equatable {
  /// Today's order count
  final int todayOrders;

  /// Today's earnings amount
  final double todayEarnings;

  /// Profit gain percentage
  final double profitGain;

  /// Total earnings amount
  final double totalEarnings;

  /// Trend direction for today's orders (positive/negative percentage)
  final double todayOrdersTrend;

  /// Trend direction for today's earnings
  final double todayEarningsTrend;

  /// Trend direction for profit gain
  final double profitGainTrend;

  /// Trend direction for total earnings
  final double totalEarningsTrend;

  const StatsData({
    required this.todayOrders,
    required this.todayEarnings,
    required this.profitGain,
    required this.totalEarnings,
    this.todayOrdersTrend = 0.0,
    this.todayEarningsTrend = 0.0,
    this.profitGainTrend = 0.0,
    this.totalEarningsTrend = 0.0,
  });

  /// Creates a copy with updated fields
  StatsData copyWith({
    int? todayOrders,
    double? todayEarnings,
    double? profitGain,
    double? totalEarnings,
    double? todayOrdersTrend,
    double? todayEarningsTrend,
    double? profitGainTrend,
    double? totalEarningsTrend,
  }) {
    return StatsData(
      todayOrders: todayOrders ?? this.todayOrders,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      profitGain: profitGain ?? this.profitGain,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayOrdersTrend: todayOrdersTrend ?? this.todayOrdersTrend,
      todayEarningsTrend: todayEarningsTrend ?? this.todayEarningsTrend,
      profitGainTrend: profitGainTrend ?? this.profitGainTrend,
      totalEarningsTrend: totalEarningsTrend ?? this.totalEarningsTrend,
    );
  }

  /// Creates an empty stats data object
  factory StatsData.empty() {
    return const StatsData(
      todayOrders: 0,
      todayEarnings: 0.0,
      profitGain: 0.0,
      totalEarnings: 0.0,
    );
  }

  /// Creates a mock stats data object for testing/development
  factory StatsData.mock() {
    return const StatsData(
      todayOrders: 245,
      todayEarnings: 12500.50,
      profitGain: 23.5,
      totalEarnings: 450320.75,
      todayOrdersTrend: 5.2,
      todayEarningsTrend: 3.1,
      profitGainTrend: -1.5,
      totalEarningsTrend: 8.7,
    );
  }

  @override
  List<Object?> get props => [
    todayOrders,
    todayEarnings,
    profitGain,
    totalEarnings,
    todayOrdersTrend,
    todayEarningsTrend,
    profitGainTrend,
    totalEarningsTrend,
  ];
}

/// Model representing chart data point
class ChartDataPoint extends Equatable {
  /// X-axis value (typically time or category)
  final String x;

  /// Y-axis value
  final double y;

  /// Optional label
  final String? label;

  const ChartDataPoint({required this.x, required this.y, this.label});

  @override
  List<Object?> get props => [x, y, label];
}

/// Model representing chart data for dashboard
class ChartData extends Equatable {
  /// Chart title
  final String title;

  /// Data points
  final List<ChartDataPoint> dataPoints;

  /// Chart type identifier
  final String chartType;

  const ChartData({
    required this.title,
    required this.dataPoints,
    this.chartType = 'line',
  });

  /// Creates empty chart data
  factory ChartData.empty() {
    return const ChartData(title: '', dataPoints: []);
  }

  /// Creates mock chart data for testing/development
  factory ChartData.mock() {
    return ChartData(
      title: 'Weekly Performance',
      chartType: 'line',
      dataPoints: [
        const ChartDataPoint(x: 'Mon', y: 120),
        const ChartDataPoint(x: 'Tue', y: 150),
        const ChartDataPoint(x: 'Wed', y: 135),
        const ChartDataPoint(x: 'Thu', y: 180),
        const ChartDataPoint(x: 'Fri', y: 165),
        const ChartDataPoint(x: 'Sat', y: 195),
        const ChartDataPoint(x: 'Sun', y: 175),
      ],
    );
  }

  @override
  List<Object?> get props => [title, dataPoints, chartType];
}
