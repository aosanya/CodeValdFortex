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
            'Define your agency\'s background, purpose, and scope',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Background field
          _RichTextFieldWithCounter(
            label: 'Background',
            hint: 'Describe the context and history that led to this agency\'s creation...',
            value: state.background,
            onChanged: viewModel.updateBackground,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.backgroundLimit,
            minLength: IntroductionState.backgroundMin,
            errorText: state.validationErrors['background'],
            minLines: 5,
            maxLines: 10,
          ),
          const SizedBox(height: 24),

          // Purpose field
          _RichTextFieldWithCounter(
            label: 'Purpose',
            hint: 'Explain why this agency exists and what impact it should have...',
            value: state.purpose,
            onChanged: viewModel.updatePurpose,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.purposeLimit,
            minLength: IntroductionState.purposeMin,
            errorText: state.validationErrors['purpose'],
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 24),

          // Scope field
          _RichTextFieldWithCounter(
            label: 'Scope',
            hint: 'Define the boundaries, focus areas, and what is included or excluded...',
            value: state.scope,
            onChanged: viewModel.updateScope,
            onFocusLost: viewModel.onFocusLost,
            maxLength: IntroductionState.scopeLimit,
            minLength: IntroductionState.scopeMin,
            errorText: state.validationErrors['scope'],
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 32),

          // AI Assist button (placeholder for future)
          OutlinedButton.icon(
            onPressed: null, // Disabled for now
            icon: const Icon(Icons.auto_awesome),
            label: const Text('AI Assist'),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveIndicator(BuildContext context, IntroductionState state) {
    switch (state.saveStatus) {
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
