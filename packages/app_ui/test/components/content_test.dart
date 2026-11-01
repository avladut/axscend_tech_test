import 'package:app_ui/app_ui.dart';
import 'package:app_ui/testing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  group(AppCard, () {
    testWidgets('shows its child and reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppCard(onTap: () => taps++, child: const Text('A')),
      );

      await tester.tap(find.text('A'));
      expect(taps, 1);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group(AppListTile, () {
    testWidgets('a tappable row gets a chevron and reports taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppListTile(title: 'Leanne', subtitle: 'Bret', onTap: () => taps++),
      );

      expect(find.text('Bret'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.tap(find.text('Leanne'));
      expect(taps, 1);
    });

    testWidgets('a row without a tap has no chevron', (tester) async {
      await tester.pumpApp(const AppListTile(title: 'Leanne'));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('its own trailing widget replaces the chevron', (tester) async {
      await tester.pumpApp(
        AppListTile(
          title: 'Leanne',
          trailing: const Text('10'),
          selected: true,
          onTap: () {},
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(tester.widget<ListTile>(find.byType(ListTile)).selected, isTrue);
    });
  });

  group(AppListTilePlaceholder, () {
    testWidgets('is as tall as the row it stands in for, at any text size', (
      tester,
    ) async {
      for (final scale in [1.0, 2.0]) {
        await tester.pumpApp(
          MediaQuery.withClampedTextScaling(
            minScaleFactor: scale,
            maxScaleFactor: scale,
            child: const Column(
              children: [
                AppListTile(
                  title: 'Leanne Graham',
                  subtitle: '@Bret',
                  leading: AppAvatar(name: 'Leanne Graham'),
                ),
                AppListTilePlaceholder(),
              ],
            ),
          ),
        );

        expect(
          tester.getSize(find.byType(AppListTilePlaceholder)).height,
          tester.getSize(find.byType(AppListTile)).height,
          reason: 'text scale $scale',
        );
      }
    });

    testWidgets('is announced only with a label', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const Column(
          children: [
            AppListTilePlaceholder(semanticLabel: 'Loading user'),
            AppListTilePlaceholder(),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Loading user'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(AppListTilePlaceholder).last).label,
        isEmpty,
      );
      semantics.dispose();
    });
  });

  group(AppAvatar, () {
    test('initialsOf takes the first and last words, skipping titles', () {
      expect(AppAvatar.initialsOf('Leanne Graham'), 'LG');
      expect(AppAvatar.initialsOf('Mrs. Dennis Schulist'), 'DS');
      expect(AppAvatar.initialsOf('Clementina DuBuque Jr'), 'CJ');
      expect(AppAvatar.initialsOf('bret'), 'B');
      expect(AppAvatar.initialsOf('  '), '?');
    });

    testWidgets('shows the initials, hidden from screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const AppAvatar(name: 'Leanne Graham', size: AppAvatarSize.lg),
      );

      expect(find.text('LG'), findsOneWidget);
      expect(find.bySemanticsLabel('LG'), findsNothing);
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, AppSizes.avatarLg / 2);
      semantics.dispose();
    });

    testWidgets('with a semantic label, is announced as an image', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const AppAvatar(name: 'Leanne Graham', semanticLabel: 'Leanne Graham'),
      );

      expect(
        tester.getSemantics(find.byType(AppAvatar)),
        matchesSemantics(label: 'Leanne Graham', isImage: true),
      );
      expect(find.bySemanticsLabel('LG'), findsNothing);
      semantics.dispose();
    });

    testWidgets('gives the same name the same colour', (tester) async {
      Color? colourOf(String name) => tester
          .widget<CircleAvatar>(find.byType(CircleAvatar))
          .backgroundColor;

      await tester.pumpApp(const AppAvatar(name: 'Ervin Howell'));
      final first = colourOf('Ervin Howell');
      await tester.pumpApp(const AppAvatar(name: 'Ervin Howell'));

      expect(colourOf('Ervin Howell'), first);
    });
  });

  group(AppTag, () {
    testWidgets('shows its label in every tone', (tester) async {
      for (final tone in AppTone.values) {
        await tester.pumpApp(AppTag(label: tone.name, tone: tone));
        expect(find.text(tone.name), findsOneWidget);
      }
    });
  });

  group(AppSectionHeader, () {
    testWidgets('shows the title as a header, the count and the action', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const AppSectionHeader(
          title: 'Posts',
          count: 10,
          trailing: Icon(Icons.sort),
        ),
      );

      expect(find.text('10'), findsOneWidget);
      expect(find.byIcon(Icons.sort), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Posts')),
        matchesSemantics(label: 'Posts', isHeader: true),
      );
      semantics.dispose();
    });

    testWidgets('puts the action at the far end of the row', (tester) async {
      await tester.pumpApp(
        const AppSectionHeader(
          title: 'Posts',
          count: 10,
          trailing: Icon(Icons.sort),
        ),
        size: TestWindows.phone,
      );

      final header = tester.getTopRight(find.byType(AppSectionHeader));
      final action = tester.getTopRight(find.byIcon(Icons.sort));
      expect(action.dx, header.dx - AppInsets.section.right);
    });

    testWidgets('works without a count or an action', (tester) async {
      await tester.pumpApp(const AppSectionHeader(title: 'Albums'));

      expect(find.byType(AppTag), findsNothing);
    });
  });

  group(AppInfoRow, () {
    testWidgets('shows the label and value, and reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: 'Sincere@april.biz',
          onTap: () => taps++,
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      await tester.tap(find.text('Sincere@april.biz'));
      expect(taps, 1);
    });
  });

  group(AppCheckRow, () {
    testWidgets('a done task is ticked, struck through and checked', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(const AppCheckRow(title: 'Write tests', done: true));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      final text = tester.widget<Text>(find.text('Write tests'));
      expect(text.style?.decoration, TextDecoration.lineThrough);
      expect(
        tester.getSemantics(find.byType(AppCheckRow)),
        matchesSemantics(
          label: 'Write tests',
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a pending task is an empty circle', (tester) async {
      await tester.pumpApp(const AppCheckRow(title: 'Ship', done: false));

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      final text = tester.widget<Text>(find.text('Ship'));
      expect(text.style?.decoration, isNot(TextDecoration.lineThrough));
    });
  });

  group(AppNetworkImage, () {
    final url = Uri.parse('https://picsum.photos/seed/1/150');

    // Decoded pictures stay in memory between tests; start each one empty.
    tearDown(
      () => PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages(),
    );

    Future<FakeImageCache> pumpImage(
      WidgetTester tester, {
      bool fail = false,
      VoidCallback? onTap,
    }) async {
      final cache = FakeImageCache(fail: fail);
      await tester.pumpApp(
        AppImageCacheScope(
          cache: cache,
          child: SizedBox.square(
            dimension: 150,
            child: AppNetworkImage(
              url: url,
              semanticLabel: 'A photo',
              onTap: onTap,
            ),
          ),
        ),
      );
      return cache;
    }

    testWidgets('loads the picture through the device cache', (tester) async {
      final cache = await pumpImage(tester);

      expect(cache.requested, [url.toString()]);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('decodes the picture at the size it is shown', (tester) async {
      await pumpImage(tester);

      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      final pixelRatio = tester.view.devicePixelRatio;
      expect(image.memCacheWidth, (150 * pixelRatio).round());
    });

    testWidgets('fills its box, tappable or not', (tester) async {
      for (final onTap in [null, () {}]) {
        await pumpImage(tester, onTap: onTap);

        final image = tester.renderObject<RenderBox>(
          find.byType(CachedNetworkImage),
        );
        expect(
          image.constraints,
          BoxConstraints.tight(const Size.square(150)),
          reason: onTap == null ? 'not tappable' : 'tappable',
        );
      }
    });

    testWidgets('shows a broken-image icon when it fails', (tester) async {
      await pumpImage(tester, fail: true);
      // The cache answers on real async, outside the test's fake clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('is an image for screen readers, and a button when tappable', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await pumpImage(tester, onTap: () => taps++);

      expect(
        tester.getSemantics(find.byType(AppNetworkImage)),
        matchesSemantics(
          label: 'A photo',
          isImage: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.byType(AppNetworkImage));
      expect(taps, 1);
      semantics.dispose();
    });
  });

  group(AppImageCache, () {
    test('keeps at most 500 pictures on disk, for 30 days', () {
      expect(AppImageCache.maxImagesOnDisk, 500);
      expect(AppImageCache.maxAge, const Duration(days: 30));
    });

    test('caps the decoded pictures kept in memory', () {
      final cache = ImageCache();
      AppImageCache.limitMemory(cache);

      expect(cache.maximumSize, 200);
      expect(cache.maximumSizeBytes, 50 * 1024 * 1024);
    });

    testWidgets('the disk cache is used unless a scope says otherwise', (
      tester,
    ) async {
      late BaseCacheManager found;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            found = AppImageCacheScope.of(context);
            return const SizedBox();
          },
        ),
      );

      expect(found, same(AppImageCache.disk));
    });
  });

  group(AppProgressRing, () {
    testWidgets('shows the percentage and tells screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpApp(
        const AppProgressRing(value: 0.45, semanticLabel: 'Todos done'),
      );

      expect(find.text('45%'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(AppProgressRing)),
        matchesSemantics(label: 'Todos done', value: '45%'),
      );
      semantics.dispose();
    });

    testWidgets('clamps values outside 0 to 1', (tester) async {
      await tester.pumpApp(
        const AppProgressRing(value: 1.7, semanticLabel: 'Todos done'),
      );

      expect(find.text('100%'), findsOneWidget);
    });
  });
}
