import 'package:flutter/foundation.dart';

/// Section type enum matching backend SectionType
enum SectionType {
  text,
  list,
  nested,
  table;

  String toJson() => name;

  static SectionType fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'text':
        return SectionType.text;
      case 'list':
        return SectionType.list;
      case 'nested':
        return SectionType.nested;
      case 'table':
        return SectionType.table;
      default:
        throw ArgumentError('Unknown section type: $json');
    }
  }
}

/// Content for a list-type section
@immutable
class ListContent {
  final List<String> items;

  const ListContent({required this.items});

  factory ListContent.fromJson(Map<String, dynamic> json) {
    return ListContent(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListContent &&
          runtimeType == other.runtimeType &&
          listEquals(items, other.items);

  @override
  int get hashCode => items.hashCode;
}

/// Content for a nested-type section
@immutable
class NestedSection {
  final String title;
  final String content;

  const NestedSection({
    required this.title,
    required this.content,
  });

  factory NestedSection.fromJson(Map<String, dynamic> json) {
    return NestedSection(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NestedSection &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => title.hashCode ^ content.hashCode;
}

/// Content for a nested-type section
@immutable
class NestedContent {
  final List<NestedSection> sections;

  const NestedContent({required this.sections});

  factory NestedContent.fromJson(Map<String, dynamic> json) {
    return NestedContent(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => NestedSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NestedContent &&
          runtimeType == other.runtimeType &&
          listEquals(sections, other.sections);

  @override
  int get hashCode => sections.hashCode;
}

/// Content for a table-type section
@immutable
class TableContent {
  final List<String> headers;
  final List<List<String>> rows;

  const TableContent({
    required this.headers,
    required this.rows,
  });

  factory TableContent.fromJson(Map<String, dynamic> json) {
    return TableContent(
      headers: (json['headers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((row) => (row as List<dynamic>)
                  .map((cell) => cell.toString())
                  .toList())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headers': headers,
      'rows': rows,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableContent &&
          runtimeType == other.runtimeType &&
          listEquals(headers, other.headers) &&
          listEquals(rows, other.rows);

  @override
  int get hashCode => headers.hashCode ^ rows.hashCode;
}

/// Represents a single section in an agency introduction
@immutable
class IntroductionSection {
  final String id;
  final SectionType type;
  final String title;
  final Map<String, dynamic> content;
  final int order;
  final bool required;

  const IntroductionSection({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.order,
    this.required = false,
  });

  factory IntroductionSection.fromJson(Map<String, dynamic> json) {
    return IntroductionSection(
      id: json['id'] as String? ?? '',
      type: SectionType.fromJson(json['type'] as String? ?? 'text'),
      title: json['title'] as String? ?? '',
      content: json['content'] as Map<String, dynamic>? ?? {},
      order: json['order'] as int? ?? 0,
      required: json['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'title': title,
      'content': content,
      'order': order,
      'required': required,
    };
  }

  /// Get typed content based on section type
  String? get textContent {
    if (type != SectionType.text) return null;
    return content['text'] as String?;
  }

  ListContent? get listContent {
    if (type != SectionType.list) return null;
    return ListContent.fromJson(content);
  }

  NestedContent? get nestedContent {
    if (type != SectionType.nested) return null;
    return NestedContent.fromJson(content);
  }

  TableContent? get tableContent {
    if (type != SectionType.table) return null;
    return TableContent.fromJson(content);
  }

  IntroductionSection copyWith({
    String? id,
    SectionType? type,
    String? title,
    Map<String, dynamic>? content,
    int? order,
    bool? required,
  }) {
    return IntroductionSection(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      order: order ?? this.order,
      required: required ?? this.required,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntroductionSection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          mapEquals(content, other.content) &&
          order == other.order &&
          required == other.required;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      title.hashCode ^
      content.hashCode ^
      order.hashCode ^
      required.hashCode;
}
