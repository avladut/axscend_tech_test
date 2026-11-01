import 'package:domain/domain.dart';
import 'package:jsonplaceholder_data/src/client/json_client.dart';
import 'package:jsonplaceholder_data/src/dto/comment_dto.dart';
import 'package:jsonplaceholder_data/src/dto/json_parsing.dart';
import 'package:jsonplaceholder_data/src/dto/post_dto.dart';

class JsonPlaceholderPostRepository implements PostRepository {
  const new(this._client);

  final JsonClient _client;

  @override
  Future<List<Post>> getPosts({int? userId, bool refresh = false}) async =>
      parseList(
        await _client.get(
          userId == null ? '/posts' : '/users/$userId/posts',
          refresh: refresh,
        ),
        'post',
        (json) => PostDto.fromJson(json).toDomain(),
      );

  @override
  Future<Post> getPost(int id, {bool refresh = false}) async =>
      PostDto.fromJson(await _client.get('/posts/$id', refresh: refresh))
          .toDomain();

  @override
  Future<List<Comment>> getComments(int postId, {bool refresh = false}) async =>
      parseList(
        await _client.get('/posts/$postId/comments', refresh: refresh),
        'comment',
        (json) => CommentDto.fromJson(json).toDomain(),
      );
}
