import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/domain/entities/tv_detail.dart';
import 'package:tv/domain/usecases/get_tv_detail.dart';

class FetchTvDetail extends Equatable {
  const FetchTvDetail(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

abstract class TvDetailState extends Equatable {
  const TvDetailState();

  @override
  List<Object?> get props => [];
}

class TvDetailEmpty extends TvDetailState {
  const TvDetailEmpty();
}

class TvDetailLoading extends TvDetailState {
  const TvDetailLoading();
}

class TvDetailHasData extends TvDetailState {
  const TvDetailHasData(this.tv);

  final TvDetail tv;

  @override
  List<Object?> get props => [tv];
}

class TvDetailError extends TvDetailState {
  const TvDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class TvDetailBloc extends Bloc<FetchTvDetail, TvDetailState> {
  TvDetailBloc(GetTvDetail getTvDetail) : super(const TvDetailEmpty()) {
    on<FetchTvDetail>((event, emit) async {
      emit(const TvDetailLoading());
      final result = await getTvDetail.execute(event.id);
      result.fold(
        (failure) => emit(TvDetailError(failure.message)),
        (tv) => emit(TvDetailHasData(tv)),
      );
    });
  }
}
