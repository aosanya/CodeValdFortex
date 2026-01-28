import 'dart:async';
import 'package:flutter/material.dart';

/// Search bar widget for agencies with debouncing
class AgencySearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final String? initialValue;

  const AgencySearchBar({super.key, this.onSearch, this.initialValue});

  @override
  State<AgencySearchBar> createState() => _AgencySearchBarState();
}

class _AgencySearchBarState extends State<AgencySearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search agencies...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch?.call('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
