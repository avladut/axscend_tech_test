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

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoading;

  /// No description provided for @profileContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get profileContact;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get profileWebsite;

  /// No description provided for @profileAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddress;

  /// A user's address on one line.
  ///
  /// In en, this message translates to:
  /// **'{street}, {suite}, {city} {zipcode}'**
  String profileAddressLine(
    String street,
    String suite,
    String city,
    String zipcode,
  );

  /// No description provided for @profileCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get profileCompany;

  /// No description provided for @profileCatchPhrase.
  ///
  /// In en, this message translates to:
  /// **'Catchphrase'**
  String get profileCatchPhrase;

  /// No description provided for @profileActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// No description provided for @profilePosts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get profilePosts;

  /// No description provided for @profilePostsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No posts} =1{1 post} other{{count} posts}}'**
  String profilePostsCount(int count);

  /// No description provided for @profileAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get profileAlbums;

  /// No description provided for @profileAlbumsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No albums} =1{1 album} other{{count} albums}}'**
  String profileAlbumsCount(int count);

  /// No description provided for @profileTodos.
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get profileTodos;

  /// No description provided for @postsTitle.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsTitle;

  /// No description provided for @postsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading posts…'**
  String get postsLoading;

  /// No description provided for @postsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get postsEmptyTitle;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postTitle;

  /// No description provided for @postLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading post…'**
  String get postLoading;

  /// No description provided for @commentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsHeader;

  /// No description provided for @commentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// No description provided for @todosTitle.
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get todosTitle;

  /// No description provided for @todosLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading todos…'**
  String get todosLoading;

  /// No description provided for @todosEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No todos yet'**
  String get todosEmptyTitle;

  /// No description provided for @todosNoneDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing done yet'**
  String get todosNoneDoneTitle;

  /// No description provided for @todosNonePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get todosNonePendingTitle;

  /// No description provided for @todosDoneCount.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String todosDoneCount(int done, int total);

  /// Read out by screen readers for the progress ring.
  ///
  /// In en, this message translates to:
  /// **'Todos done'**
  String get todosProgressLabel;

  /// No description provided for @todosFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String todosFilterAll(int count);

  /// No description provided for @todosFilterDone.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String todosFilterDone(int count);

  /// No description provided for @todosFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String todosFilterPending(int count);
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
