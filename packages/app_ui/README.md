# app_ui

The app's design system: an `AppBrand`, design tokens, a complete Material 3
theme (light and dark) and the reusable `App*` widgets. It knows nothing about
users, posts or any backend, and has no text of its own.

```dart
import 'package:app_ui/app_ui.dart';

const brand = AppBrand(name: 'Directory', seed: Color(0xFF00695C));

MaterialApp(
  theme: AppTheme.light(brand),
  darkTheme: AppTheme.dark(brand),
  // ...
);

// In a widget:
Padding(
  padding: AppInsets.card,
  child: Text(user.name, style: context.textStyles.titleMedium),
);
```

- **The design language** (brand, principles, every token and component, do's
  and don'ts): [DESIGN.md](DESIGN.md).
- **Tests:** `flutter test` in this folder. Each component has widget tests,
  and the theme has its own.
