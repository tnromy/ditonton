import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/usecases/get_tv_recommendations.dart';
import 'package:tv/presentation/bloc/tv_list_bloc.dart';

class FetchTvRecommendations extends Equatable {
  const FetchTvRecommendations(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class TvRecommendationsBloc extends Bloc<FetchTvRecommendations, TvListState> {
  TvRecommendationsBloc(GetTvRecommendations getRecommendations)
    : super(const TvListEmpty()) {
    on<FetchTvRecommendations>((event, emit) async {
      emit(const TvListLoading());
      final result = await getRecommendations.execute(event.id);
      result.fold(
        (failure) => emit(TvListError(failure.message)),
        (tvs) => emit(TvListHasData(tvs)),
      );
    });
  }
}
