import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../models/agency/introduction_section.dart';
import '../../../providers/introduction_provider.dart';

/// Dialog for manually adding a new section to the introduction.
/// Allows users to create sections with different types and configure their content.
class AddSectionDialog extends ConsumerStatefulWidget {
  final String agencyId;

  const AddSectionDialog({
    super.key,
    required this.agencyId,
  });

  @override
  ConsumerState<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends ConsumerState<AddSectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  
  SectionType _selectedType = SectionType.text;
  bool _isRequired = false;
  bool _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAdding = true);

    try {
      final Map<String, dynamic> content = _buildContent();

      final section = IntroductionSection(
        id: '', // Server will generate
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        content: content,
        isRequired: _isRequired,
        order: 0, // Server will assign based on current max order
      );

      await ref.read(introductionProvider(widget.agencyId).notifier).addSection(section);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Section added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding section: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _buildContent() {
    switch (_selectedType) {
      case SectionType.text:
        return {
          'text': _contentController.text.trim(),
        };
      
      case SectionType.list:
        final items = _contentController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return {
          'items': items,
          'isNumbered': false,
        };
      
      case SectionType.nested:
        // For nested sections, start with empty subsections
        // Users can add them after creation
        return {
          'subsections': <Map<String, dynamic>>[],
        };
      
      case SectionType.table:
        // For tables, create a simple 2-column structure
        return {
          'columns': ['Column 1', 'Column 2'],
          'rows': <List<String>>[],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Section',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isAdding ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Type
                      const Text(
                        'Section Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<SectionType>(
                        segments: [
                          ButtonSegment(
                            value: SectionType.text,
                            label: const Text('Text'),
                            icon: const Icon(Icons.text_fields, size: 18),
                          ),
                          ButtonSegment(
                            value: SectionType.list,
                            label: const Text('List'),
                            icon: const Icon(Icons.list, size: 18),
                          ),
                          ButtonSegment(
                            value: SectionType.nested,
                            label: const Text('Nested'),
                            icon: const Icon(Icons.account_tree, size: 18),
                          ),
                          ButtonSegment(
                            value: SectionType.table,
                            label: const Text('Table'),
                            icon: const Icon(Icons.table_chart, size: 18),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<SectionType> newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                            _contentController.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Section Title',
                          hintText: 'e.g., Our Mission',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                        enabled: !_isAdding,
                      ),
                      const SizedBox(height: 16),

                      // Description (optional)
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'Brief explanation of this section',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        enabled: !_isAdding,
                      ),
                      const SizedBox(height: 16),

                      // Content input (varies by type)
                      _buildContentInput(),
                      const SizedBox(height: 16),

                      // Required toggle
                      SwitchListTile(
                        title: const Text('Required Section'),
                        subtitle: const Text('Mark this section as required'),
                        value: _isRequired,
                        onChanged: _isAdding ? null : (value) {
                          setState(() => _isRequired = value);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isAdding ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isAdding ? null : _handleAdd,
                    icon: _isAdding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isAdding ? 'Adding...' : 'Add Section'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentInput() {
    switch (_selectedType) {
      case SectionType.text:
        return TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Content',
            hintText: 'Enter section text content',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Content is required';
            }
            return null;
          },
          enabled: !_isAdding,
        );

      case SectionType.list:
        return TextFormField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'List Items',
            hintText: 'Enter one item per line',
            border: OutlineInputBorder(),
            helperText: 'Each line will become a list item',
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'At least one item is required';
            }
            return null;
          },
          enabled: !_isAdding,
        );

      case SectionType.nested:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Nested Section',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'The nested section will be created empty. You can add subsections after creation.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        );

      case SectionType.table:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Table Section',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'A table with 2 columns will be created. You can edit the structure and add rows after creation.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        );
    }
  }
}
