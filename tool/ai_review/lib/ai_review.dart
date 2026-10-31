/// Reviews pull requests with a self-hosted, OpenAI-compatible model and
/// posts each finding as its own GitHub review thread.
library;

export 'src/cli.dart' show buildArgParser, defaultModel, runCli;
export 'src/diff/diff_filter.dart';
export 'src/diff/diff_source.dart';
export 'src/diff/file_diff.dart';
export 'src/diff/unified_diff_parser.dart';
export 'src/model/openai_compatible_model.dart';
export 'src/model/review_model.dart';
export 'src/publish/console_publisher.dart';
export 'src/publish/github_publisher.dart';
export 'src/publish/review_publisher.dart';
export 'src/review/comment_planner.dart';
export 'src/review/finding.dart';
export 'src/review/prompt_builder.dart';
export 'src/review/review_formatter.dart';
export 'src/review/review_parser.dart';
export 'src/review/text_safety.dart';
export 'src/review_service.dart';
