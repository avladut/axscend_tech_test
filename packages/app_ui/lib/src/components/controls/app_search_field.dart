import 'package:flutter/material.dart';

/// A search box with a clear button that shows once something is typed.
class AppSearchField extends StatefulWidget {
  const new({
    required this.hint,
    required this.clearTooltip,
    required this.onChanged,
    this.value = '',
    super.key,
  });

  /// Such as "Search users".
  final String hint;

  /// Such as "Clear search".
  final String clearTooltip;

  /// Called on every change, and with `''` when cleared.
  final ValueChanged<String> onChanged;

  /// The text to show. The field follows it when the parent changes it, for
  /// example when a search is reset elsewhere.
  final String value;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when it differs from what's typed, so typing never moves the
    // cursor.
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

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
