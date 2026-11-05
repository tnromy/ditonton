import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/domain/usecases/get_watchlist_status.dart';
import 'package:movie/domain/usecases/remove_watchlist.dart';
import 'package:movie/domain/usecases/save_watchlist.dart';

abstract class MovieWatchlistEvent extends Equatable {
  const MovieWatchlistEvent();
}

class LoadMovieWatchlistStatus extends MovieWatchlistEvent {
  const LoadMovieWatchlistStatus(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class AddMovieToWatchlist extends MovieWatchlistEvent {
  const AddMovieToWatchlist(this.movie);

  final MovieDetail movie;

  @override
  List<Object?> get props => [movie];
}

class RemoveMovieFromWatchlist extends MovieWatchlistEvent {
  const RemoveMovieFromWatchlist(this.movie);

  final MovieDetail movie;

  @override
  List<Object?> get props => [movie];
}

class MovieWatchlistState extends Equatable {
  const MovieWatchlistState({this.isAdded = false, this.message = ''});

  final bool isAdded;
  final String message;

  @override
  List<Object?> get props => [isAdded, message];
}

class MovieWatchlistBloc
    extends Bloc<MovieWatchlistEvent, MovieWatchlistState> {
  static const addSuccessMessage = 'Added to Watchlist';
  static const removeSuccessMessage = 'Removed from Watchlist';

  MovieWatchlistBloc({
    required GetWatchListStatus getWatchListStatus,
    required SaveWatchlist saveWatchlist,
    required RemoveWatchlist removeWatchlist,
  }) : super(const MovieWatchlistState()) {
    on<LoadMovieWatchlistStatus>((event, emit) async {
      final isAdded = await getWatchListStatus.execute(event.id);
      emit(MovieWatchlistState(isAdded: isAdded));
    });

    Future<void> update(
      Emitter<MovieWatchlistState> emit,
      MovieDetail movie,
      Future<Either<Failure, String>> Function() action,
    ) async {
      if (state.message.isNotEmpty) {
        emit(MovieWatchlistState(isAdded: state.isAdded));
      }
      final result = await action();
      final message = result.fold((failure) => failure.message, (ok) => ok);
      final isAdded = await getWatchListStatus.execute(movie.id);
      emit(MovieWatchlistState(isAdded: isAdded, message: message));
    }

    on<AddMovieToWatchlist>(
      (event, emit) =>
          update(emit, event.movie, () => saveWatchlist.execute(event.movie)),
    );
    on<RemoveMovieFromWatchlist>(
      (event, emit) =>
          update(emit, event.movie, () => removeWatchlist.execute(event.movie)),
    );
  }
}
