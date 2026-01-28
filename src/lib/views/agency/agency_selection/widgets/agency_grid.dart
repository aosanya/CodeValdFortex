import 'package:flutter/material.dart';
import '../../../../models/agency/agency_model.dart';
import 'agency_card.dart';

/// Grid layout for displaying agencies
class AgencyGrid extends StatelessWidget {
  final List<Agency> agencies;
  final Function(Agency)? onAgencyTap;

  const AgencyGrid({super.key, required this.agencies, this.onAgencyTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: agencies.length,
          itemBuilder: (context, index) {
            final agency = agencies[index];
            return AgencyCard(
              agency: agency,
              onTap: onAgencyTap != null ? () => onAgencyTap!(agency) : null,
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    // Responsive breakpoints from design specs
    if (width > 1200) {
      return 4; // Wide desktop
    } else if (width > 900) {
      return 3; // Desktop
    } else if (width > 600) {
      return 2; // Tablet
    } else {
      return 1; // Mobile
    }
  }
}
