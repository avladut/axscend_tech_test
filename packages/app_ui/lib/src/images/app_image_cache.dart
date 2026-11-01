import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Where pictures are kept, so each one is downloaded once.
///
/// - **On the device's disk:** the last [maxImagesOnDisk] pictures, each for
///   up to [maxAge]. A picture shown again comes from disk, even offline.
/// - **In memory:** at most [maxImagesInMemory] decoded pictures and
///   [maxBytesInMemory] bytes, once [limitMemory] has run.
///
/// On the web, the browser's own cache keeps the pictures.
abstract final class AppImageCache {
  static const maxImagesOnDisk = 500;
  static const maxAge = Duration(days: 30);
  static const maxImagesInMemory = 200;
  static const int maxBytesInMemory = 50 * 1024 * 1024;

  /// The disk cache every `AppNetworkImage` uses, unless an
  /// [AppImageCacheScope] says otherwise.
  static final BaseCacheManager disk = CacheManager(
    Config(
      'app_ui_images',
      stalePeriod: maxAge,
      maxNrOfCacheObjects: maxImagesOnDisk,
    ),
  );

  /// Caps Flutter's in-memory cache of decoded pictures (by default 1,000
  /// pictures and 100 MB). Call once, before `runApp`.
  static void limitMemory([ImageCache? cache]) {
    (cache ?? PaintingBinding.instance.imageCache)
      ..maximumSize = maxImagesInMemory
      ..maximumSizeBytes = maxBytesInMemory;
  }
}

/// Gives the pictures below it another cache, such as a fake one in tests.
class AppImageCacheScope extends InheritedWidget {
  const new({required this.cache, required super.child, super.key});

  final BaseCacheManager cache;

  /// The nearest scope's cache, or [AppImageCache.disk].
  static BaseCacheManager of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppImageCacheScope>()?.cache ??
      AppImageCache.disk;

  @override
  bool updateShouldNotify(AppImageCacheScope oldWidget) =>
      cache != oldWidget.cache;
}
