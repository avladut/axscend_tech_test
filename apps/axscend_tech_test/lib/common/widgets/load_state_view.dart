import 'package:app_ui/app_ui.dart';
import 'package:axscend_tech_test/common/loading/load_bloc.dart';
import 'package:axscend_tech_test/common/widgets/data_failure_view.dart';
import 'package:flutter/widgets.dart';

/// What a screen shows for a [LoadState]: a spinner until the data first
/// arrives, the failure with "Try again", or [builder] with the data, also
/// while a refresh runs.
class LoadStateView<T> extends StatelessWidget {
  const new({
    required this.state,
    required this.loadingTitle,
    required this.onRetry,
    required this.builder,
    super.key,
  });

  final LoadState<T> state;

  /// Such as "Loading albums…", read out by screen readers.
  final String loadingTitle;

  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    final data = state.data;
    if (state.status == LoadStatus.failure && failure != null) {
      return DataFailureView(failure: failure, onRetry: onRetry);
    }
    if (data != null) return builder(context, data);
    return AppStatusView.loading(title: loadingTitle);
  }
}
