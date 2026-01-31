import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:src/models/agency/introduction_section.dart';
import 'package:src/widgets/introduction/text_section_widget.dart';
import 'package:src/widgets/introduction/list_section_widget.dart';
import 'package:src/widgets/introduction/nested_section_widget.dart';
import 'package:src/widgets/introduction/table_section_widget.dart';

void main() {
  group('TextSectionWidget Tests', () {
    testWidgets('renders text content correctly', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section1',
        type: SectionType.text,
        title: 'Overview',
        description: 'Our company overview',
        content: {'text': 'We are a leading technology company.'},
        isRequired: true,
        order: 1,
      );

      bool editCalled = false;
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextSectionWidget(
              section: section,
              onEdit: () => editCalled = true,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Overview'), findsOneWidget);

      // Verify description is displayed
      expect(find.text('Our company overview'), findsOneWidget);

      // Verify content is displayed
      expect(find.text('We are a leading technology company.'), findsOneWidget);

      // Verify required badge is shown
      expect(find.text('REQUIRED'), findsOneWidget);

      // Test edit button
      await tester.tap(find.byIcon(Icons.edit));
      expect(editCalled, true);

      // Test delete button
      await tester.tap(find.byIcon(Icons.delete));
      expect(deleteCalled, true);
    });

    testWidgets('handles optional section without description', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section2',
        type: SectionType.text,
        title: 'Simple Section',
        content: {'text': 'Simple content'},
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify title is displayed
      expect(find.text('Simple Section'), findsOneWidget);

      // Verify REQUIRED badge is not shown
      expect(find.text('REQUIRED'), findsNothing);
    });
  });

  group('ListSectionWidget Tests', () {
    testWidgets('renders bullet list correctly', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section3',
        type: SectionType.list,
        title: 'Features',
        content: {
          'items': ['Feature 1', 'Feature 2', 'Feature 3'],
          'isNumbered': false,
        },
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Features'), findsOneWidget);

      // Verify all items are displayed
      expect(find.text('Feature 1'), findsOneWidget);
      expect(find.text('Feature 2'), findsOneWidget);
      expect(find.text('Feature 3'), findsOneWidget);

      // Verify bullet points (•) are shown
      expect(find.text('•'), findsNWidgets(3));
    });

    testWidgets('renders numbered list correctly', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section4',
        type: SectionType.list,
        title: 'Steps',
        content: {
          'items': ['First step', 'Second step', 'Third step'],
          'isNumbered': true,
        },
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify numbers are shown
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);

      // Verify items
      expect(find.text('First step'), findsOneWidget);
      expect(find.text('Second step'), findsOneWidget);
      expect(find.text('Third step'), findsOneWidget);
    });
  });

  group('NestedSectionWidget Tests', () {
    testWidgets('renders nested subsections with expand/collapse', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section5',
        type: SectionType.nested,
        title: 'Our Services',
        content: {
          'subsections': [
            {
              'title': 'Consulting',
              'description': 'Expert consulting services',
              'items': ['Strategy', 'Implementation'],
            },
            {
              'title': 'Development',
              'description': 'Custom software development',
              'items': ['Web Apps', 'Mobile Apps'],
            },
          ],
        },
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NestedSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify main title
      expect(find.text('Our Services'), findsOneWidget);

      // Initially, subsections should be collapsed
      expect(find.text('Expert consulting services'), findsNothing);

      // Tap to expand first subsection
      await tester.tap(find.text('Consulting'));
      await tester.pumpAndSettle();

      // Now description and items should be visible
      expect(find.text('Expert consulting services'), findsOneWidget);
      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Implementation'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Consulting'));
      await tester.pumpAndSettle();

      // Should be hidden again
      expect(find.text('Expert consulting services'), findsNothing);
    });
  });

  group('TableSectionWidget Tests', () {
    testWidgets('renders table with columns and rows', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section6',
        type: SectionType.table,
        title: 'Pricing',
        content: {
          'columns': ['Plan', 'Price', 'Features'],
          'rows': [
            ['Basic', '\$10/mo', '5 users'],
            ['Pro', '\$20/mo', '10 users'],
            ['Enterprise', '\$50/mo', 'Unlimited'],
          ],
        },
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify title
      expect(find.text('Pricing'), findsOneWidget);

      // Verify column headers
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify row data
      expect(find.text('Basic'), findsOneWidget);
      expect(find.text('\$10/mo'), findsOneWidget);
      expect(find.text('5 users'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('\$20/mo'), findsOneWidget);
      expect(find.text('Enterprise'), findsOneWidget);
    });

    testWidgets('handles empty table', (WidgetTester tester) async {
      final section = IntroductionSection(
        id: 'section7',
        type: SectionType.table,
        title: 'Empty Table',
        content: {
          'columns': ['Column 1', 'Column 2'],
          'rows': [],
        },
        isRequired: false,
        order: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TableSectionWidget(
              section: section,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should still render headers
      expect(find.text('Column 1'), findsOneWidget);
      expect(find.text('Column 2'), findsOneWidget);

      // Should show "No data" message
      expect(find.text('No data available'), findsOneWidget);
    });
  });
}
