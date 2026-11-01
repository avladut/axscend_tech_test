import 'package:flutter/material.dart';

/// A labelled value, such as an email address with an envelope icon.
/// Tappable when [onTap] is set, for example to write an email.
class AppInfoRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(value),
    subtitle: Text(label),
    onTap: onTap,
  );
}
