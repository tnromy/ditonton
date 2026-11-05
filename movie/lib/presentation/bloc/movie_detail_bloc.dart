import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/domain/usecases/get_movie_detail.dart';

class FetchMovieDetail extends Equatable {
  const FetchMovieDetail(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

abstract class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailEmpty extends MovieDetailState {
  const MovieDetailEmpty();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailHasData extends MovieDetailState {
  const MovieDetailHasData(this.movie);

  final MovieDetail movie;

  @override
  List<Object?> get props => [movie];
}

class MovieDetailError extends MovieDetailState {
  const MovieDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MovieDetailBloc extends Bloc<FetchMovieDetail, MovieDetailState> {
  MovieDetailBloc(GetMovieDetail getMovieDetail)
    : super(const MovieDetailEmpty()) {
    on<FetchMovieDetail>((event, emit) async {
      emit(const MovieDetailLoading());
      final result = await getMovieDetail.execute(event.id);
      result.fold(
        (failure) => emit(MovieDetailError(failure.message)),
        (movie) => emit(MovieDetailHasData(movie)),
      );
    });
  }
}
