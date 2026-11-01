import 'dart:convert';

import 'package:ai_review/src/publish/review_publisher.dart';
import 'package:ai_review/src/review/comment_planner.dart';
import 'package:ai_review/src/review/review_formatter.dart';
import 'package:http/http.dart' as http;

/// Posts the review on the pull request through GitHub's REST API.
///
/// Each run is one PR review with `event: COMMENT` (never APPROVE or
/// REQUEST_CHANGES). Every finding is its own thread, so branch protection's
/// "conversations must be resolved" makes Alex decide on each one.
class GitHubPublisher implements ReviewPublisher {
  new({
    required this.repository,
    required this.pullNumber,
    required this.headSha,
    required this._token,
    http.Client? client,
    Uri? apiBase,
    this.botLogin = 'github-actions[bot]',
    this._formatter = const ReviewFormatter(),
  }) : _client = client ?? http.Client(),
       _apiBase = apiBase ?? Uri.parse('https://api.github.com');

  /// `owner/name`.
  final String repository;
  final int pullNumber;

  /// The commit the threads are attached to.
  final String headSha;

  /// Only reviews by this account count as earlier AI reviews.
  final String botLogin;

  final String _token;
  final http.Client _client;
  final Uri _apiBase;
  final ReviewFormatter _formatter;

  static const _pageSize = 100;
  static const _maxPages = 10;

  String get _pullPath => '/repos/$repository/pulls/$pullNumber';

  @override
  Future<String?> lastReviewedSha() async {
    String? last;
    int? lastId;
    for (var page = 1; page <= _maxPages; page++) {
      final reviews = await _get(
        '$_pullPath/reviews',
        query: {'per_page': '$_pageSize', 'page': '$page'},
      );
      if (reviews is! List || reviews.isEmpty) break;
      // The newest marked review wins. GitHub documents oldest-first order,
      // but review ids only ever grow, so the highest id is newest whatever
      // order the list arrives in.
      for (final review in reviews) {
        if (review
            case {
              'id': final int id,
              'user': {'login': final String login},
              'body': final String body,
            }
            when login == botLogin && (lastId == null || id > lastId)) {
          final match = ReviewFormatter.markerPattern.firstMatch(body);
          if (match != null) {
            last = match.group(1);
            lastId = id;
          }
        }
      }
      if (reviews.length < _pageSize) break;
    }
    return last;
  }

  @override
  Future<void> publish(
    ReviewReport report,
    List<PlannedComment> comments,
  ) async {
    final body = _formatter.reviewBody(report);
    final onLines = [
      for (final comment in comments)
        if (comment.placement == Placement.line) comment,
    ];
    final onFiles = [
      for (final comment in comments)
        if (comment.placement != Placement.line) comment,
    ];

    try {
      await _createReview(body, onLines, report.model);
    } on _Unprocessable {
      // GitHub refused a line position. Post the review without line threads
      // and put those findings on their files instead, so none are lost.
      await _createReview(body, const [], report.model);
      onFiles.insertAll(0, onLines);
    }
    for (final comment in onFiles) {
      final body = _formatter.commentBody(comment, model: report.model);
      try {
        await _post('$_pullPath/comments', {
          'commit_id': headSha,
          'path': comment.path,
          'subject_type': 'file',
          'body': body,
        }, recoverable: true);
      } on _Unprocessable {
        // GitHub refused the file, most likely because it isn't in the PR's
        // diff. The finding goes in the conversation instead of being lost.
        await _post('/repos/$repository/issues/$pullNumber/comments', {
          'body':
              "_About `${comment.path}`, which GitHub won't let the bot "
              'comment on directly._\n\n$body',
        });
      }
    }
  }

  @override
  Future<void> publishUnavailable({
    required String reason,
    required String model,
  }) => _post('$_pullPath/reviews', {
    'commit_id': headSha,
    'event': 'COMMENT',
    'body': _formatter.unavailableBody(reason: reason, model: model),
  });

  @override
  Future<void> publishNote({
    required String title,
    required String detail,
    String? reviewedSha,
  }) => _post('$_pullPath/reviews', {
    'commit_id': headSha,
    'event': 'COMMENT',
    'body': _formatter.noteBody(
      title: title,
      detail: detail,
      reviewedSha: reviewedSha,
    ),
  });

  Future<void> _createReview(
    String body,
    List<PlannedComment> onLines,
    String model,
  ) => _post('$_pullPath/reviews', {
    'commit_id': headSha,
    'event': 'COMMENT',
    'body': body,
    'comments': [
      for (final comment in onLines)
        {
          'path': comment.path,
          'line': comment.line,
          'side': 'RIGHT',
          'body': _formatter.commentBody(comment, model: model),
        },
    ],
  }, recoverable: onLines.isNotEmpty);

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_token',
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'ai-review',
  };

  Uri _uri(String path, [Map<String, String>? query]) =>
      _apiBase.replace(path: '${_apiBase.path}$path', queryParameters: query);

  Future<Object?> _get(String path, {Map<String, String>? query}) async {
    final response = await _send(
      'GET',
      path,
      () => _client.get(_uri(path, query), headers: _headers),
    );
    _check('GET', path, response);
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw PublishException(
        'GitHub GET $path answered HTTP ${response.statusCode} with a body '
        'that is not JSON.',
      );
    }
  }

  /// Turns any failure to talk to GitHub (network, TLS…) into a
  /// [PublishException], which the CLI catches and logs. The token is only
  /// ever in a header, so it can't appear in the message.
  static Future<http.Response> _send(
    String method,
    String path,
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on Exception catch (error) {
      throw PublishException(
        'Could not reach GitHub for $method $path: $error',
      );
    }
  }

  /// [recoverable]: a 422 then means GitHub refused where a comment goes (a
  /// line or file outside the diff), which [publish] can recover from.
  Future<void> _post(
    String path,
    Map<String, Object?> json, {
    bool recoverable = false,
  }) async {
    final response = await _send(
      'POST',
      path,
      () => _client.post(
        _uri(path),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(json),
      ),
    );
    if (response.statusCode == 422 && recoverable) {
      throw const _Unprocessable();
    }
    _check('POST', path, response);
  }

  static void _check(String method, String path, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw PublishException(
      'GitHub $method $path failed with HTTP ${response.statusCode}: '
      '${_errorMessage(response)}',
    );
  }

  static String _errorMessage(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      if (json case {'message': final String message}) return message;
    } on FormatException {
      // Not JSON; fall through.
    }
    return response.reasonPhrase ?? 'no details';
  }
}

class _Unprocessable implements Exception {
  const new();
}
