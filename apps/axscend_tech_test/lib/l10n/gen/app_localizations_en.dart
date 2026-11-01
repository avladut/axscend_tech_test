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

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLoading => 'Loading profile…';

  @override
  String get profileContact => 'Contact';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileWebsite => 'Website';

  @override
  String get profileAddress => 'Address';

  @override
  String profileAddressLine(
    String street,
    String suite,
    String city,
    String zipcode,
  ) {
    return '$street, $suite, $city $zipcode';
  }

  @override
  String get profileCompany => 'Company';

  @override
  String get profileCatchPhrase => 'Catchphrase';

  @override
  String get profileActivity => 'Activity';

  @override
  String get profilePosts => 'Posts';

  @override
  String profilePostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
      zero: 'No posts',
    );
    return '$_temp0';
  }

  @override
  String get profileAlbums => 'Albums';

  @override
  String profileAlbumsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count albums',
      one: '1 album',
      zero: 'No albums',
    );
    return '$_temp0';
  }

  @override
  String get profileTodos => 'Todos';

  @override
  String get postsTitle => 'Posts';

  @override
  String get postsLoading => 'Loading posts…';

  @override
  String get postsEmptyTitle => 'No posts yet';

  @override
  String get postTitle => 'Post';

  @override
  String get postLoading => 'Loading post…';

  @override
  String get commentsHeader => 'Comments';

  @override
  String get commentsEmptyTitle => 'No comments yet';

  @override
  String get todosTitle => 'Todos';

  @override
  String get todosLoading => 'Loading todos…';

  @override
  String get todosEmptyTitle => 'No todos yet';

  @override
  String get todosNoneDoneTitle => 'Nothing done yet';

  @override
  String get todosNonePendingTitle => 'All done';

  @override
  String todosDoneCount(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get todosProgressLabel => 'Todos done';

  @override
  String todosFilterAll(int count) {
    return 'All ($count)';
  }

  @override
  String todosFilterDone(int count) {
    return 'Done ($count)';
  }

  @override
  String todosFilterPending(int count) {
    return 'Pending ($count)';
  }
}
