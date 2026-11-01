import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Ask for the data. With [refresh], fresh from the backend rather than the
/// cache.
final class LoadRequested extends Equatable {
  const new({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

enum LoadStatus { initial, loading, success, failure }

/// A screen's data and where its loading stands.
final class LoadState<T> extends Equatable {
  const new({this.status = LoadStatus.initial, this.data, this.failure});

  final LoadStatus status;

  /// The last data that arrived. Kept while a refresh runs.
  final T? data;

  /// Why the last load failed. Set only when [status] is
  /// [LoadStatus.failure]; the View puts it into words.
  final DataFailure? failure;

  @override
  List<Object?> get props => [status, data, failure];
}

/// A bloc for a screen that loads one thing, shows it, and can refresh it.
/// Subclasses only say how to [load] it.
abstract class LoadBloc<T> extends Bloc<LoadRequested, LoadState<T>> {
  new() : super(LoadState<T>()) {
    // A request while one runs (a double pull-to-refresh) is dropped.
    on<LoadRequested>(_onLoadRequested, transformer: droppable());
  }

  /// Fetches the data. Throws a [DataFailure] when it can't.
  @protected
  Future<T> load({required bool refresh});

  /// Asks for fresh data. Completes once it has arrived or failed, or the
  /// bloc has closed, so a pull-to-refresh spinner knows when to stop.
  Future<void> refresh() {
    add(const LoadRequested(refresh: true));
    return stream.firstWhere(
      (state) => state.status != LoadStatus.loading,
      orElse: () => state,
    );
  }

  Future<void> _onLoadRequested(
    LoadRequested event,
    Emitter<LoadState<T>> emit,
  ) async {
    emit(LoadState(status: LoadStatus.loading, data: state.data));
    try {
      final data = await load(refresh: event.refresh);
      emit(LoadState(status: LoadStatus.success, data: data));
    } on DataFailure catch (failure) {
      emit(
        LoadState(
          status: LoadStatus.failure,
          data: state.data,
          failure: failure,
        ),
      );
    }
  }
}

/// Waits for [a] and [b] side by side. If either fails, throws that failure
/// itself (the first one), so a [LoadBloc] can show it. A second failure
/// is dropped rather than left unhandled.
Future<(A, B)> loadBoth<A, B>(Future<A> a, Future<B> b) async {
  final results = await Future.wait<Object?>([a, b]);
  return (results[0] as A, results[1] as B);
}
