import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A picture cache for tests, which have no network or disk. Put it in an
/// `AppImageCacheScope`. It records what it's asked for. Pictures never
/// arrive, or with [fail] they fail like a download with nothing cached.
class FakeImageCache implements BaseCacheManager {
  new({this.fail = false});

  final bool fail;

  /// Every picture asked for, in order.
  final requested = <String>[];

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    requested.add(url);
    return fail
        ? Stream.error(Exception('no picture in tests: $url'))
        : StreamController<FileResponse>().stream;
  }

  // Nothing else is used by AppNetworkImage.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
