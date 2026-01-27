# Flutter Design Patterns Guide

This guide provides reusable Flutter patterns extracted from HTML template references.

## Table of Contents

1. [Dashboard Layout](#dashboard-layout)
2. [Stat Cards](#stat-cards)
3. [Navigation Drawer](#navigation-drawer)
4. [Data Tables](#data-tables)
5. [Charts & Visualizations](#charts--visualizations)
6. [List Items](#list-items)
7. [Theme Configuration](#theme-configuration)

---

## Dashboard Layout

### Responsive Dashboard Structure

```dart
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Search
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          // Notifications
          Badge(
            label: const Text('6'),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
          // Profile
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage('https://...'),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid columns
          final crossAxisCount = constraints.maxWidth > 1200 ? 4 :
                                  constraints.maxWidth > 800 ? 3 :
                                  constraints.maxWidth > 600 ? 2 : 1;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                _buildBreadcrumb(context),
                const SizedBox(height: 16),
                
                // Stats Cards Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Today Orders',
                      value: '5,472',
                      change: '+427',
                      isPositive: true,
                      icon: Icons.shopping_bag,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Today Earnings',
                      value: '\$7,589',
                      change: '-453',
                      isPositive: false,
                      icon: Icons.attach_money,
                      color: Colors.cyan,
                    ),
                    // More stat cards...
                  ],
                ),
                const SizedBox(height: 24),
                
                // Charts Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ProjectBudgetChart(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BrowserUsageCard(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('Dashboard'),
        ),
        const Icon(Icons.chevron_right, size: 16),
        const Text('Sales'),
      ],
    );
  }
}
```

---

## Stat Cards

### Enhanced Stat Card with Trend Indicator

```dart
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Left side: Text content
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        subtitle ?? 'Last week',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right side: Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Navigation Drawer

### Multi-Level Navigation Drawer

```dart
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header with logo
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo.png', height: 40),
                const Spacer(),
                const Text(
                  'CodeVald Fortex',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Category label
                _buildCategoryLabel('MAIN'),
                
                // Dashboards submenu
                ExpansionTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboards'),
                  children: [
                    _buildSubMenuItem(
                      context,
                      'Dashboard 1',
                      '/dashboard1',
                    ),
                    _buildSubMenuItem(
                      context,
                      'Dashboard 2',
                      '/dashboard2',
                    ),
                  ],
                ),
                
                _buildCategoryLabel('WEB APPS'),
                
                // Apps submenu
                ExpansionTile(
                  leading: const Icon(Icons.apps),
                  title: const Text('Apps'),
                  children: [
                    _buildSubMenuItem(context, 'Calendar', '/calendar'),
                    _buildSubMenuItem(context, 'Contacts', '/contacts'),
                    _buildSubMenuItem(context, 'Gallery', '/gallery'),
                  ],
                ),
                
                // Single menu item
                ListTile(
                  leading: const Icon(Icons.widgets),
                  title: const Text('Widgets'),
                  onTap: () {
                    Navigator.pushNamed(context, '/widgets');
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildSubMenuItem(BuildContext context, String title, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
```

---

## Data Tables

### Sortable and Filterable Data Table

```dart
class ProductTable extends StatefulWidget {
  const ProductTable({Key? key}) : super(key: key);

  @override
  State<ProductTable> createState() => _ProductTableState();
}

class _ProductTableState extends State<ProductTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  String _searchQuery = '';
  
  final List<Map<String, dynamic>> _products = [
    {
      'date': '#01',
      'client': 'Sean Black',
      'productId': 'PRO12345',
      'product': 'Mi LED Smart TV 4A 80',
      'cost': 14500,
      'payment': 'Online Payment',
      'status': 'Delivered',
    },
    // More products...
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product['client']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Product Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Search and filter bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort By'),
                    onPressed: null,
                  ),
                  onSelected: (value) {
                    // Handle sorting
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'date', child: Text('Date')),
                    const PopupMenuItem(value: 'client', child: Text('Client')),
                    const PopupMenuItem(value: 'cost', child: Text('Cost')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Data Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: const Text('Date'),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  const DataColumn(label: Text('Client Name')),
                  const DataColumn(label: Text('Product ID')),
                  const DataColumn(label: Text('Product')),
                  const DataColumn(label: Text('Cost')),
                  const DataColumn(label: Text('Payment Mode')),
                  const DataColumn(label: Text('Status')),
                ],
                rows: filteredProducts.map((product) {
                  return DataRow(cells: [
                    DataCell(Text(product['date'])),
                    DataCell(Text(product['client'])),
                    DataCell(Text(product['productId'])),
                    DataCell(Text(product['product'])),
                    DataCell(Text('\$${product['cost']}')),
                    DataCell(Text(product['payment'])),
                    DataCell(_buildStatusBadge(product['status'])),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'shipped':
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

## Charts & Visualizations

### Using fl_chart for Line Charts

```dart
import 'package:fl_chart/fl_chart.dart';

class ProjectBudgetChart extends StatelessWidget {
  const ProjectBudgetChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Budget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(months[value.toInt() % 6]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 4),
                        const FlSpot(2, 3.5),
                        const FlSpot(3, 5),
                        const FlSpot(4, 4),
                        const FlSpot(5, 6),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## List Items

### Customer List with Avatars and Status

```dart
class CustomerListItem extends StatelessWidget {
  final String name;
  final String userId;
  final String avatarUrl;
  final String status;
  final bool isPaid;

  const CustomerListItem({
    Key? key,
    required this.name,
    required this.userId,
    required this.avatarUrl,
    required this.status,
    required this.isPaid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'User ID: $userId',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPaid
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isPaid ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () {
        // Navigate to customer detail
      },
    );
  }
}

// Usage in a list
class RecentCustomersList extends StatelessWidget {
  const RecentCustomersList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Customers',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              CustomerListItem(
                name: 'Samantha Melon',
                userId: '#1234',
                avatarUrl: 'https://...',
                status: 'Paid',
                isPaid: true,
              ),
              Divider(height: 1),
              CustomerListItem(
                name: 'Allie Grater',
                userId: '#5678',
                avatarUrl: 'https://...',
                status: 'Pending',
                isPaid: false,
              ),
              // More customers...
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Theme Configuration

### Material 3 Theme Setup

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Color scheme
  static const Color primaryColor = Color(0xFF6C5DD3);
  static const Color secondaryColor = Color(0xFF8A94A6);
  static const Color successColor = Color(0xFF47C363);
  static const Color dangerColor = Color(0xFFFF5B5B);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF17A2B8);
  
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    ),
  );
  
  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
  );
}

// Apply in main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeVald Fortex',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
```

---

## Best Practices

1. **Responsive Design**: Use `LayoutBuilder` and `MediaQuery` for responsive layouts
2. **State Management**: Use Riverpod for reactive state across widgets
3. **Performance**: Use `const` constructors and `ListView.builder` for large lists
4. **Accessibility**: Provide semantic labels and ensure proper contrast ratios
5. **Code Reusability**: Extract common patterns into reusable widgets
6. **Theming**: Use `Theme.of(context)` instead of hardcoded colors

---

## Next Steps

1. Set up the Flutter project structure
2. Implement the theme configuration
3. Create a widget library with these patterns
4. Build feature-specific screens using these components
5. Test on multiple screen sizes and orientations
