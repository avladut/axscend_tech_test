import 'package:flutter/material.dart';

/// A search box with a clear button that shows once something is typed.
class AppSearchField extends StatefulWidget {
  const new({
    required this.hint,
    required this.clearTooltip,
    required this.onChanged,
    this.initialValue = '',
    super.key,
  });

  /// Such as "Search users".
  final String hint;

  /// Such as "Clear search".
  final String clearTooltip;

  /// Called on every change, and with `''` when cleared.
  final ValueChanged<String> onChanged;

  final String initialValue;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: widget.hint,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _controller.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: widget.clearTooltip,
                icon: const Icon(Icons.clear),
                onPressed: _clear,
              ),
      ),
    ),
  );
}
