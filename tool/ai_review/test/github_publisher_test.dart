import 'dart:convert';

import 'package:ai_review/ai_review.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import 'support/fakes.dart';

void main() {
  group(GitHubPublisher, () {
    late List<http.Request> requests;

    GitHubPublisher publisherWith(
      http.Response Function(http.Request request) handler, {
      Uri? apiBase,
    }) {
      requests = [];
      return GitHubPublisher(
        repository: 'avladut/axscend_tech_test',
        pullNumber: 7,
        headSha: shaB,
        token: 'gh-token',
        apiBase: apiBase,
        client: MockClient((request) async {
          requests.add(request);
          return handler(request);
        }),
      );
    }

    Map<String, Object?> review(String login, String body) => {
      'user': {'login': login},
      'body': body,
    };

    Map<String, Object?> bodyOf(http.Request request) =>
        jsonDecode(request.body) as Map<String, Object?>;

    group('lastReviewedSha', () {
      test("returns the newest commit from the bot's own reviews", () async {
        final publisher = publisherWith(
          (_) => http.Response(
            jsonEncode([
              review(
                'github-actions[bot]',
                '${ReviewFormatter.marker(shaA)}\nold',
              ),
              review('avladut', '${ReviewFormatter.marker(shaC)}\nhuman'),
              review('github-actions[bot]', 'unavailable, no marker'),
              review(
                'github-actions[bot]',
                '${ReviewFormatter.marker(shaB)}\nnew',
              ),
            ]),
            200,
          ),
        );

        expect(await publisher.lastReviewedSha(), shaB);
        final request = requests.single;
        expect(
          request.url.path,
          '/repos/avladut/axscend_tech_test/pulls/7/reviews',
        );
        expect(request.headers['Authorization'], 'Bearer gh-token');
      });

      test('reads further pages', () async {
        final publisher = publisherWith((request) {
          final page = request.url.queryParameters['page'];
          return http.Response(
            jsonEncode(
              page == '1'
                  ? List.filled(100, review('someone', 'hi'))
                  : [
                      review(
                        'github-actions[bot]',
                        ReviewFormatter.marker(shaC),
                      ),
                    ],
            ),
            200,
          );
        });

        expect(await publisher.lastReviewedSha(), shaC);
        expect(requests, hasLength(2));
      });

      test('returns null without earlier reviews', () async {
        final publisher = publisherWith((_) => http.Response('[]', 200));
        expect(await publisher.lastReviewedSha(), isNull);
      });

      test('fails clearly when GitHub refuses', () async {
        final publisher = publisherWith(
          (_) => http.Response('{"message": "Bad credentials"}', 401),
        );
        await expectLater(
          publisher.lastReviewedSha(),
          throwsA(
            isA<PublishException>().having(
              (e) => e.message,
              'message',
              contains('Bad credentials'),
            ),
          ),
        );
      });
    });

    group('publish', () {
      final selection = DiffSelection(files: [addedFile('lib/a.dart')]);
      final report = ReviewReport(
        review: const StructuredReview(summary: 'ok', findings: []),
        selection: selection,
        model: 'qwen38-flash',
        headSha: shaB,
        took: const Duration(seconds: 3),
      );
      final onLine = PlannedComment(
        finding: finding(title: 'On a line'),
        path: 'lib/a.dart',
        placement: Placement.line,
        line: 2,
      );
      final onFile = PlannedComment(
        finding: finding(title: 'On the file'),
        path: 'lib/a.dart',
        placement: Placement.file,
      );

      test(
        'posts one COMMENT review with line threads, then file threads',
        () async {
          final publisher = publisherWith((_) => http.Response('{}', 201));

          await publisher.publish(report, [onLine, onFile]);

          expect(requests, hasLength(2));
          final reviewRequest = bodyOf(requests.first);
          expect(requests.first.url.path, endsWith('/pulls/7/reviews'));
          expect(reviewRequest['event'], 'COMMENT');
          expect(reviewRequest['commit_id'], shaB);
          expect(
            reviewRequest['body'],
            startsWith(ReviewFormatter.marker(shaB)),
          );
          final lineThread = (reviewRequest['comments']! as List).single as Map;
          expect(lineThread['path'], 'lib/a.dart');
          expect(lineThread['line'], 2);
          expect(lineThread['side'], 'RIGHT');

          expect(requests.last.url.path, endsWith('/pulls/7/comments'));
          final fileThread = bodyOf(requests.last);
          expect(fileThread['subject_type'], 'file');
          expect(fileThread['path'], 'lib/a.dart');
          expect(fileThread['body'], contains('On the file'));
        },
      );

      test(
        'moves line threads to their files when GitHub rejects a line',
        () async {
          var reviewPosts = 0;
          final publisher = publisherWith((request) {
            if (request.url.path.endsWith('/reviews') && reviewPosts++ == 0) {
              return http.Response(
                '{"message": "line must be part of the diff"}',
                422,
              );
            }
            return http.Response('{}', 201);
          });

          await publisher.publish(report, [onLine, onFile]);

          final paths = requests.map((r) => r.url.path.split('/').last);
          expect(paths, ['reviews', 'reviews', 'comments', 'comments']);
          expect(bodyOf(requests[1])['comments'], isEmpty);
          expect(bodyOf(requests[2])['body'], contains('On a line'));
          expect(bodyOf(requests[3])['body'], contains('On the file'));
        },
      );

      test('never approves or requests changes', () async {
        final publisher = publisherWith((_) => http.Response('{}', 201));

        await publisher.publish(report, [onLine]);
        await publisher.publishUnavailable(reason: 'down', model: 'm');

        for (final request in requests) {
          final event = bodyOf(request)['event'];
          if (event != null) expect(event, 'COMMENT');
        }
      });
    });

    test('posts an "unavailable" review without a marker', () async {
      final publisher = publisherWith((_) => http.Response('{}', 201));

      await publisher.publishUnavailable(reason: 'timed out', model: 'm');

      final body = bodyOf(requests.single)['body']! as String;
      expect(body, contains('AI review unavailable'));
      expect(ReviewFormatter.markerPattern.hasMatch(body), isFalse);
    });

    test(
      'posts a note as a COMMENT review, with the marker if given',
      () async {
        final publisher = publisherWith((_) => http.Response('{}', 201));

        await publisher.publishNote(
          title: 'nothing to review',
          detail: 'Only lockfiles changed.',
          reviewedSha: shaB,
        );

        final request = bodyOf(requests.single);
        expect(requests.single.url.path, endsWith('/pulls/7/reviews'));
        expect(request['event'], 'COMMENT');
        expect(request.containsKey('comments'), isFalse);
        final body = request['body']! as String;
        expect(ReviewFormatter.markerPattern.firstMatch(body)?.group(1), shaB);
        expect(body, contains('nothing to review'));
      },
    );

    test('works with a GitHub Enterprise API base', () async {
      final publisher = publisherWith(
        (_) => http.Response('[]', 200),
        apiBase: Uri.parse('https://ghe.example/api/v3'),
      );

      await publisher.lastReviewedSha();

      expect(
        requests.single.url.path,
        '/api/v3/repos/avladut/axscend_tech_test/pulls/7/reviews',
      );
    });
  });
}
