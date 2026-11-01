// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tryAgain => 'Try again';

  @override
  String get failureOfflineTitle => 'You\'re offline';

  @override
  String get failureOfflineMessage => 'Check your connection and try again.';

  @override
  String get failureNotFoundTitle => 'Not found';

  @override
  String get failureNotFoundMessage => 'It may have been removed.';

  @override
  String get failureServerTitle => 'The server had a problem';

  @override
  String failureServerMessage(int statusCode) {
    return 'It answered with error $statusCode. Try again in a moment.';
  }

  @override
  String get failureUnexpectedTitle => 'Something didn\'t look right';

  @override
  String get failureUnexpectedMessage =>
      'The server\'s answer couldn\'t be read. Try again later.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'This page doesn\'t exist.';

  @override
  String get notFoundAction => 'Go to users';

  @override
  String get usersTitle => 'Users';

  @override
  String get usersSearchHint => 'Search users';

  @override
  String get usersSearchClear => 'Clear search';

  @override
  String get usersSortTooltip => 'Sort users';

  @override
  String get usersSortNameAscending => 'Name, A to Z';

  @override
  String get usersSortNameDescending => 'Name, Z to A';

  @override
  String get usersSortCompany => 'Company';

  @override
  String get usersSortCity => 'City';

  @override
  String get usersAllHeader => 'All users';

  @override
  String get usersResultsHeader => 'Results';

  @override
  String usersTileSubtitle(String username, String company) {
    return '@$username · $company';
  }

  @override
  String get usersLoading => 'Loading users…';

  @override
  String get usersRowLoading => 'Loading user';

  @override
  String get usersRowFailed => 'Couldn\'t load this user';

  @override
  String get usersEmptyTitle => 'No users yet';

  @override
  String usersNoMatchTitle(String query) {
    return 'No users match “$query”';
  }

  @override
  String get usersNoMatchMessage =>
      'Try a name, username, email, company or city.';

  @override
  String get albumsTitle => 'Albums';

  @override
  String get albumsLoading => 'Loading albums…';

  @override
  String get albumsEmptyTitle => 'No albums yet';

  @override
  String get photosTitle => 'Photos';

  @override
  String get photosLoading => 'Loading photos…';

  @override
  String get photosEmptyTitle => 'No photos in this album';

  @override
  String get photoTitle => 'Photo';

  @override
  String get photoLoading => 'Loading photo…';
}
