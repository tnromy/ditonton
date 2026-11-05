import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/usecases/search_movies.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';
import 'package:rxdart/rxdart.dart';

class OnMovieQueryChanged extends Equatable {
  const OnMovieQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

EventTransformer<T> _debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class SearchMoviesBloc extends Bloc<OnMovieQueryChanged, MovieListState> {
  static const debounceDuration = Duration(milliseconds: 500);

  SearchMoviesBloc(SearchMovies searchMovies) : super(const MovieListEmpty()) {
    on<OnMovieQueryChanged>((event, emit) async {
      final query = event.query.trim();
      if (query.isEmpty) {
        emit(const MovieListEmpty());
        return;
      }

      emit(const MovieListLoading());
      final result = await searchMovies.execute(query);
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) => emit(MovieListHasData(movies)),
      );
    }, transformer: _debounce(debounceDuration));
  }
}
