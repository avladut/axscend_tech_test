import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Button that repeats a request that failed.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @failureOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get failureOfflineTitle;

  /// No description provided for @failureOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get failureOfflineMessage;

  /// No description provided for @failureNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failureNotFoundTitle;

  /// No description provided for @failureNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed.'**
  String get failureNotFoundMessage;

  /// No description provided for @failureServerTitle.
  ///
  /// In en, this message translates to:
  /// **'The server had a problem'**
  String get failureServerTitle;

  /// Shown when the server answers with an error.
  ///
  /// In en, this message translates to:
  /// **'It answered with error {statusCode}. Try again in a moment.'**
  String failureServerMessage(int statusCode);

  /// No description provided for @failureUnexpectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Something didn\'t look right'**
  String get failureUnexpectedTitle;

  /// No description provided for @failureUnexpectedMessage.
  ///
  /// In en, this message translates to:
  /// **'The server\'s answer couldn\'t be read. Try again later.'**
  String get failureUnexpectedMessage;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get notFoundMessage;

  /// No description provided for @notFoundAction.
  ///
  /// In en, this message translates to:
  /// **'Go to users'**
  String get notFoundAction;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @usersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get usersSearchHint;

  /// No description provided for @usersSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get usersSearchClear;

  /// No description provided for @usersSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort users'**
  String get usersSortTooltip;

  /// No description provided for @usersSortNameAscending.
  ///
  /// In en, this message translates to:
  /// **'Name, A to Z'**
  String get usersSortNameAscending;

  /// No description provided for @usersSortNameDescending.
  ///
  /// In en, this message translates to:
  /// **'Name, Z to A'**
  String get usersSortNameDescending;

  /// No description provided for @usersSortCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get usersSortCompany;

  /// No description provided for @usersSortCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get usersSortCity;

  /// No description provided for @usersAllHeader.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get usersAllHeader;

  /// Header above the users that match a search.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get usersResultsHeader;

  /// Second line of a user's row: their username and company.
  ///
  /// In en, this message translates to:
  /// **'@{username} · {company}'**
  String usersTileSubtitle(String username, String company);

  /// No description provided for @usersLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading users…'**
  String get usersLoading;

  /// Read out by screen readers for a row whose user is still loading.
  ///
  /// In en, this message translates to:
  /// **'Loading user'**
  String get usersRowLoading;

  /// No description provided for @usersRowFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this user'**
  String get usersRowFailed;

  /// No description provided for @usersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get usersEmptyTitle;

  /// No description provided for @usersNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No users match “{query}”'**
  String usersNoMatchTitle(String query);

  /// No description provided for @usersNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a name, username, email, company or city.'**
  String get usersNoMatchMessage;

  /// No description provided for @albumsTitle.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albumsTitle;

  /// No description provided for @albumsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading albums…'**
  String get albumsLoading;

  /// No description provided for @albumsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No albums yet'**
  String get albumsEmptyTitle;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosTitle;

  /// No description provided for @photosLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading photos…'**
  String get photosLoading;

  /// No description provided for @photosEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No photos in this album'**
  String get photosEmptyTitle;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photoTitle;

  /// No description provided for @photoLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading photo…'**
  String get photoLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
