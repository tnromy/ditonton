import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/tv_detail.dart';
import 'package:tv/domain/usecases/get_watchlist_status_tv.dart';
import 'package:tv/domain/usecases/remove_watchlist_tv.dart';
import 'package:tv/domain/usecases/save_watchlist_tv.dart';

abstract class TvWatchlistEvent extends Equatable {
  const TvWatchlistEvent();
}

class LoadTvWatchlistStatus extends TvWatchlistEvent {
  const LoadTvWatchlistStatus(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class AddTvToWatchlist extends TvWatchlistEvent {
  const AddTvToWatchlist(this.tv);

  final TvDetail tv;

  @override
  List<Object?> get props => [tv];
}

class RemoveTvFromWatchlist extends TvWatchlistEvent {
  const RemoveTvFromWatchlist(this.tv);

  final TvDetail tv;

  @override
  List<Object?> get props => [tv];
}

class TvWatchlistState extends Equatable {
  const TvWatchlistState({this.isAdded = false, this.message = ''});

  final bool isAdded;
  final String message;

  @override
  List<Object?> get props => [isAdded, message];
}

class TvWatchlistBloc extends Bloc<TvWatchlistEvent, TvWatchlistState> {
  static const addSuccessMessage = 'Added to Watchlist';
  static const removeSuccessMessage = 'Removed from Watchlist';

  TvWatchlistBloc({
    required GetWatchlistStatusTv getWatchlistStatus,
    required SaveWatchlistTv saveWatchlist,
    required RemoveWatchlistTv removeWatchlist,
  }) : super(const TvWatchlistState()) {
    on<LoadTvWatchlistStatus>((event, emit) async {
      final isAdded = await getWatchlistStatus.execute(event.id);
      emit(TvWatchlistState(isAdded: isAdded));
    });

    Future<void> update(
      Emitter<TvWatchlistState> emit,
      TvDetail tv,
      Future<Either<Failure, String>> Function() action,
    ) async {
      if (state.message.isNotEmpty) {
        emit(TvWatchlistState(isAdded: state.isAdded));
      }
      final result = await action();
      final message = result.fold((failure) => failure.message, (ok) => ok);
      final isAdded = await getWatchlistStatus.execute(tv.id);
      emit(TvWatchlistState(isAdded: isAdded, message: message));
    }

    on<AddTvToWatchlist>(
      (event, emit) =>
          update(emit, event.tv, () => saveWatchlist.execute(event.tv)),
    );
    on<RemoveTvFromWatchlist>(
      (event, emit) =>
          update(emit, event.tv, () => removeWatchlist.execute(event.tv)),
    );
  }
}
