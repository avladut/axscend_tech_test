/// The window size classes of Material 3.
enum AppWindowSize {
  /// Phones in portrait: one pane, a bottom navigation bar.
  compact,

  /// Small tablets and phones in landscape: one pane, a navigation rail.
  medium,

  /// Tablets and desktops: two panes, a navigation rail.
  expanded;

  /// The size class for a window [width] wide.
  static AppWindowSize forWidth(double width) {
    if (width >= AppBreakpoints.expanded) return expanded;
    if (width >= AppBreakpoints.medium) return medium;
    return compact;
  }

  bool get isCompact => this == compact;

  bool get isExpanded => this == expanded;
}

/// Where one size class ends and the next begins, in logical pixels.
abstract final class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 840;
}
