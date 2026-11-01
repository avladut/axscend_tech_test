import 'package:app_ui/src/theme/theme_context.dart';
import 'package:flutter/material.dart';

/// One top-level destination of the app.
@immutable
class AppDestination {
  const new({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The app's top-level navigation around [body]: a bottom bar on phones, a
/// rail on the side on tablets.
class AppAdaptiveNavigation extends StatelessWidget {
  const new({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    super.key,
  }) : assert(destinations.length >= 2, 'Navigation needs 2+ destinations.');

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (context.windowSize.isCompact) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(child: body),
        ],
      ),
    );
  }
}
