import 'package:flutter/material.dart';

/// Enum representing the status of an agency
enum AgencyStatus {
  draft,
  validated,
  published,
  active;

  /// Get display name for the status
  String get displayName {
    switch (this) {
      case AgencyStatus.draft:
        return 'Draft';
      case AgencyStatus.validated:
        return 'Validated';
      case AgencyStatus.published:
        return 'Published';
      case AgencyStatus.active:
        return 'Active';
    }
  }

  /// Get badge color for the status
  Color get badgeColor {
    switch (this) {
      case AgencyStatus.draft:
        return Colors.grey;
      case AgencyStatus.validated:
        return Colors.blue;
      case AgencyStatus.published:
        return Colors.orange;
      case AgencyStatus.active:
        return Colors.green;
    }
  }

  /// Parse from string value
  static AgencyStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return AgencyStatus.draft;
      case 'validated':
        return AgencyStatus.validated;
      case 'published':
        return AgencyStatus.published;
      case 'active':
        return AgencyStatus.active;
      default:
        throw ArgumentError('Invalid agency status: $value');
    }
  }
}
