/// The model that writes the review.
abstract interface class ReviewModel {
  /// Shown in the review, e.g. `qwen38-flash`.
  String get name;

  /// Sends one system + user message pair and returns the full answer.
  /// When [jsonSchema] is given, the server is asked to constrain the answer
  /// to it (if it can't, the request is retried without it).
  /// Throws [ReviewModelException] when no answer could be had.
  Future<ModelReply> complete({
    required String system,
    required String user,
    Map<String, Object?>? jsonSchema,
  });
}

class ModelReply {
  const new(this.text, {this.promptTokens, this.completionTokens});

  final String text;
  final int? promptTokens;
  final int? completionTokens;
}

/// The model server couldn't produce an answer. [message] is safe to show
/// in a public PR: it never contains the key or the server's address.
class ReviewModelException implements Exception {
  const new(this.message);

  final String message;

  @override
  String toString() => 'ReviewModelException: $message';
}
