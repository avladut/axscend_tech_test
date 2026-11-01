import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
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
    testWidgets('loads the link with a label for screen readers', (
      tester,
    ) async {
      await tester.pumpApp(
        AppNetworkImage(
          url: Uri.parse('https://picsum.photos/seed/1/150'),
          semanticLabel: 'A photo',
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.semanticLabel, 'A photo');
      expect(
        (image.image as NetworkImage).url,
        'https://picsum.photos/seed/1/150',
      );
    });

    testWidgets('shows a broken-image icon when it fails', (tester) async {
      // Tests have no network, so every image request fails.
      await tester.pumpApp(
        AppNetworkImage(
          url: Uri.parse('https://picsum.photos/seed/1/150'),
          semanticLabel: 'A photo',
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
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
