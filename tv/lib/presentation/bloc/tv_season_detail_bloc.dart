import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/season_detail.dart';
import 'package:tv/domain/usecases/get_tv_season_detail.dart';

class FetchTvSeasonDetail extends Equatable {
  const FetchTvSeasonDetail({required this.tvId, required this.seasonNumber});

  final int tvId;
  final int seasonNumber;

  @override
  List<Object?> get props => [tvId, seasonNumber];
}

abstract class TvSeasonDetailState extends Equatable {
  const TvSeasonDetailState();

  @override
  List<Object?> get props => [];
}

class TvSeasonDetailEmpty extends TvSeasonDetailState {
  const TvSeasonDetailEmpty();
}

class TvSeasonDetailLoading extends TvSeasonDetailState {
  const TvSeasonDetailLoading();
}

class TvSeasonDetailHasData extends TvSeasonDetailState {
  const TvSeasonDetailHasData(this.season);

  final SeasonDetail season;

  @override
  List<Object?> get props => [season];
}

class TvSeasonDetailError extends TvSeasonDetailState {
  const TvSeasonDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class TvSeasonDetailBloc
    extends Bloc<FetchTvSeasonDetail, TvSeasonDetailState> {
  TvSeasonDetailBloc(GetTvSeasonDetail getTvSeasonDetail)
    : super(const TvSeasonDetailEmpty()) {
    on<FetchTvSeasonDetail>((event, emit) async {
      emit(const TvSeasonDetailLoading());
      final result = await getTvSeasonDetail.execute(
        event.tvId,
        event.seasonNumber,
      );
      result.fold(
        (failure) => emit(TvSeasonDetailError(failure.message)),
        (season) => emit(TvSeasonDetailHasData(season)),
      );
    });
  }
}
