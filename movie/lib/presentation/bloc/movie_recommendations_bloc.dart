import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/usecases/get_movie_recommendations.dart';
import 'package:movie/presentation/bloc/movie_list_bloc.dart';

class FetchMovieRecommendations extends Equatable {
  const FetchMovieRecommendations(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class MovieRecommendationsBloc
    extends Bloc<FetchMovieRecommendations, MovieListState> {
  MovieRecommendationsBloc(GetMovieRecommendations getRecommendations)
    : super(const MovieListEmpty()) {
    on<FetchMovieRecommendations>((event, emit) async {
      emit(const MovieListLoading());
      final result = await getRecommendations.execute(event.id);
      result.fold(
        (failure) => emit(MovieListError(failure.message)),
        (movies) => emit(MovieListHasData(movies)),
      );
    });
  }
}
