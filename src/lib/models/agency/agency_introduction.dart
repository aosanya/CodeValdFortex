import 'package:flutter/foundation.dart';
import 'introduction_section.dart';

/// Represents a complete agency introduction with flexible sections
@immutable
class AgencyIntroduction {
  final String agencyId;
  final String template;
  final List<IntroductionSection> sections;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgencyIntroduction({
    required this.agencyId,
    required this.template,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgencyIntroduction.fromJson(Map<String, dynamic> json) {
    return AgencyIntroduction(
      agencyId: json['agency_id'] as String? ?? '',
      template: json['template'] as String? ?? 'custom',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) =>
                  IntroductionSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agency_id': agencyId,
      'template': template,
      'sections': sections.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create an empty introduction
  factory AgencyIntroduction.empty(String agencyId) {
    return AgencyIntroduction(
      agencyId: agencyId,
      template: 'custom',
      sections: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get section by ID
  IntroductionSection? getSectionById(String sectionId) {
    try {
      return sections.firstWhere((s) => s.id == sectionId);
    } catch (e) {
      return null;
    }
  }

  /// Get sections ordered by order field
  List<IntroductionSection> get orderedSections {
    final List<IntroductionSection> sorted = List.from(sections);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Get required sections only
  List<IntroductionSection> get requiredSections {
    return sections.where((s) => s.required).toList();
  }

  /// Check if all required sections have content
  bool get isComplete {
    for (final section in requiredSections) {
      switch (section.type) {
        case SectionType.text:
          final text = section.textContent;
          if (text == null || text.trim().isEmpty) return false;
          break;
        case SectionType.list:
          final list = section.listContent;
          if (list == null || list.items.isEmpty) return false;
          break;
        case SectionType.nested:
          final nested = section.nestedContent;
          if (nested == null || nested.sections.isEmpty) return false;
          break;
        case SectionType.table:
          final table = section.tableContent;
          if (table == null ||
              table.headers.isEmpty ||
              table.rows.isEmpty) {
            return false;
          }
          break;
      }
    }
    return true;
  }

  /// Get count of sections
  int get sectionCount => sections.length;

  AgencyIntroduction copyWith({
    String? agencyId,
    String? template,
    List<IntroductionSection>? sections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgencyIntroduction(
      agencyId: agencyId ?? this.agencyId,
      template: template ?? this.template,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgencyIntroduction &&
          runtimeType == other.runtimeType &&
          agencyId == other.agencyId &&
          template == other.template &&
          listEquals(sections, other.sections) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      agencyId.hashCode ^
      template.hashCode ^
      sections.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
