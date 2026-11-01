/// Fixed sizes: icons, avatars and layout widths.
abstract final class AppSizes {
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 48;

  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 72;

  static const double progressRing = 48;

  /// Readable line length for text-heavy pages.
  static const double maxContentWidth = 720;

  /// The list pane in a two-pane layout.
  static const double listPaneWidth = 360;

  /// The smallest a photo grid cell may get before the grid drops a column.
  static const double gridTileMinWidth = 140;
}
