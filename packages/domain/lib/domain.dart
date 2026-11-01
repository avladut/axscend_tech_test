/// What the app is about, independent of any backend: models, repository
/// contracts and typed failures.
///
/// Pure Dart. Must not depend on Flutter, http or a data package.
library;

export 'src/failures/data_failure.dart';
export 'src/models/address.dart';
export 'src/models/album.dart';
export 'src/models/comment.dart';
export 'src/models/company.dart';
export 'src/models/geo.dart';
export 'src/models/photo.dart';
export 'src/models/post.dart';
export 'src/models/todo.dart';
export 'src/models/user.dart';
export 'src/repositories/album_repository.dart';
export 'src/repositories/post_repository.dart';
export 'src/repositories/todo_repository.dart';
export 'src/repositories/user_repository.dart';
