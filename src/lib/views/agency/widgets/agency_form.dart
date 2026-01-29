import 'package:flutter/material.dart';
import '../../../models/agency/agency_form_state.dart';

/// Reusable form widget for creating/editing agencies
class AgencyForm extends StatelessWidget {
  final AgencyFormState formState;
  final Function(String field, dynamic value) onChanged;
  final bool readOnly;

  const AgencyForm({
    super.key,
    required this.formState,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Required fields section header
        Row(
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name field
        TextFormField(
          initialValue: formState.name,
          decoration: InputDecoration(
            labelText: 'Agency Name *',
            hintText: 'Enter a unique agency name',
            helperText: 'Unique identifier for this agency (3-100 characters)',
            border: const OutlineInputBorder(),
            errorText: formState.errors['name'],
            prefixIcon: const Icon(Icons.business),
          ),
          enabled: !readOnly,
          maxLength: 100,
          textInputAction: TextInputAction.next,
          onChanged: (value) => onChanged('name', value),
        ),
        const SizedBox(height: 16),

        // Description field
        TextFormField(
          initialValue: formState.description,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Describe the purpose and scope of this agency',
            helperText: 'Optional detailed description (max 500 characters)',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
            errorText: formState.errors['description'],
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description),
            ),
          ),
          enabled: !readOnly,
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          onChanged: (value) => onChanged('description', value),
        ),
      ],
    );
  }
}
