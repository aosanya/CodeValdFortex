import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/agency/introduction_viewmodel.dart';
import '../../../models/agency/introduction_state.dart';

/// Introduction section for the Agency Designer
class IntroductionSection extends ConsumerWidget {
  final String agencyId;

  const IntroductionSection({super.key, required this.agencyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(introductionViewModelProvider(agencyId).notifier);
    final state = ref.watch(introductionViewModelProvider(agencyId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with save indicator
          Row(
            children: [
              Text(
                'Introduction',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              _buildSaveIndicator(context, state),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Define flexible introduction data points for your agency. Each field can hold up to 1000 characters.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Dynamic fields
          ...state.fields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildDynamicField(
                context,
                viewModel,
                state,
                field,
                index,
              ),
            );
          }),

          // Add field button
          OutlinedButton.icon(
            onPressed: viewModel.addField,
            icon: const Icon(Icons.add),
            label: const Text('Add Field'),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicField(
    BuildContext context,
    IntroductionViewModel viewModel,
    IntroductionState state,
    IntroductionField field,
    int index,
  ) {
    final labelError = state.validationErrors['field_${field.id}_label'];
    final contentError = state.validationErrors['field_${field.id}_content'];
    final charCount = field.content.length;
    final charLimit = IntroductionState.fieldLimit;
    final isOverLimit = charCount > charLimit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field header with label input and remove button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: field.label)
                      ..selection = TextSelection.collapsed(offset: field.label.length),
                    decoration: InputDecoration(
                      labelText: 'Field Label',
                      hintText: 'e.g., Overview, Context, Background',
                      errorText: labelError,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => viewModel.updateFieldLabel(field.id, value),
                  ),
                ),
                const SizedBox(width: 8),
                // Remove button (only show if more than 1 field)
                if (state.fields.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => viewModel.removeField(field.id),
                    tooltip: 'Remove field',
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Content textarea
            TextField(
              controller: TextEditingController(text: field.content)
                ..selection = TextSelection.collapsed(offset: field.content.length),
              decoration: InputDecoration(
                labelText: 'Content',
                hintText: 'Enter content for this field...',
                errorText: contentError,
                border: const OutlineInputBorder(),
                helperText: '$charCount / $charLimit characters',
                helperStyle: TextStyle(
                  color: isOverLimit 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              maxLines: 6,
              minLines: 4,
              maxLength: charLimit,
              onChanged: (value) => viewModel.updateFieldContent(field.id, value),
              onTapOutside: (_) => viewModel.onFocusLost(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveIndicator(BuildContext context, IntroductionState state) {
    switch (state.saveStatus) {
      case SaveStatus.saving:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Saving...', style: TextStyle(fontSize: 14)),
          ],
        );

      case SaveStatus.saved:
        final lastSaved = state.lastSavedAt;
        final timeAgo = lastSaved != null
            ? _getTimeAgo(DateTime.now().difference(lastSaved))
            : '';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 16),
            const SizedBox(width: 8),
            Text('Saved $timeAgo', style: const TextStyle(fontSize: 14)),
          ],
        );

      case SaveStatus.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 16),
            const SizedBox(width: 8),
            const Text('Save failed', style: TextStyle(fontSize: 14)),
          ],
        );

      case SaveStatus.idle:
      default:
        return const SizedBox.shrink();
    }
  }

  String _getTimeAgo(Duration duration) {
    if (duration.inSeconds < 10) return 'just now';
    if (duration.inSeconds < 60) return '${duration.inSeconds}s ago';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }
}

      case SaveStatus.saving:
        return Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Saving...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case SaveStatus.saved:
        final formattedTime = state.lastSavedAt != null
            ? '${state.lastSavedAt!.hour.toString().padLeft(2, '0')}:${state.lastSavedAt!.minute.toString().padLeft(2, '0')}'
            : '';
        return Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Saved at $formattedTime',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      case SaveStatus.error:
        return Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Error saving',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        );
      case SaveStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

/// Rich text field with character counter
class _RichTextFieldWithCounter extends StatefulWidget {
  final String label;
  final String hint;
  final String value;
  final Function(String) onChanged;
  final VoidCallback onFocusLost;
  final int maxLength;
  final int minLength;
  final String? errorText;
  final int minLines;
  final int maxLines;

  const _RichTextFieldWithCounter({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.onFocusLost,
    required this.maxLength,
    required this.minLength,
    this.errorText,
    this.minLines = 3,
    this.maxLines = 10,
  });

  @override
  State<_RichTextFieldWithCounter> createState() =>
      _RichTextFieldWithCounterState();
}

class _RichTextFieldWithCounterState extends State<_RichTextFieldWithCounter> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.onFocusLost();
      }
    });
  }

  @override
  void didUpdateWidget(_RichTextFieldWithCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getCounterColor(BuildContext context) {
    final percentage = widget.value.length / widget.maxLength;
    if (percentage >= 1.0) {
      return Theme.of(context).colorScheme.error;
    } else if (percentage >= 0.95) {
      return Colors.red;
    } else if (percentage >= 0.80) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
            helperText: 'Minimum ${widget.minLength} characters',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${widget.value.length} / ${widget.maxLength} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getCounterColor(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
