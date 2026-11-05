import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/tv.dart';
import 'package:tv/domain/usecases/get_on_the_air_tv.dart';
import 'package:tv/domain/usecases/get_popular_tv.dart';
import 'package:tv/domain/usecases/get_top_rated_tv.dart';
import 'package:tv/domain/usecases/get_watchlist_tv.dart';

abstract class TvListEvent extends Equatable {
  const TvListEvent();

  @override
  List<Object?> get props => [];
}

class FetchTv extends TvListEvent {
  const FetchTv();
}

abstract class TvListState extends Equatable {
  const TvListState();

  @override
  List<Object?> get props => [];
}

class TvListEmpty extends TvListState {
  const TvListEmpty();
}

class TvListLoading extends TvListState {
  const TvListLoading();
}

class TvListHasData extends TvListState {
  const TvListHasData(this.tvs);

  final List<Tv> tvs;

  @override
  List<Object?> get props => [tvs];
}

class TvListError extends TvListState {
  const TvListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

typedef TvListLoader = Future<Either<Failure, List<Tv>>> Function();

abstract class TvListBloc extends Bloc<TvListEvent, TvListState> {
  TvListBloc(TvListLoader load) : super(const TvListEmpty()) {
    on<FetchTv>((event, emit) async {
      emit(const TvListLoading());
      final result = await load();
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) => emit(TvListHasData(tvs)),
      );
    });
  }
}

class OnTheAirTvBloc extends TvListBloc {
  OnTheAirTvBloc(GetOnTheAirTv usecase) : super(usecase.execute);
}

class PopularTvBloc extends TvListBloc {
  PopularTvBloc(GetPopularTv usecase) : super(usecase.execute);
}

class TopRatedTvBloc extends TvListBloc {
  TopRatedTvBloc(GetTopRatedTv usecase) : super(usecase.execute);
}

class WatchlistTvBloc extends TvListBloc {
  WatchlistTvBloc(GetWatchlistTv usecase) : super(usecase.execute);
}
