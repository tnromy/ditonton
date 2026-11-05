import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/domain/usecases/get_now_playing_movies.dart';
import 'package:movie/domain/usecases/get_popular_movies.dart';
import 'package:movie/domain/usecases/get_top_rated_movies.dart';
import 'package:movie/domain/usecases/get_watchlist_movies.dart';

abstract class MovieListEvent extends Equatable {
  const MovieListEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovies extends MovieListEvent {
  const FetchMovies();
}

abstract class MovieListState extends Equatable {
  const MovieListState();

  @override
  List<Object?> get props => [];
}

class MovieListEmpty extends MovieListState {
  const MovieListEmpty();
}

class MovieListLoading extends MovieListState {
  const MovieListLoading();
}

class MovieListHasData extends MovieListState {
  const MovieListHasData(this.movies);

  final List<Movie> movies;

  @override
  List<Object?> get props => [movies];
}

class MovieListError extends MovieListState {
  const MovieListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

typedef MovieListLoader = Future<Either<Failure, List<Movie>>> Function();

abstract class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  MovieListBloc(MovieListLoader load) : super(const MovieListEmpty()) {
    on<FetchMovies>((event, emit) async {
      emit(const MovieListLoading());
      final result = await load();
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) => emit(MovieListHasData(movies)),
      );
    });
  }
}

class NowPlayingMoviesBloc extends MovieListBloc {
  NowPlayingMoviesBloc(GetNowPlayingMovies usecase) : super(usecase.execute);
}

class PopularMoviesBloc extends MovieListBloc {
  PopularMoviesBloc(GetPopularMovies usecase) : super(usecase.execute);
}

class TopRatedMoviesBloc extends MovieListBloc {
  TopRatedMoviesBloc(GetTopRatedMovies usecase) : super(usecase.execute);
}

class WatchlistMoviesBloc extends MovieListBloc {
  WatchlistMoviesBloc(GetWatchlistMovies usecase) : super(usecase.execute);
}
